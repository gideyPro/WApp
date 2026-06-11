import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/favorite_service.dart';
import '../../data/services/lead_service.dart';
import 'auth_providers.dart';

/// Favorite Provider
final favoriteServiceProvider =
    Provider<FavoriteService>((ref) => FavoriteService());
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(favoriteServiceProvider), ref);
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteService _favoriteService;
  final Ref _ref;
  FavoritesNotifier(this._favoriteService, this._ref)
      : super(const FavoritesState.initial());

  Future<void> loadFavorites({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _favoriteService.getFavorites(page: page);
    if (response.success) {
      state = FavoritesState.loaded(
        favorites: response.listings,
        total: response.total ?? 0,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> toggleFavorite(int listingId) async {
    final response = await _favoriteService.toggleFavorite(listingId);
    if (response.success) {
      await loadFavorites();
      await _ref.read(profileProvider.notifier).loadProfile();
    }
    return response.success;
  }
}

class FavoritesState {
  final bool isLoading;
  final List<dynamic> favorites;
  final int total;
  final String? errorMessage;
  const FavoritesState(
      {required this.isLoading,
      this.favorites = const [],
      this.total = 0,
      this.errorMessage});
  const FavoritesState.initial()
      : isLoading = true,
        favorites = const [],
        total = 0,
        errorMessage = null;
  const FavoritesState.loaded({required this.favorites, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  FavoritesState copyWith(
      {bool? isLoading,
      List<dynamic>? favorites,
      int? total,
      String? errorMessage}) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }
}

/// Lead (Interest) Provider
final leadServiceProvider =
    Provider<LeadService>((ref) => LeadService());
final myInterestsProvider =
    StateNotifierProvider<MyInterestsNotifier, MyInterestsState>((ref) {
  return MyInterestsNotifier(ref.watch(leadServiceProvider));
});

class MyInterestsNotifier extends StateNotifier<MyInterestsState> {
  final LeadService _leadService;
  MyInterestsNotifier(this._leadService)
      : super(const MyInterestsState.initial());

  Future<void> loadInterests({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _leadService.getMyInterests(page: page);
    if (response.success) {
      state = MyInterestsState.loaded(
          interests: response.leads, total: response.leads.length);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> expressInterest(int listingId, {String? message}) async {
    final response = await _leadService.expressInterest(
        listingId: listingId, message: message);
    if (response.success) await loadInterests();
    return response.success;
  }
}

class MyInterestsState {
  final bool isLoading;
  final List<dynamic> interests;
  final int total;
  final String? errorMessage;
  const MyInterestsState(
      {required this.isLoading,
      this.interests = const [],
      this.total = 0,
      this.errorMessage});
  const MyInterestsState.initial()
      : isLoading = true,
        interests = const [],
        total = 0,
        errorMessage = null;
  const MyInterestsState.loaded({required this.interests, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  MyInterestsState copyWith(
      {bool? isLoading,
      List<dynamic>? interests,
      int? total,
      String? errorMessage}) {
    return MyInterestsState(
        isLoading: isLoading ?? this.isLoading,
        interests: interests ?? this.interests,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}
