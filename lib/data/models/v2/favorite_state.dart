import '../../../core/utils/type_utils.dart';

/// Result of favoriting or unfavoriting a listing.
class FavoriteState {
  final int listingId;
  final bool favorited;
  final int favoritesCount;

  const FavoriteState({
    required this.listingId,
    required this.favorited,
    this.favoritesCount = 0,
  });

  factory FavoriteState.fromJson(Map<String, dynamic> json) {
    return FavoriteState(
      listingId: TypeUtils.safeInt(json['listing_id']) ?? 0,
      favorited: TypeUtils.safeBool(json['favorited']),
      favoritesCount: TypeUtils.safeInt(json['favorites_count']) ?? 0,
    );
  }
}
