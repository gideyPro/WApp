import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/services/listing_service.dart';
import '../../data/models/listing.dart';

/// Listing Service Provider
final listingServiceProvider = Provider<ListingService>((ref) {
  return ListingService();
});

/// All listings with pagination (Home Screen)
final listingsProvider = StateNotifierProvider<ListingsNotifier, ListingsState>((ref) {
  return ListingsNotifier(ref.watch(listingServiceProvider));
});

/// Search results provider (Search Screen)
final searchResultsProvider = StateNotifierProvider.autoDispose<ListingsNotifier, ListingsState>((ref) {
  return ListingsNotifier(ref.watch(listingServiceProvider));
});

/// Featured listings
final featuredListingsProvider = StateNotifierProvider<FeaturedListingsNotifier, ListingsState>((ref) {
  return FeaturedListingsNotifier(ref.watch(listingServiceProvider));
});

/// Single listing detail
final listingDetailProvider = StateNotifierProvider<ListingDetailNotifier, ListingDetailState>((ref) {
  return ListingDetailNotifier(ref.watch(listingServiceProvider));
});

/// Similar listings
final similarListingsProvider = FutureProvider.family<ListingResponse, int>((ref, listingId) {
  return ref.watch(listingServiceProvider).getSimilarListings(listingId);
});

class ListingsNotifier extends StateNotifier<ListingsState> {
  final ListingService _listingService;

  ListingsNotifier(this._listingService) : super(const ListingsState.initial());

  Future<void> loadListings({int page = 1, Map<String, dynamic>? filters}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final response = await _listingService.getListings(
      page: page,
      filters: filters,
    );

    if (response.success) {
      final newListings = page == 1
          ? response.listings
          : [...state.listings, ...response.listings];

      state = ListingsState.loaded(
        listings: newListings,
        currentPage: response.currentPage ?? page,
        totalPages: response.totalPages ?? 1,
        total: response.total ?? 0,
        hasMore: (response.currentPage ?? page) < (response.totalPages ?? 1),
      );

      // Cache page 1 results for offline fallback
      if (page == 1 && newListings.isNotEmpty) {
        _cacheListings(newListings, response.total ?? 0);
      }
    } else {
      // Try loading from cache on error
      if (page == 1 && state.listings.isEmpty) {
        final cached = await _loadCachedListings();
        if (cached != null) {
          state = ListingsState.loaded(
            listings: cached,
            total: cached.length,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: response.message,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: response.message,
        );
      }
    }
  }

  Future<void> _cacheListings(List<Listing> listings, int total) async {
    try {
      final box = await Hive.openBox('listings_cache');
      await box.put('all_listings', jsonEncode(listings.map((l) => l.toJson()).toList()));
      await box.put('all_listings_total', total);
    } catch (_) {}
  }

  Future<List<Listing>?> _loadCachedListings() async {
    try {
      final box = await Hive.openBox('listings_cache');
      final raw = box.get('all_listings');
      if (raw == null) return null;
      final List<dynamic> decoded = jsonDecode(raw as String);
      return decoded
          .map((e) => Listing.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}

class FeaturedListingsNotifier extends StateNotifier<ListingsState> {
  final ListingService _listingService;

  FeaturedListingsNotifier(this._listingService)
      : super(const ListingsState.initial());

  Future<void> loadFeaturedListings({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _listingService.getFeaturedListings(
      page: page,
    );

    if (response.success) {
      state = ListingsState.loaded(
        listings: response.listings,
        currentPage: response.currentPage ?? page,
        totalPages: response.totalPages ?? 1,
        total: response.total ?? 0,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }
}

class ListingDetailNotifier extends StateNotifier<ListingDetailState> {
  final ListingService _listingService;

  ListingDetailNotifier(this._listingService)
      : super(const ListingDetailState.initial());

  Future<void> loadListing(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _listingService.getListingDetail(id);

    if (response.success && response.listing != null) {
      state = ListingDetailState.loaded(response.listing!);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }
}

class ListingsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Listing> listings;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;
  final String? errorMessage;

  const ListingsState({
    required this.isLoading,
    this.isLoadingMore = false,
    this.listings = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasMore = false,
    this.errorMessage,
  });

  const ListingsState.initial()
      : isLoading = true,
        isLoadingMore = false,
        listings = const [],
        currentPage = 1,
        totalPages = 1,
        total = 0,
        hasMore = false,
        errorMessage = null;

  const ListingsState.loaded({
    required this.listings,
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  ListingsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Listing>? listings,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ListingsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      listings: listings ?? this.listings,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

class ListingDetailState {
  final bool isLoading;
  final Listing? listing;
  final String? errorMessage;

  const ListingDetailState({
    required this.isLoading,
    this.listing,
    this.errorMessage,
  });

  const ListingDetailState.initial()
      : isLoading = true,
        listing = null,
        errorMessage = null;

  const ListingDetailState.loaded(this.listing)
      : isLoading = false,
        errorMessage = null;

  ListingDetailState copyWith({
    bool? isLoading,
    Listing? listing,
    String? errorMessage,
  }) {
    return ListingDetailState(
      isLoading: isLoading ?? this.isLoading,
      listing: listing ?? this.listing,
      errorMessage: errorMessage,
    );
  }
}
