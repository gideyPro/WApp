import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/payment_state.dart';
import '../../data/models/v2/plan.dart';
import '../../data/models/v2/subscription_state.dart' as v2_sub;
import '../../data/services/v2/payment_service.dart';
import '../../data/services/v2/plan_service.dart';
import '../../data/services/v2/subscription_service.dart';
import 'v2_providers.dart';

/// Payment Provider backed by V2
final paymentServiceProvider = Provider<PaymentServiceV2>((ref) {
  return ref.watch(paymentV2ServiceProvider);
});

final paymentHistoryProvider =
    StateNotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>((ref) {
  return PaymentHistoryNotifier(ref.watch(paymentV2ServiceProvider));
});

class PaymentHistoryNotifier extends StateNotifier<PaymentHistoryState> {
  final PaymentServiceV2 _service;

  PaymentHistoryNotifier(this._service)
      : super(const PaymentHistoryState.initial());

  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _service.fetch();
      state = PaymentHistoryState.loaded(
        payments: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load payment history',
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
        payments: [...state.payments, ...page.items],
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
        errorMessage: 'Could not load more payments',
      );
    }
  }
}

class PaymentHistoryState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<PaymentState> payments;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  const PaymentHistoryState({
    required this.isLoading,
    this.isLoadingMore = false,
    this.payments = const [],
    this.nextCursor,
    this.hasMore = false,
    this.errorMessage,
  });

  const PaymentHistoryState.initial()
      : isLoading = true,
        isLoadingMore = false,
        payments = const [],
        nextCursor = null,
        hasMore = false,
        errorMessage = null;

  const PaymentHistoryState.loaded({
    required this.payments,
    this.nextCursor,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  int get total => payments.length;

  PaymentHistoryState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<PaymentState>? payments,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
  }) {
    return PaymentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      payments: payments ?? this.payments,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

/// Subscription Providers
final subscriptionServiceProvider = Provider<SubscriptionServiceV2>((ref) {
  return ref.watch(subscriptionV2ServiceProvider);
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(
    ref.watch(subscriptionV2ServiceProvider),
    ref.watch(planServiceProvider),
  );
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionServiceV2 _subscriptionService;
  final PlanService _planService;

  SubscriptionNotifier(this._subscriptionService, this._planService)
      : super(const SubscriptionState.initial()) {
    _initialRefresh();
  }

  Future<void> _initialRefresh() async {
    refresh();
  }

  Future<void> refresh({String currency = 'ETB'}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final overview = await _subscriptionService.fetchOverview();
      final plans = await _planService.fetchPlans();
      final caps = overview.capabilities;

      state = SubscriptionState.loaded(
        plans: plans,
        subscription: overview.subscription,
        canCreateListing: caps['max_listings']?.hasCapacity ?? false,
        canCreateRentalListing:
            caps['max_rental_listings']?.hasCapacity ?? false,
        canCreateVehicle: caps['max_vehicles']?.hasCapacity ?? false,
        canCreateRentalVehicle:
            caps['max_rental_vehicles']?.hasCapacity ?? false,
        canCreateJob: caps['max_jobs']?.hasCapacity ?? false,
        canFeatureListing: caps['max_featured_listings']?.hasCapacity ?? false,
        canViewVip: caps.canViewVip,
        canCreateOrder: caps['max_orders']?.hasCapacity ?? false,
        hasPaidSubscription: overview.subscription?.isActive == true &&
            overview.subscription?.plan?.slug != 'free',
        canSeeVideo: caps.canViewVideo,
        canSeeContact: caps.canAccessContact,
        canSeeFullAddress: caps['access_full_address']?.allowed ?? false,
        contactViewsUsed: caps['max_contacts']?.used ?? 0,
        contactViewsRemaining: caps['max_contacts']?.remaining ?? 0,
      );
    } on ApiV2Exception catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class SubscriptionState {
  final bool isLoading;
  final List<Plan> plans;
  final v2_sub.SubscriptionState? subscription;
  final bool canCreateListing;
  final bool canCreateRentalListing;
  final bool canCreateVehicle;
  final bool canCreateRentalVehicle;
  final bool canCreateJob;
  final bool canFeatureListing;
  final bool canViewVip;
  final bool canCreateOrder;
  final bool hasPaidSubscription;
  final bool canSeeVideo;
  final bool canSeeContact;
  final bool canSeeFullAddress;
  final int contactViewsUsed;
  final int contactViewsRemaining;
  final int rentalContactViewsUsed;
  final int rentalContactViewsRemaining;
  final int carContactViewsUsed;
  final int carContactViewsRemaining;
  final int carRentalContactViewsUsed;
  final int carRentalContactViewsRemaining;
  final int jobContactViewsUsed;
  final int jobContactViewsRemaining;
  final String? errorMessage;

  const SubscriptionState({
    required this.isLoading,
    this.plans = const [],
    this.subscription,
    this.canCreateListing = false,
    this.canCreateRentalListing = false,
    this.canCreateVehicle = false,
    this.canCreateRentalVehicle = false,
    this.canCreateJob = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.canSeeFullAddress = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
    this.rentalContactViewsUsed = 0,
    this.rentalContactViewsRemaining = 0,
    this.carContactViewsUsed = 0,
    this.carContactViewsRemaining = 0,
    this.carRentalContactViewsUsed = 0,
    this.carRentalContactViewsRemaining = 0,
    this.jobContactViewsUsed = 0,
    this.jobContactViewsRemaining = 0,
    this.errorMessage,
  });

  const SubscriptionState.initial()
      : isLoading = true,
        plans = const [],
        subscription = null,
        canCreateListing = false,
        canCreateRentalListing = false,
        canCreateVehicle = false,
        canCreateRentalVehicle = false,
        canCreateJob = false,
        canFeatureListing = false,
        canViewVip = false,
        canCreateOrder = false,
        hasPaidSubscription = false,
        canSeeVideo = false,
        canSeeContact = false,
        canSeeFullAddress = false,
        contactViewsUsed = 0,
        contactViewsRemaining = 0,
        rentalContactViewsUsed = 0,
        rentalContactViewsRemaining = 0,
        carContactViewsUsed = 0,
        carContactViewsRemaining = 0,
        carRentalContactViewsUsed = 0,
        carRentalContactViewsRemaining = 0,
        jobContactViewsUsed = 0,
        jobContactViewsRemaining = 0,
        errorMessage = null;

  const SubscriptionState.loaded({
    required this.plans,
    this.subscription,
    this.canCreateListing = false,
    this.canCreateRentalListing = false,
    this.canCreateVehicle = false,
    this.canCreateRentalVehicle = false,
    this.canCreateJob = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.canSeeFullAddress = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
    this.rentalContactViewsUsed = 0,
    this.rentalContactViewsRemaining = 0,
    this.carContactViewsUsed = 0,
    this.carContactViewsRemaining = 0,
    this.carRentalContactViewsUsed = 0,
    this.carRentalContactViewsRemaining = 0,
    this.jobContactViewsUsed = 0,
    this.jobContactViewsRemaining = 0,
  })  : isLoading = false,
        errorMessage = null;

  SubscriptionState copyWith({
    bool? isLoading,
    List<Plan>? plans,
    v2_sub.SubscriptionState? subscription,
    bool? canCreateListing,
    bool? canCreateRentalListing,
    bool? canCreateVehicle,
    bool? canCreateRentalVehicle,
    bool? canCreateJob,
    bool? canFeatureListing,
    bool? canViewVip,
    bool? canCreateOrder,
    bool? hasPaidSubscription,
    bool? canSeeVideo,
    bool? canSeeContact,
    bool? canSeeFullAddress,
    int? contactViewsUsed,
    int? contactViewsRemaining,
    int? rentalContactViewsUsed,
    int? rentalContactViewsRemaining,
    int? carContactViewsUsed,
    int? carContactViewsRemaining,
    int? carRentalContactViewsUsed,
    int? carRentalContactViewsRemaining,
    int? jobContactViewsUsed,
    int? jobContactViewsRemaining,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      subscription: subscription ?? this.subscription,
      canCreateListing: canCreateListing ?? this.canCreateListing,
      canCreateRentalListing:
          canCreateRentalListing ?? this.canCreateRentalListing,
      canCreateVehicle: canCreateVehicle ?? this.canCreateVehicle,
      canCreateRentalVehicle:
          canCreateRentalVehicle ?? this.canCreateRentalVehicle,
      canCreateJob: canCreateJob ?? this.canCreateJob,
      canFeatureListing: canFeatureListing ?? this.canFeatureListing,
      canViewVip: canViewVip ?? this.canViewVip,
      canCreateOrder: canCreateOrder ?? this.canCreateOrder,
      hasPaidSubscription: hasPaidSubscription ?? this.hasPaidSubscription,
      canSeeVideo: canSeeVideo ?? this.canSeeVideo,
      canSeeContact: canSeeContact ?? this.canSeeContact,
      canSeeFullAddress: canSeeFullAddress ?? this.canSeeFullAddress,
      contactViewsUsed: contactViewsUsed ?? this.contactViewsUsed,
      contactViewsRemaining:
          contactViewsRemaining ?? this.contactViewsRemaining,
      rentalContactViewsUsed:
          rentalContactViewsUsed ?? this.rentalContactViewsUsed,
      rentalContactViewsRemaining:
          rentalContactViewsRemaining ?? this.rentalContactViewsRemaining,
      carContactViewsUsed: carContactViewsUsed ?? this.carContactViewsUsed,
      carContactViewsRemaining:
          carContactViewsRemaining ?? this.carContactViewsRemaining,
      carRentalContactViewsUsed:
          carRentalContactViewsUsed ?? this.carRentalContactViewsUsed,
      carRentalContactViewsRemaining:
          carRentalContactViewsRemaining ?? this.carRentalContactViewsRemaining,
      jobContactViewsUsed: jobContactViewsUsed ?? this.jobContactViewsUsed,
      jobContactViewsRemaining:
          jobContactViewsRemaining ?? this.jobContactViewsRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasError => errorMessage != null;
}
