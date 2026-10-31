import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../models/listing.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/favorite_service.dart';

/// Service for managing favorite listings backed by V2 API.
class FavoriteService {
  final FavoriteServiceV2 _v2;
  final Map<int, String> _cursors = {};

  FavoriteService({ApiClient? apiClient, FavoriteServiceV2? v2Service})
      : _v2 = v2Service ??
            FavoriteServiceV2(
              client:
                  apiClient != null ? ApiV2Client(apiClient: apiClient) : null,
            );

  Future<FavoriteResponse> getFavorites({
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      if (page <= 1) {
        _cursors.clear();
      }
      final cursor = page > 1 ? _cursors[page] : null;
      final result = await _v2.fetch(cursor: cursor, limit: perPage);
      if (result.nextCursor != null) {
        _cursors[page + 1] = result.nextCursor!;
      }
      final listings = result.items.map((s) => s.toListing()).toList();

      return FavoriteResponse(
        success: true,
        listings: listings,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: listings.length,
      );
    } catch (e) {
      return FavoriteResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<FavoriteResponse> toggleFavorite(int listingId, {bool? currentlyFavorite}) async {
    try {
      final shouldRemove = currentlyFavorite ?? false;
      final state = shouldRemove
          ? await _v2.unfavorite(listingId)
          : await _v2.favorite(listingId);

      return FavoriteResponse(
        success: true,
        message: state.favorited ? 'Added to favorites' : 'Removed from favorites',
        isFavorite: state.favorited,
      );
    } catch (e) {
      return FavoriteResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
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
      'FavoriteResponse(success: $success, listings: ${listings.length}, isFavorite: $isFavorite)';
}
