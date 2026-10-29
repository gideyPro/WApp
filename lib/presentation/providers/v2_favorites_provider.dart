import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/listing_summary.dart';
import '../../data/services/v2/favorite_service.dart';
import 'v2_providers.dart';

/// Cursor-paginated favorites for the v2 favorites screen.
final favoritesV2Provider =
    StateNotifierProvider<FavoritesV2Notifier, FavoritesV2State>((ref) {
  return FavoritesV2Notifier(ref.watch(favoriteV2ServiceProvider));
});

class FavoritesV2Notifier extends StateNotifier<FavoritesV2State> {
  final FavoriteServiceV2 _service;

  FavoritesV2Notifier(this._service) : super(const FavoritesV2State.initial());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _service.fetch();
      state = FavoritesV2State.loaded(
        favorites: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load favorites',
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;

    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _service.fetch(cursor: cursor);
      state = state.copyWith(
        favorites: [...state.favorites, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more favorites',
      );
    }
  }

  /// Remove a favorite. The backend treats a repeat as success, but the row is
  /// already gone from this list, so it is not called twice by the screen.
  Future<bool> remove(int listingId) async {
    try {
      final result = await _service.unfavorite(listingId);
      if (!result.favorited) {
        state = state.copyWith(
          favorites: state.favorites
              .where((favorite) => favorite.id != listingId)
              .toList(),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

class FavoritesV2State {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ListingSummary> favorites;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  const FavoritesV2State({
    required this.isLoading,
    this.isLoadingMore = false,
    this.favorites = const [],
    this.nextCursor,
    this.hasMore = false,
    this.errorMessage,
  });

  const FavoritesV2State.initial()
      : isLoading = true,
        isLoadingMore = false,
        favorites = const [],
        nextCursor = null,
        hasMore = false,
        errorMessage = null;

  const FavoritesV2State.loaded({
    required this.favorites,
    this.nextCursor,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  /// Favorites are fetched page by page, so the loaded count is the total the
  /// screen can currently show.
  int get total => favorites.length;

  FavoritesV2State copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ListingSummary>? favorites,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
  }) {
    return FavoritesV2State(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      favorites: favorites ?? this.favorites,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}
