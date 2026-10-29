import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/listing_detail.dart';
import '../../models/v2/listing_summary.dart';
import 'catalog_filters.dart';

/// Read-only catalog calls for listings, cars and jobs.
class CatalogService {
  final ApiV2Client _client;

  CatalogService({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<Paginated<ListingSummary>> fetchListings({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
    ListingFilters filters = const ListingFilters(),
  }) {
    return _client.getCollection(
      ApiV2Constants.listings,
      parse: ListingSummary.fromJson,
      query: _pageQuery(cursor, limit, filters.toQuery()),
    );
  }

  Future<ListingDetail> fetchListing(int id) async {
    final data = await _client.getItem(ApiV2Constants.listing(id));
    return ListingDetail.fromJson(data);
  }

  Future<List<ListingSummary>> fetchFeaturedListings({int limit = 12}) {
    return _client.getCollection(
      ApiV2Constants.listingsFeatured,
      parse: ListingSummary.fromJson,
      query: {'limit': _clampLimit(limit)},
    ).then((page) => page.items);
  }

  Future<Paginated<ListingSummary>> fetchCars({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
    CarFilters filters = const CarFilters(),
  }) {
    return _client.getCollection(
      ApiV2Constants.cars,
      parse: ListingSummary.fromJson,
      query: _pageQuery(cursor, limit, filters.toQuery()),
    );
  }

  Future<ListingDetail> fetchCar(int id) async {
    final data = await _client.getItem(ApiV2Constants.car(id));
    return ListingDetail.fromJson(data);
  }

  Future<List<ListingSummary>> fetchFeaturedCars({int limit = 12}) {
    return _client.getCollection(
      ApiV2Constants.carsFeatured,
      parse: ListingSummary.fromJson,
      query: {'limit': _clampLimit(limit)},
    ).then((page) => page.items);
  }

  Future<Paginated<ListingSummary>> fetchJobs({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
    JobFilters filters = const JobFilters(),
  }) {
    return _client.getCollection(
      ApiV2Constants.jobs,
      parse: ListingSummary.fromJson,
      query: _pageQuery(cursor, limit, filters.toQuery()),
    );
  }

  Future<ListingDetail> fetchJob(int id) async {
    final data = await _client.getItem(ApiV2Constants.job(id));
    return ListingDetail.fromJson(data);
  }

  Future<List<ListingSummary>> fetchFeaturedJobs({int limit = 12}) {
    return _client.getCollection(
      ApiV2Constants.jobsFeatured,
      parse: ListingSummary.fromJson,
      query: {'limit': _clampLimit(limit)},
    ).then((page) => page.items);
  }

  static Map<String, dynamic> _pageQuery(
    String? cursor,
    int limit,
    Map<String, dynamic> filters,
  ) {
    return {
      ...filters,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'limit': _clampLimit(limit),
    };
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit
        ? ApiV2Constants.maxLimit
        : limit;
  }
}
