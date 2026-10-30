import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../../core/network/v2/api_v2_constants.dart';
import '../models/job_form_data.dart';
import '../models/v2/listing_summary.dart';
import '../models/v2/owner_listing.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'listing_service.dart';
import 'v2/catalog_filters.dart';
import 'v2/catalog_service.dart';
import 'v2/owner_listing_service.dart';
import 'v2/promotion_service.dart';

/// Service for managing job listings backed by V2 API.
class JobService {
  final ApiV2Client _v2Client;
  final CatalogService _catalog;
  final OwnerListingService _owner;
  final PromotionServiceV2 _promo;

  JobService({ApiClient? apiClient})
      : _v2Client = ApiV2Client(apiClient: apiClient),
        _catalog = CatalogService(client: ApiV2Client(apiClient: apiClient)),
        _owner = OwnerListingService(client: ApiV2Client(apiClient: apiClient)),
        _promo = PromotionServiceV2(client: ApiV2Client(apiClient: apiClient));

  Future<ListingResponse> getListings({
    int page = 1,
    int perPage = 15,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final jobFilters = JobFilters(
        jobCategory: filters?['category']?.toString() ?? filters?['job_category']?.toString(),
        jobType: filters?['job_type']?.toString(),
        location: filters?['location']?.toString(),
        search: filters?['search']?.toString() ?? filters?['q']?.toString(),
      );

      final result = await _catalog.fetchJobs(
        limit: perPage,
        filters: jobFilters,
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
        type: ListingKind.job,
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
      final items = await _catalog.fetchFeaturedJobs(limit: limit);
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
      final detail = await _catalog.fetchJob(listingId);
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
      final result = await _v2Client.getCollection(
        '${ApiV2Constants.jobs}/$listingId/similar',
        parse: ListingSummary.fromJson,
      );
      final listings = result.items.map((s) => s.toListing()).toList();

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

  Future<ListingResponse> createListing({
    required JobFormData formData,
    String? submissionKey,
    void Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.2);
      final key = submissionKey ?? 'job-${DateTime.now().microsecondsSinceEpoch}';
      final payload = formData.toV2Payload(key);

      final draft = await _owner.createJob(payload);
      onProgress?.call(0.6);

      await _owner.submit(draft.id);
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Job listing submitted for review',
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
    required JobFormData formData,
    void Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.4);
      final payload = formData.toV2Payload('');
      await _owner.updateJob(listingId, payload);
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Job updated successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> deleteListing(int id) async {
    try {
      await _owner.delete(id);
      return const ListingResponse(
        success: true,
        message: 'Job listing deleted successfully',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> featureListing(int id) async {
    try {
      await _promo.feature(id);
      return const ListingResponse(success: true, message: 'Featured');
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> unfeatureListing(int id) async {
    try {
      await _promo.unfeature(id);
      return const ListingResponse(success: true, message: 'Unfeatured');
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ContactRevealResponse> revealContact(int id) async {
    try {
      final data = await _v2Client.sendItem(
        '${ApiV2Constants.listings}/$id/reveal-contact',
        method: 'POST',
      );

      return ContactRevealResponse(
        success: true,
        contact: data['contact']?.toString() ?? data['phone']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        alreadyRevealed: data['already_revealed'] ?? false,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ContactRevealResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<int?> checkSubmissionKey(String key) async {
    return null;
  }
}
