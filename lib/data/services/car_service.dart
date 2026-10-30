import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../models/car_form_data.dart';
import '../models/listing.dart';
import '../models/v2/listing_summary.dart';
import '../models/v2/owner_listing.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'listing_service.dart';
import 'v2/catalog_filters.dart';
import 'v2/catalog_service.dart';
import 'v2/listing_media_service.dart';
import 'v2/owner_listing_service.dart';
import 'v2/promotion_service.dart';

/// Service for managing vehicle listings backed by V2 API.
class CarService {
  final ApiClient _apiClient;
  final CatalogService _catalog;
  final OwnerListingService _owner;
  final ListingMediaServiceV2 _media;
  final PromotionServiceV2 _promo;

  CarService({ApiClient? apiClient})
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
      final carFilters = CarFilters(
        listingType: filters?['listing_type']?.toString(),
        location: filters?['location']?.toString() ?? filters?['city']?.toString(),
        make: filters?['make']?.toString(),
        model: filters?['model']?.toString(),
        bodyType: filters?['body_type']?.toString(),
        transmission: filters?['transmission']?.toString(),
        fuelType: filters?['fuel_type']?.toString(),
        condition: filters?['condition']?.toString(),
        vehicleCategory: filters?['vehicle_category']?.toString(),
      );

      final result = await _catalog.fetchCars(
        limit: perPage,
        filters: carFilters,
      );

      final listings = result.items.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: listings.length,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> getMyListings({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    try {
      final oStatus = switch (status?.toLowerCase()) {
        'active' => OwnerListingStatus.active,
        'pending' => OwnerListingStatus.pending,
        'rejected' => OwnerListingStatus.rejected,
        'frozen' => OwnerListingStatus.frozen,
        'draft' => OwnerListingStatus.draft,
        _ => null,
      };

      final result = await _owner.fetch(
        limit: perPage,
        type: ListingKind.car,
        status: oStatus,
      );

      final listings = result.items.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: listings.length,
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
      final items = await _catalog.fetchFeaturedCars(limit: limit);
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
      final detail = await _catalog.fetchCar(listingId);
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

  Future<ListingResponse> getSimilarListings(int listingId) async {
    try {
      // V2 backend does not expose /cars/{id}/similar — fall back to V1.
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/cars/$listingId/similar',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final dataList = ApiEnvelope.extractList(
          data,
          itemKeys: const ['listings', 'items'],
        );
        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();

        return ListingResponse(
          success: true,
          listings: listings,
        );
      }

      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch similar cars'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> createListing({
    required CarFormData formData,
    String? submissionKey,
    void Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);
      final key = submissionKey ?? 'car-${DateTime.now().microsecondsSinceEpoch}';
      final payload = formData.toV2Payload(key);

      final draft = await _owner.createCar(payload);
      onProgress?.call(0.5);

      if (formData.images.isNotEmpty) {
        final imageFiles = formData.images.map((f) => File(f.path)).toList();
        await _media.uploadImages(draft.id, imageFiles);
      }
      onProgress?.call(0.8);

      await _owner.submit(draft.id);
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Vehicle listing submitted for review',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> updateListing({
    required int listingId,
    required CarFormData formData,
    void Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.3);
      final payload = formData.toV2Payload('');
      await _owner.updateCar(listingId, payload);
      onProgress?.call(0.7);

      if (formData.images.isNotEmpty) {
        final imageFiles = formData.images.map((f) => File(f.path)).toList();
        await _media.uploadImages(listingId, imageFiles);
      }
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Vehicle updated successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> deleteListing(int listingId) async {
    try {
      await _owner.delete(listingId);
      return const ListingResponse(
        success: true,
        message: 'Vehicle listing deleted successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> featureListing(int listingId) async {
    try {
      await _promo.feature(listingId);
      return const ListingResponse(success: true, message: 'Featured');
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
      return const ListingResponse(success: true, message: 'Unfeatured');
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
      return const ListingResponse(success: true, message: 'VIP enabled');
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
      return const ListingResponse(success: true, message: 'VIP disabled');
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
      // V2 backend does not expose /cars/{id}/reveal-contact — fall back to V1.
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId/reveal-contact',
      );

      if (response.statusCode == 200) {
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
      final exception = ApiErrorHandler.handle(e);
      return ContactRevealResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<int?> checkSubmissionKey(String submissionKey) async {
    return null;
  }
}
