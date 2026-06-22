import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/payment_service.dart';
import '../../data/services/subscription_service.dart';
import '../../data/models/subscription.dart';

/// Payment Provider
final paymentServiceProvider =
    Provider<PaymentService>((ref) => PaymentService());
final paymentHistoryProvider =
    StateNotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>((ref) {
  return PaymentHistoryNotifier(ref.watch(paymentServiceProvider));
});

class PaymentHistoryNotifier extends StateNotifier<PaymentHistoryState> {
  final PaymentService _paymentService;
  PaymentHistoryNotifier(this._paymentService)
      : super(const PaymentHistoryState.initial());

  Future<void> loadPayments({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _paymentService.getPaymentHistory(page: page);
    if (response.success) {
      state = PaymentHistoryState.loaded(
          payments: response.payments, total: response.total ?? 0);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }
}

class PaymentHistoryState {
  final bool isLoading;
  final List<dynamic> payments;
  final int total;
  final String? errorMessage;
  const PaymentHistoryState(
      {required this.isLoading,
      this.payments = const [],
      this.total = 0,
      this.errorMessage});
  const PaymentHistoryState.initial()
      : isLoading = true,
        payments = const [],
        total = 0,
        errorMessage = null;
  const PaymentHistoryState.loaded({required this.payments, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  PaymentHistoryState copyWith(
      {bool? isLoading,
      List<dynamic>? payments,
      int? total,
      String? errorMessage}) {
    return PaymentHistoryState(
        isLoading: isLoading ?? this.isLoading,
        payments: payments ?? this.payments,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}

/// Subscription Providers
final subscriptionServiceProvider =
    Provider<SubscriptionServiceApi>((ref) => SubscriptionServiceApi());

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(subscriptionServiceProvider));
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionServiceApi _subscriptionService;
  SubscriptionNotifier(this._subscriptionService)
      : super(const SubscriptionState.initial()) {
    refresh();
  }

  Future<void> refresh({String currency = 'ETB'}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _subscriptionService.getFullData(currency: currency);

      if (data.success) {
        state = SubscriptionState.loaded(
          plans: data.plans,
          subscription: data.subscription,
          canCreateListing: data.canCreateListing,
          canFeatureListing: data.canFeatureListing,
          canViewVip: data.canViewVip,
          canCreateOrder: data.canCreateOrder,
          hasPaidSubscription: data.hasPaidSubscription,
          canSeeVideo: data.canSeeVideo,
          canSeeContact: data.canSeeContact,
          canSeeFullAddress: data.canSeeFullAddress,
          contactViewsUsed: data.contactViewsUsed,
          contactViewsRemaining: data.contactViewsRemaining,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: data.message,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class SubscriptionState {
  final bool isLoading;
  final List<SubscriptionPlan> plans;
  final Subscription? subscription;
  final bool canCreateListing;
  final bool canFeatureListing;
  final bool canViewVip;
  final bool canCreateOrder;
  final bool hasPaidSubscription;
  final bool canSeeVideo;
  final bool canSeeContact;
  final bool canSeeFullAddress;
  final int contactViewsUsed;
  final int contactViewsRemaining;
  final String? errorMessage;

  const SubscriptionState({
    required this.isLoading,
    this.plans = const [],
    this.subscription,
    this.canCreateListing = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.canSeeFullAddress = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
    this.errorMessage,
  });

  const SubscriptionState.initial()
      : isLoading = true,
        plans = const [],
        subscription = null,
        canCreateListing = false,
        canFeatureListing = false,
        canViewVip = false,
        canCreateOrder = false,
        hasPaidSubscription = false,
        canSeeVideo = false,
        canSeeContact = false,
        canSeeFullAddress = false,
        contactViewsUsed = 0,
        contactViewsRemaining = 0,
        errorMessage = null;

  const SubscriptionState.loaded({
    required this.plans,
    this.subscription,
    this.canCreateListing = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.canSeeFullAddress = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
  })  : isLoading = false,
        errorMessage = null;

  SubscriptionState copyWith({
    bool? isLoading,
    List<SubscriptionPlan>? plans,
    Subscription? subscription,
    bool? canCreateListing,
    bool? canFeatureListing,
    bool? canViewVip,
    bool? canCreateOrder,
    bool? hasPaidSubscription,
    bool? canSeeVideo,
    bool? canSeeContact,
    bool? canSeeFullAddress,
    int? contactViewsUsed,
    int? contactViewsRemaining,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      subscription: subscription ?? this.subscription,
      canCreateListing: canCreateListing ?? this.canCreateListing,
      canFeatureListing: canFeatureListing ?? this.canFeatureListing,
      canViewVip: canViewVip ?? this.canViewVip,
      canCreateOrder: canCreateOrder ?? this.canCreateOrder,
      hasPaidSubscription: hasPaidSubscription ?? this.hasPaidSubscription,
      canSeeVideo: canSeeVideo ?? this.canSeeVideo,
      canSeeContact: canSeeContact ?? this.canSeeContact,
      canSeeFullAddress: canSeeFullAddress ?? this.canSeeFullAddress,
      contactViewsUsed: contactViewsUsed ?? this.contactViewsUsed,
      contactViewsRemaining: contactViewsRemaining ?? this.contactViewsRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasError => errorMessage != null;
}
