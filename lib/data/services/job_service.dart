import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../models/job_form_data.dart';
import '../models/listing.dart';
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
  final ApiClient _apiClient;
  final CatalogService _catalog;
  final OwnerListingService _owner;
  final PromotionServiceV2 _promo;
  final Map<int, String> _jobCursors = {};
  final Map<int, String> _myJobCursors = {};

  JobService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        _catalog = CatalogService(client: ApiV2Client(apiClient: apiClient)),
        _owner = OwnerListingService(client: ApiV2Client(apiClient: apiClient)),
        _promo = PromotionServiceV2(client: ApiV2Client(apiClient: apiClient));

  Future<ListingResponse> getListings({
    int page = 1,
    int perPage = 15,
    Map<String, dynamic>? filters,
  }) async {
    try {
      if (page <= 1) {
        _jobCursors.clear();
      }
      final cursor = page > 1 ? _jobCursors[page] : null;

      final jobFilters = JobFilters(
        jobCategory: filters?['category']?.toString() ?? filters?['job_category']?.toString(),
        jobType: filters?['job_type']?.toString(),
        location: filters?['location']?.toString(),
        search: filters?['search']?.toString() ?? filters?['q']?.toString(),
      );

      final result = await _catalog.fetchJobs(
        cursor: cursor,
        limit: perPage,
        filters: jobFilters,
      );

      if (result.nextCursor != null) {
        _jobCursors[page + 1] = result.nextCursor!;
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
      if (page <= 1) {
        _myJobCursors.clear();
      }
      final cursor = page > 1 ? _myJobCursors[page] : null;

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
        type: ListingKind.job,
        status: oStatus,
      );

      if (result.nextCursor != null) {
        _myJobCursors[page + 1] = result.nextCursor!;
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

  Future<ListingResponse> getFeaturedListings({int page = 1, int limit = 10}) async {
    try {
      final items = await _catalog.fetchFeaturedJobs(limit: limit);
      final listings = items.map((s) => s.toListing()).toList();

      return ListingResponse(
        success: true,
        listings: listings,
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
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
      return ListingDetailResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> getSimilarListings(int listingId) async {
    try {
      // V2 backend does not expose /jobs/{id}/similar — fall back to V1.
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/jobs/$listingId/similar',
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
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch similar jobs'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
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
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
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
      final payload = formData.toV2Payload('', isUpdate: true);
      await _owner.updateJob(listingId, payload);
      onProgress?.call(1.0);

      return const ListingResponse(
        success: true,
        message: 'Job updated successfully',
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
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
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> featureListing(int id) async {
    try {
      await _promo.feature(id);
      return const ListingResponse(success: true, message: 'Featured');
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ListingResponse> unfeatureListing(int id) async {
    try {
      await _promo.unfeature(id);
      return const ListingResponse(success: true, message: 'Unfeatured');
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<ContactRevealResponse> revealContact(int id) async {
    try {
      // V2 backend does not expose /jobs/{id}/reveal-contact — fall back to V1.
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/jobs/$id/reveal-contact',
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
      return ContactRevealResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<int?> checkSubmissionKey(String key) async {
    return null;
  }
}
