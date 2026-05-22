import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';

/// Service for managing favorite listings
class FavoriteService {
  final ApiClient _apiClient;

  FavoriteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's favorite listings
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
        final dataMap = (data is Map) ? data : {};
        
        final dataList = _extractList(data);

        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();

        // Safely parse pagination fields
        int currentPage = _safeInt(dataMap['current_page']) ?? page;
        int totalPages = _safeInt(dataMap['last_page']) ?? 1;
        int total = _safeInt(dataMap['total']) ?? 0;

        return FavoriteResponse(
          success: true,
          listings: listings,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return FavoriteResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch favorites'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Safely convert dynamic value to int
  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Add listing to favorites
  Future<FavoriteResponse> addFavorite(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.addFavorite}/$listingId',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FavoriteResponse(
          success: true,
          message: _extractMessage(response.data, 'Added to favorites'),
        );
      }

      return FavoriteResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to add favorite'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Remove listing from favorites
  Future<FavoriteResponse> removeFavorite(int listingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.removeFavorite}/$listingId',
      );

      if (response.statusCode == 200) {
        return FavoriteResponse(
          success: true,
          message: _extractMessage(response.data, 'Removed from favorites'),
        );
      }

      return FavoriteResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to remove favorite'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Toggle favorite status
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
          message: _extractMessage(data, 'Favorite toggled'),
          isFavorite: added,
        );
      }

      return FavoriteResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to toggle favorite'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FavoriteResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Helper to extract list from dynamic response
  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'] ?? raw['listings'] ?? raw['items'];
      if (data is List) return data;
      if (data is Map) return data.values.toList();
    }
    return [];
  }

  /// Helper to extract message from dynamic response
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map && raw['message'] != null) {
      return raw['message'].toString();
    }
    return defaultMessage;
  }
}

/// Response wrapper for favorite operations
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
