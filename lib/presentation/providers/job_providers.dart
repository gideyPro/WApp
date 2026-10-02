import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/job_service.dart';
import '../../data/services/listing_service.dart';
import '../../data/models/listing.dart';
import 'listing_provider.dart';

final jobServiceProvider = Provider<JobService>((ref) {
  return JobService();
});

final jobListingsProvider = StateNotifierProvider<JobListingsNotifier, ListingsState>((ref) {
  return JobListingsNotifier(ref.watch(jobServiceProvider));
});

final jobDetailProvider = StateNotifierProvider<JobDetailNotifier, ListingDetailState>((ref) {
  return JobDetailNotifier(ref.watch(jobServiceProvider));
});

final similarJobsProvider = FutureProvider.family<ListingResponse, int>((ref, listingId) {
  return ref.watch(jobServiceProvider).getSimilarListings(listingId);
});

class JobListingsNotifier extends StateNotifier<ListingsState> {
  final JobService _jobService;

  JobListingsNotifier(this._jobService) : super(const ListingsState.initial());

  Future<void> loadListings({int page = 1, Map<String, dynamic>? filters}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final response = await _jobService.getListings(
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
    } else {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: response.message,
      );
    }
  }

  void reset() {
    state = const ListingsState.initial();
  }
}

class JobDetailNotifier extends StateNotifier<ListingDetailState> {
  final JobService _jobService;

  JobDetailNotifier(this._jobService) : super(const ListingDetailState.initial());

  Future<void> loadListing(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _jobService.getListingDetail(id);
    if (response.success && response.listing != null) {
      state = ListingDetailState.loaded(response.listing!);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
        requiresSubscription: response.subscriptionGate?.required ?? false,
      );
    }
  }

  Future<void> refreshListing(int id) async {
    final response = await _jobService.getListingDetail(id);
    if (response.success && response.listing != null) {
      state = ListingDetailState.loaded(response.listing!);
    }
  }

  void updateListingInline(Listing listing) {
    state = ListingDetailState.loaded(listing);
  }

  Future<String?> featureListing(int id) async {
    if (state.listing != null) {
      updateListingInline(state.listing!.copyWith(isFeatured: true));
    }
    final response = await _jobService.featureListing(id);
    if (!response.success) {
      refreshListing(id);
      return response.message;
    }
    refreshListing(id);
    return null;
  }

  Future<String?> unfeatureListing(int id) async {
    if (state.listing != null) {
      updateListingInline(state.listing!.copyWith(isFeatured: false));
    }
    final response = await _jobService.unfeatureListing(id);
    if (!response.success) {
      refreshListing(id);
      return response.message;
    }
    refreshListing(id);
    return null;
  }

  Future<Map<String, dynamic>?> revealContact(int id) async {
    if (state.listing == null) return null;
    final response = await _jobService.revealContact(id);
    if (response.success) {
      final updated = state.listing!.copyWith(
        contactRevealed: true,
        revealedName: response.name,
        revealedContact: response.contact,
      );
      state = ListingDetailState.loaded(updated);
      return {'name': response.name, 'contact': response.contact};
    }
    return null;
  }
}
