import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';

/// Service for managing favorite listings
class FavoriteService {
  final ApiClient _apiClient;

  FavoriteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<FavoriteResponse> getFavorites({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.favorites,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
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

        final pagination = ApiEnvelope.extractPagination(data, fallbackPage: page);

        return FavoriteResponse(
          success: true,
          listings: listings,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }

      return FavoriteResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch favorites'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<FavoriteResponse> toggleFavorite(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.toggleFavorite}/$listingId/toggle',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final added = (data is Map) ? (data['added'] ?? false) : false;

        return FavoriteResponse(
          success: true,
          message: ApiEnvelope.extractMessage(data, 'Favorite toggled'),
          isFavorite: added,
        );
      }

      return FavoriteResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to toggle favorite'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

class FavoriteResponse {
  final bool success;
  final String message;
  final List<Listing> listings;
  final int? currentPage;
  final int? totalPages;
  final int? total;
  final bool? isFavorite;

  const FavoriteResponse({
    required this.success,
    this.message = '',
    this.listings = const [],
    this.currentPage,
    this.totalPages,
    this.total,
    this.isFavorite,
  });

  @override
  String toString() =>
      'FavoriteResponse(success: $success, listings: ${listings.length})';
}
