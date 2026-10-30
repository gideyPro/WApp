import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_client.dart';
import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/app_config.dart';
import '../../data/models/v2/help_content.dart';
import '../../data/models/v2/home_feed.dart';
import '../../data/models/v2/listing_detail.dart';
import '../../data/models/v2/listing_summary.dart';
import '../../data/models/v2/owner_listing.dart';
import '../../data/models/v2/subscription_state.dart';
import '../../data/services/v2/address_service.dart';
import '../../data/services/v2/app_config_service.dart';
import '../../data/services/v2/auth_service.dart';
import '../../data/services/v2/catalog_service.dart';
import '../../data/services/v2/conference_service.dart';
import '../../data/services/v2/conversation_service.dart';
import '../../data/services/v2/favorite_service.dart';
import '../../data/services/v2/help_service.dart';
import '../../data/services/v2/home_service.dart';
import '../../data/services/v2/kyc_service.dart';
import '../../data/services/v2/listing_media_service.dart';
import '../../data/services/v2/notification_service.dart';
import '../../data/services/v2/order_service.dart';
import '../../data/services/v2/owner_listing_service.dart';
import '../../data/services/v2/payment_service.dart';
import '../../data/services/v2/plan_service.dart';
import '../../data/services/v2/profile_service.dart';
import '../../data/services/v2/promotion_service.dart';
import '../../data/services/v2/subscription_service.dart';
import 'app_providers.dart';

/// Transport shared by every v2 service. Reuses [apiClientProvider] so v1 and
/// v2 requests share authentication, locale and 401 handling.
final apiV2ClientProvider = Provider<ApiV2Client>((ref) {
  return ApiV2Client(apiClient: ref.watch(apiClientProvider));
});

final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return AppConfigService(client: ref.watch(apiV2ClientProvider));
});

final catalogServiceProvider = Provider<CatalogService>((ref) {
  return CatalogService(client: ref.watch(apiV2ClientProvider));
});

final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService(client: ref.watch(apiV2ClientProvider));
});

final subscriptionV2ServiceProvider = Provider<SubscriptionServiceV2>((ref) {
  return SubscriptionServiceV2(client: ref.watch(apiV2ClientProvider));
});

final paymentV2ServiceProvider = Provider<PaymentServiceV2>((ref) {
  return PaymentServiceV2(client: ref.watch(apiV2ClientProvider));
});

final kycV2ServiceProvider = Provider<KycServiceV2>((ref) {
  return KycServiceV2(client: ref.watch(apiV2ClientProvider));
});

final helpV2ServiceProvider = Provider<HelpServiceV2>((ref) {
  return HelpServiceV2(client: ref.watch(apiV2ClientProvider));
});

final orderV2ServiceProvider = Provider<OrderServiceV2>((ref) {
  return OrderServiceV2(client: ref.watch(apiV2ClientProvider));
});

final conversationV2ServiceProvider = Provider<ConversationServiceV2>((ref) {
  return ConversationServiceV2(client: ref.watch(apiV2ClientProvider));
});

final conferenceV2ServiceProvider = Provider<ConferenceServiceV2>((ref) {
  return ConferenceServiceV2(client: ref.watch(apiV2ClientProvider));
});

final authV2ServiceProvider = Provider<AuthServiceV2>((ref) {
  return AuthServiceV2(client: ref.watch(apiV2ClientProvider));
});

final profileV2ServiceProvider = Provider<ProfileServiceV2>((ref) {
  return ProfileServiceV2(client: ref.watch(apiV2ClientProvider));
});

final favoriteV2ServiceProvider = Provider<FavoriteServiceV2>((ref) {
  return FavoriteServiceV2(client: ref.watch(apiV2ClientProvider));
});

final notificationV2ServiceProvider = Provider<NotificationServiceV2>((ref) {
  return NotificationServiceV2(client: ref.watch(apiV2ClientProvider));
});

final addressV2ServiceProvider = Provider<AddressServiceV2>((ref) {
  return AddressServiceV2(client: ref.watch(apiV2ClientProvider));
});

final ownerListingServiceProvider = Provider<OwnerListingService>((ref) {
  return OwnerListingService(client: ref.watch(apiV2ClientProvider));
});

/// Cursor-paginated owner listings for the my-listings screen.
///
/// Filtered by [ListingKind] and [OwnerListingStatus]; exposes moderation
/// state and owner affordances (edit/submit/delete/promote).
final myListingsV2Provider = StateNotifierProvider.family<MyListingsV2Notifier,
    MyListingsV2State, OwnerListingStatusFilter>((ref, filter) {
  return MyListingsV2Notifier(
    ref.watch(ownerListingServiceProvider),
    filter,
  );
});

class MyListingsV2Notifier extends StateNotifier<MyListingsV2State> {
  final OwnerListingService _service;
  final OwnerListingStatusFilter _filter;

  MyListingsV2Notifier(this._service, this._filter)
      : super(const MyListingsV2State.initial());

  Future<void> loadMyListings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _service.fetch(
        cursor: null,
        type: _filter.type,
        status: _filter.status,
      );
      state = MyListingsV2State.loaded(
        listings: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load your listings',
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
      final page = await _service.fetch(
        cursor: cursor,
        type: _filter.type,
        status: _filter.status,
      );
      state = state.copyWith(
        listings: [...state.listings, ...page.items],
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
        errorMessage: 'Could not load more listings',
      );
    }
  }

  /// Submit a listing for moderation. On success, refreshes the feed.
  Future<bool> submit(int listingId) async {
    try {
      await _service.submit(listingId);
      await loadMyListings();
      return true;
    } on ApiV2Exception catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Delete a listing. On success, removes it from the feed.
  Future<bool> delete(int listingId) async {
    try {
      await _service.delete(listingId);
      state = state.copyWith(
        listings:
            state.listings.where((listing) => listing.id != listingId).toList(),
      );
      return true;
    } on ApiV2Exception catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Replace one row with updated server state (e.g. after edit/submit).
  void refreshListing(OwnerListing updated) {
    state = state.copyWith(
      listings: state.listings
          .map((listing) => listing.id == updated.id ? updated : listing)
          .toList(),
    );
  }
}

/// Filter combination for my-listings tabs.
class OwnerListingStatusFilter {
  final ListingKind? type;
  final OwnerListingStatus? status;

  const OwnerListingStatusFilter({
    this.type,
    this.status,
  });

  factory OwnerListingStatusFilter.all() => const OwnerListingStatusFilter();
  factory OwnerListingStatusFilter.active() =>
      const OwnerListingStatusFilter(status: OwnerListingStatus.active);
  factory OwnerListingStatusFilter.pending() =>
      const OwnerListingStatusFilter(status: OwnerListingStatus.pending);
  factory OwnerListingStatusFilter.frozen() =>
      const OwnerListingStatusFilter(status: OwnerListingStatus.frozen);
  factory OwnerListingStatusFilter.rejected() =>
      const OwnerListingStatusFilter(status: OwnerListingStatus.rejected);
  factory OwnerListingStatusFilter.draft() =>
      const OwnerListingStatusFilter(status: OwnerListingStatus.draft);

  factory OwnerListingStatusFilter.cars({OwnerListingStatus? status}) =>
      OwnerListingStatusFilter(type: ListingKind.car, status: status);
  factory OwnerListingStatusFilter.jobs({OwnerListingStatus? status}) =>
      OwnerListingStatusFilter(type: ListingKind.job, status: status);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OwnerListingStatusFilter &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(type, status);
}

class MyListingsV2State {
  final bool isLoading;
  final bool isLoadingMore;
  final List<OwnerListing> listings;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  const MyListingsV2State({
    required this.isLoading,
    this.isLoadingMore = false,
    this.listings = const [],
    this.nextCursor,
    this.hasMore = false,
    this.errorMessage,
  });

  const MyListingsV2State.initial()
      : isLoading = true,
        isLoadingMore = false,
        listings = const [],
        nextCursor = null,
        hasMore = false,
        errorMessage = null;

  const MyListingsV2State.loaded({
    required this.listings,
    this.nextCursor,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  int get total => listings.length;

  MyListingsV2State copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<OwnerListing>? listings,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
  }) {
    return MyListingsV2State(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      listings: listings ?? this.listings,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

final listingMediaV2ServiceProvider = Provider<ListingMediaServiceV2>((ref) {
  return ListingMediaServiceV2(client: ref.watch(apiV2ClientProvider));
});

final promotionV2ServiceProvider = Provider<PromotionServiceV2>((ref) {
  return PromotionServiceV2(client: ref.watch(apiV2ClientProvider));
});

final homeServiceProvider = Provider<HomeService>((ref) {
  final service = HomeService(client: ref.watch(apiV2ClientProvider));
  ref.onDispose(service.clearCache);
  return service;
});

/// The combined V2 home feed from `/v2/home`.
///
/// Cached 60s with ETag for anonymous non-VIP viewers via [HomeService].
final homeV2Provider =
    StateNotifierProvider<HomeV2Notifier, HomeV2State>((ref) {
  return HomeV2Notifier(ref.watch(homeServiceProvider));
});

class HomeV2Notifier extends StateNotifier<HomeV2State> {
  final HomeService _service;

  HomeV2Notifier(this._service) : super(const HomeV2State.initial());

  Future<void> loadHome() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final feed = await _service.fetch();
      state = HomeV2State.loaded(feed: feed);
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load the home feed',
      );
    }
  }
}

class HomeV2State {
  final bool isLoading;
  final HomeFeed? feed;
  final String? errorMessage;

  const HomeV2State({
    required this.isLoading,
    this.feed,
    this.errorMessage,
  });

  const HomeV2State.initial()
      : isLoading = true,
        feed = null,
        errorMessage = null;

  const HomeV2State.loaded({required this.feed})
      : isLoading = false,
        errorMessage = null;

  HomeV2State copyWith({
    bool? isLoading,
    HomeFeed? feed,
    String? errorMessage,
  }) {
    return HomeV2State(
      isLoading: isLoading ?? this.isLoading,
      feed: feed ?? this.feed,
      errorMessage: errorMessage,
    );
  }
}

/// Boot-time config. Widgets watch this to apply feature flags and the
/// force-update gate.
final appConfigProvider = FutureProvider<AppConfig>((ref) {
  return ref.watch(appConfigServiceProvider).fetch();
});

/// The viewer's subscription and resolved feature capabilities.
///
/// Invalidate this after actions that consume a quota (creating an order,
/// publishing a listing) so gates and counters update on the next read.
final subscriptionOverviewProvider =
    FutureProvider<SubscriptionOverview>((ref) {
  return ref.watch(subscriptionV2ServiceProvider).fetchOverview();
});

/// Single listing detail from `/v2/listings/{id}`.
///
/// Owner viewers receive moderation state and affordances; public viewers
/// never see moderation fields.
final listingDetailV2Provider =
    FutureProvider.family<ListingDetail, int>((ref, listingId) async {
  return ref.watch(catalogServiceProvider).fetchListing(listingId);
});

/// Generic catalog detail for listings, cars, and jobs.
final catalogItemDetailV2Provider =
    FutureProvider.family<ListingDetail, ({ListingKind kind, int id})>((ref, arg) async {
  final service = ref.watch(catalogServiceProvider);
  switch (arg.kind) {
    case ListingKind.car:
      return service.fetchCar(arg.id);
    case ListingKind.job:
      return service.fetchJob(arg.id);
    case ListingKind.house:
    case ListingKind.land:
    case ListingKind.unknown:
      return service.fetchListing(arg.id);
  }
});

/// Help home feed from `/v2/help`.
final helpHomeProvider = FutureProvider<HelpHome>((ref) {
  return ref.watch(helpV2ServiceProvider).fetchHome();
});
