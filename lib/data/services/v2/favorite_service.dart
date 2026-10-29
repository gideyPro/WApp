import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/favorite_state.dart';
import '../../models/v2/listing_summary.dart';

/// The viewer's favorites plus the idempotent add/remove mutations.
class FavoriteServiceV2 {
  final ApiV2Client _client;

  FavoriteServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<Paginated<ListingSummary>> fetch({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    return _client.getCollection(
      ApiV2Constants.favorites,
      parse: ListingSummary.fromJson,
      query: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<FavoriteState> favorite(int listingId) async {
    final data = await _client.sendItem(
      ApiV2Constants.favorite(listingId),
      method: 'POST',
    );

    return FavoriteState.fromJson(data);
  }

  Future<FavoriteState> unfavorite(int listingId) async {
    final data = await _client.sendItem(
      ApiV2Constants.favorite(listingId),
      method: 'DELETE',
    );

    return FavoriteState.fromJson(data);
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit
        ? ApiV2Constants.maxLimit
        : limit;
  }
}
