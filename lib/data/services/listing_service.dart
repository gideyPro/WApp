import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../../core/network/v2/api_v2_constants.dart';
import '../../core/utils/type_utils.dart';
import '../models/listing.dart';
import '../models/listing_form_data.dart';
import '../models/v2/owner_listing.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/catalog_filters.dart';
import 'v2/catalog_service.dart';
import 'v2/listing_media_service.dart';
import 'v2/owner_listing_service.dart';
import 'v2/promotion_service.dart';

/// Service for managing property listings backed by V2 API.
class ListingService {
  final ApiClient _apiClient;
  final CatalogService _catalog;
  final OwnerListingService _owner;
  final ListingMediaServiceV2 _media;
  final PromotionServiceV2 _promo;
  final Map<String, Map<int, String>> _cursorStore = {};

  ListingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        _catalog = CatalogService(client: ApiV2Client(apiClient: apiClient)),
        _owner = OwnerListingService(client: ApiV2Client(apiClient: apiClient)),
        _media = ListingMediaServiceV2(client: ApiV2Client(apiClient: apiClient)),
        _promo = PromotionServiceV2(client: ApiV2Client(apiClient: apiClient));

  Future<ListingResponse> getListings({
    int page = 1,
    int perPage = 15,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryKey = 'cat_${filters?.toString() ?? ''}';
      if (page <= 1) {
        _cursorStore.remove(queryKey);
      }
      final pageCursors = _cursorStore.putIfAbsent(queryKey, () => {});
      final cursor = page > 1 ? pageCursors[page] : null;

      final listingFilters = ListingFilters(
        type: filters?['type']?.toString(),
        listingType: filters?['listing_type']?.toString(),
        rentalPeriodUnit: filters?['rental_period_unit']?.toString(),
        location: filters?['location']?.toString() ?? filters?['city']?.toString(),
        priceMin: filters?['price_min'] is num ? (filters!['price_min'] as num).toDouble() : null,
        priceMax: filters?['price_max'] is num ? (filters!['price_max'] as num).toDouble() : null,
        areaMin: filters?['area_min'] is num ? (filters!['area_min'] as num).toDouble() : null,
        areaMax: filters?['area_max'] is num ? (filters!['area_max'] as num).toDouble() : null,
        minBedrooms: filters?['bedrooms'] is num ? (filters!['bedrooms'] as num).toInt() : null,
        minBathrooms: filters?['bathrooms'] is num ? (filters!['bathrooms'] as num).toInt() : null,
      );

      final result = await _catalog.fetchListings(
        cursor: cursor,
        limit: perPage,
        filters: listingFilters,
      );

      if (result.nextCursor != null) {
        pageCursors[page + 1] = result.nextCursor!;
      }

      final listings = result.items.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: listings.length,
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> getMyListings({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    try {
      final queryKey = 'my_${status?.toLowerCase() ?? 'all'}';
      if (page <= 1) {
        _cursorStore.remove(queryKey);
      }
      final pageCursors = _cursorStore.putIfAbsent(queryKey, () => {});
      final cursor = page > 1 ? pageCursors[page] : null;

      final oStatus = switch (status?.toLowerCase()) {
        'active' => OwnerListingStatus.active,
        'pending' => OwnerListingStatus.pending,
        'rejected' => OwnerListingStatus.rejected,
        'frozen' => OwnerListingStatus.frozen,
        'draft' => OwnerListingStatus.draft,
        _ => null,
      };

      final result = await _owner.fetch(
        cursor: cursor,
        limit: perPage,
        status: oStatus,
      );

      if (result.nextCursor != null) {
        pageCursors[page + 1] = result.nextCursor!;
      }

      final listings = result.items.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: listings.length,
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> getVipListings({int limit = 10}) async {
    try {
      final result = await _catalog.fetchListings(
        limit: limit,
        filters: const ListingFilters(sort: CatalogSort.newest),
      );

      final listings = result.items
          .where((s) => s.isVip)
          .map((s) => s.toListing())
          .toList();

      return ListingResponse(
        success: true,
        listings: listings,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> getFeaturedListings({int page = 1, int limit = 10}) async {
    try {
      final items = await _catalog.fetchFeaturedListings(limit: limit);
      final listings = items.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingDetailResponse> getListingDetail(int listingId) async {
    try {
      final detail = await _catalog.fetchListing(listingId);
      final listing = detail.toListing();

      return ListingDetailResponse(
        success: true,
        listing: listing,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingDetailResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<VideoProcessing?> getVideoStatus(int listingId) async {
    try {
      final v = await _media.fetchVideo(listingId);
      final status = switch (v.status) {
        VideoStateStatus.ready => VideoProcessingStatus.ready,
        VideoStateStatus.processing => VideoProcessingStatus.processing,
        VideoStateStatus.failed => VideoProcessingStatus.failed,
        _ => VideoProcessingStatus.pending,
      };
      return VideoProcessing(status: status, processedUrl: v.url);
    } catch (_) {
      return null;
    }
  }

  Future<ListingResponse> getSimilarListings(int listingId) async {
    try {
      final detail = await _catalog.fetchListing(listingId);
      final listings = detail.similar.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
        total: listings.length,
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> createListing({
    required ListingFormData formData,
    String? submissionKey,
    void Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);
      final key = submissionKey ?? 'sub-${DateTime.now().microsecondsSinceEpoch}';
      final payload = formData.toV2Payload(key);

      final draft = await _owner.createProperty(payload);
      onProgress?.call(0.3);

      if (formData.images.isNotEmpty) {
        final imageFiles = formData.images.map((f) => File(f.path)).toList();
        await _media.uploadImages(draft.id, imageFiles);
      }
      onProgress?.call(0.5);

      if (formData.sitePlan != null) {
        try {
          await _media.uploadSitePlan(draft.id, File(formData.sitePlan!.path));
        } catch (_) {}
      }
      onProgress?.call(0.65);

      if (formData.ownershipProof != null) {
        try {
          await _media.uploadOwnershipProof(draft.id, File(formData.ownershipProof!.path));
        } catch (_) {}
      }
      onProgress?.call(0.8);

      if (formData.videoFile != null) {
        try {
          await _media.uploadVideo(draft.id, File(formData.videoFile!.path));
        } catch (_) {}
      }
      onProgress?.call(0.9);

      await _owner.submit(draft.id);
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Listing submitted successfully for review',
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> updateListing({
    required int listingId,
    required ListingFormData formData,
    void Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.2);
      final payload = formData.toV2Payload('', isUpdate: true);
      await _owner.updateProperty(listingId, payload);
      onProgress?.call(0.4);

      // Delete removed images
      for (final imageId in formData.removedImageIds) {
        try {
          await _media.deleteImage(listingId, imageId);
        } catch (_) {}
      }

      // Upload new images
      if (formData.images.isNotEmpty) {
        final imageFiles = formData.images.map((f) => File(f.path)).toList();
        await _media.uploadImages(listingId, imageFiles);
      }
      onProgress?.call(0.6);

      // Handle site plan removal or update
      if (formData.removeExistingSitePlan) {
        try {
          await _media.deleteSitePlan(listingId);
        } catch (_) {}
      }
      if (formData.sitePlan != null) {
        try {
          await _media.uploadSitePlan(listingId, File(formData.sitePlan!.path));
        } catch (_) {}
      }

      // Handle ownership proof
      if (formData.ownershipProof != null) {
        try {
          await _media.uploadOwnershipProof(listingId, File(formData.ownershipProof!.path));
        } catch (_) {}
      }
      onProgress?.call(0.8);

      // Handle video deletion or update
      if (formData.deleteVideo) {
        try {
          await _media.deleteVideo(listingId);
        } catch (_) {}
      }
      if (formData.videoFile != null) {
        try {
          await _media.uploadVideo(listingId, File(formData.videoFile!.path));
        } catch (_) {}
      }
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Listing updated successfully',
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> deleteListing(int listingId) async {
    try {
      await _owner.delete(listingId);
      return const ListingResponse(
        success: true,
        message: 'Listing deleted successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> vipListing(int listingId) async {
    try {
      await _promo.vip(listingId);
      return const ListingResponse(
        success: true,
        message: 'Listing marked as VIP successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ContactRevealResponse> revealContact(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiV2Constants.listingRevealContact(listingId),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = ApiEnvelope.extractData(response.data);
        return ContactRevealResponse(
          success: true,
          contact: data['contact']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          alreadyRevealed: data['already_revealed'] ?? false,
        );
      }

      return ContactRevealResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to reveal contact'),
      );
    } catch (e) {
      return ContactRevealResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> featureListing(int listingId) async {
    try {
      await _promo.feature(listingId);
      return const ListingResponse(
        success: true,
        message: 'Listing featured successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> unfeatureListing(int listingId) async {
    try {
      await _promo.unfeature(listingId);
      return const ListingResponse(
        success: true,
        message: 'Listing unfeatured successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> unvipListing(int listingId) async {
    try {
      await _promo.unvip(listingId);
      return const ListingResponse(
        success: true,
        message: 'VIP status removed successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<int?> checkSubmissionKey(String submissionKey) async {
    try {
      final response = await _apiClient.dio.get(
        ApiV2Constants.listingCheckKey(submissionKey),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = ApiEnvelope.extractData(response.data);
        return TypeUtils.safeInt(data['listing_id']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class ListingResponse {
  final bool success;
  final String message;
  final List<Listing> listings;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const ListingResponse({
    required this.success,
    this.message = '',
    this.listings = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });

  @override
  String toString() =>
      'ListingResponse(success: $success, listings: ${listings.length})';
}

class ListingDetailResponse {
  final bool success;
  final String message;
  final Listing? listing;
  final SubscriptionGate? subscriptionGate;

  const ListingDetailResponse({
    required this.success,
    this.message = '',
    this.listing,
    this.subscriptionGate,
  });
}

class ContactRevealResponse {
  final bool success;
  final String message;
  final String contact;
  final String name;
  final String email;
  final bool alreadyRevealed;

  const ContactRevealResponse({
    required this.success,
    this.message = '',
    this.contact = '',
    this.name = '',
    this.email = '',
    this.alreadyRevealed = false,
  });
}
