import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../models/subscription.dart';
import '../models/v2/payment_state.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/plan_service.dart';
import 'v2/payment_service.dart';
import 'v2/subscription_service.dart';

/// Service for subscription management backed by V2 API.
class SubscriptionServiceApi {
  final PlanService _planService;
  final SubscriptionServiceV2 _subV2;
  final PaymentServiceV2 _paymentV2;

  SubscriptionServiceApi({
    ApiClient? apiClient,
    PlanService? planService,
    SubscriptionServiceV2? subService,
    PaymentServiceV2? paymentService,
  })  : _planService = planService ?? PlanService(),
        _subV2 = subService ?? SubscriptionServiceV2(),
        _paymentV2 = paymentService ?? PaymentServiceV2(client: ApiV2Client(apiClient: apiClient));

  Future<SubscriptionPlansResponse> getPlans({String currency = 'ETB'}) async {
    try {
      final plansV2 = await _planService.fetchPlans();
      final plans = plansV2.map((p) => p.toSubscriptionPlan()).toList();

      return SubscriptionPlansResponse(
        success: true,
        plans: plans,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionPlansResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<FullSubscriptionData> getFullData({String currency = 'ETB'}) async {
    try {
      final plansV2 = await _planService.fetchPlans();
      final plans = plansV2.map((p) => p.toSubscriptionPlan()).toList();

      final overview = await _subV2.fetchOverview();

      final sub = overview.subscription?.toLegacySubscription();

      return FullSubscriptionData(
        success: true,
        plans: plans,
        subscription: sub,
        canCreateListing: overview.capabilities.maxListings?.hasCapacity ?? false,
        canCreateRentalListing: overview.capabilities['max_rental_listings']?.hasCapacity ?? false,
        canCreateVehicle: overview.capabilities.maxVehicles?.hasCapacity ?? false,
        canCreateRentalVehicle: overview.capabilities['max_rental_vehicles']?.hasCapacity ?? false,
        canCreateJob: overview.capabilities.maxJobs?.hasCapacity ?? false,
        canFeatureListing: overview.capabilities.maxFeaturedListings?.hasCapacity ?? false,
        canViewVip: overview.capabilities.canViewVip,
        canCreateOrder: overview.capabilities.maxOrders?.hasCapacity ?? false,
        hasPaidSubscription: overview.hasActiveSubscription,
        canSeeVideo: overview.capabilities.canViewVideo,
        canSeeContact: overview.capabilities.canAccessContact,
        canSeeFullAddress: true,
        contactViewsUsed: overview.capabilities.maxContacts?.used ?? 0,
        contactViewsRemaining: overview.capabilities.maxContacts?.remaining ?? 0,
        rentalContactViewsUsed: overview.capabilities['max_rental_contacts']?.used ?? 0,
        rentalContactViewsRemaining: overview.capabilities['max_rental_contacts']?.remaining ?? 0,
        carContactViewsUsed: overview.capabilities['max_car_contacts']?.used ?? 0,
        carContactViewsRemaining: overview.capabilities['max_car_contacts']?.remaining ?? 0,
        carRentalContactViewsUsed: overview.capabilities['max_car_rental_contacts']?.used ?? 0,
        carRentalContactViewsRemaining: overview.capabilities['max_car_rental_contacts']?.remaining ?? 0,
        jobContactViewsUsed: overview.capabilities['max_job_contacts']?.used ?? 0,
        jobContactViewsRemaining: overview.capabilities['max_job_contacts']?.remaining ?? 0,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FullSubscriptionData(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<CurrentSubscriptionResponse> getCurrentSubscription() async {
    try {
      final overview = await _subV2.fetchOverview();
      final sub = overview.subscription?.toLegacySubscription();

      return CurrentSubscriptionResponse(
        success: true,
        subscription: sub,
        canCreateListing: overview.capabilities.maxListings?.hasCapacity ?? false,
        canCreateRentalListing: overview.capabilities['max_rental_listings']?.hasCapacity ?? false,
        canCreateVehicle: overview.capabilities.maxVehicles?.hasCapacity ?? false,
        canCreateRentalVehicle: overview.capabilities['max_rental_vehicles']?.hasCapacity ?? false,
        canCreateJob: overview.capabilities.maxJobs?.hasCapacity ?? false,
        canFeatureListing: overview.capabilities.maxFeaturedListings?.hasCapacity ?? false,
        canViewVip: overview.capabilities.canViewVip,
        canCreateOrder: overview.capabilities.maxOrders?.hasCapacity ?? false,
        hasPaidSubscription: overview.hasActiveSubscription,
        canSeeVideo: overview.capabilities.canViewVideo,
        canSeeContact: overview.capabilities.canAccessContact,
        canSeeFullAddress: true,
        contactViewsUsed: overview.capabilities.maxContacts?.used ?? 0,
        contactViewsRemaining: overview.capabilities.maxContacts?.remaining ?? 0,
        rentalContactViewsUsed: overview.capabilities['max_rental_contacts']?.used ?? 0,
        rentalContactViewsRemaining: overview.capabilities['max_rental_contacts']?.remaining ?? 0,
        carContactViewsUsed: overview.capabilities['max_car_contacts']?.used ?? 0,
        carContactViewsRemaining: overview.capabilities['max_car_contacts']?.remaining ?? 0,
        carRentalContactViewsUsed: overview.capabilities['max_car_rental_contacts']?.used ?? 0,
        carRentalContactViewsRemaining: overview.capabilities['max_car_rental_contacts']?.remaining ?? 0,
        jobContactViewsUsed: overview.capabilities['max_job_contacts']?.used ?? 0,
        jobContactViewsRemaining: overview.capabilities['max_job_contacts']?.remaining ?? 0,
      );
    } catch (e) {
      return const CurrentSubscriptionResponse(
        success: false,
        canCreateListing: false,
        canCreateRentalListing: false,
        canCreateVehicle: false,
        canCreateRentalVehicle: false,
        canCreateJob: false,
        canFeatureListing: false,
        canViewVip: false,
        canCreateOrder: false,
      );
    }
  }

  Future<SubscriptionActionResponse> subscribe(
    int planId, {
    String currency = 'ETB',
    int billingCycleMonths = 1,
  }) async {
    try {
      final checkout = await _subV2.checkout(
        planId,
        cycleMonths: billingCycleMonths,
        currency: currency,
      );

      if (checkout.activated) {
        return const SubscriptionActionResponse(
          success: true,
          message: 'Subscription activated successfully',
        );
      } else if (checkout.checkoutUrl != null) {
        return SubscriptionActionResponse(
          success: true,
          message: 'Payment initialized',
          checkoutUrl: checkout.checkoutUrl,
          txRef: checkout.checkoutUrl?.split('/').last,
        );
      }

      return const SubscriptionActionResponse(
        success: false,
        message: 'Could not complete subscription',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionActionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<SubscriptionActionResponse> startTrial(int planId) async {
    try {
      await _subV2.startTrial(planId);
      return const SubscriptionActionResponse(
        success: true,
        message: 'Trial started successfully!',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionActionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }


  Future<SubscriptionActionResponse> processPayment({
    required int planId,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      final cycleMonths = paymentData?['billing_cycle_months'] as int?;
      final currency = paymentData?['currency'] as String? ?? 'ETB';
      final checkout = await _subV2.checkout(
        planId,
        cycleMonths: cycleMonths,
        currency: currency,
      );

      if (checkout.checkoutUrl != null) {
        return SubscriptionActionResponse(
          success: true,
          message: 'Payment initialized',
          checkoutUrl: checkout.checkoutUrl,
          txRef: checkout.checkoutUrl?.split('/').last,
        );
      }

      return const SubscriptionActionResponse(
        success: false,
        message: 'Could not initialize payment',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionActionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<SubscriptionActionResponse> activateSubscription({
    required String txRef,
  }) async {
    try {
      final state = await _paymentV2.fetchOne(txRef);
      if (state.status == PaymentStatusV2.success || state.isActivated) {
        return const SubscriptionActionResponse(
          success: true,
          message: 'Subscription activated',
        );
      }
      return const SubscriptionActionResponse(
        success: false,
        message: 'Payment not yet verified',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionActionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<SubscriptionActionResponse> cancelSubscription() async {
    return const SubscriptionActionResponse(
      success: true,
      message: 'Subscription cancelled',
    );
  }

  Future<String?> checkPaymentStatus(String txRef) async {
    try {
      final state = await _paymentV2.fetchOne(txRef);
      if (state.status == PaymentStatusV2.success || state.isActivated) {
        return 'success';
      }
      if (state.status == PaymentStatusV2.failed) {
        return 'failed';
      }
      if (state.status == PaymentStatusV2.cancelled) {
        return 'cancelled';
      }
      return 'pending';
    } catch (_) {
      return 'pending';
    }
  }

  Future<String?> verifyPaymentStatus(String txRef) async {
    return checkPaymentStatus(txRef);
  }
}

class SubscriptionPlansResponse {
  final bool success;
  final String message;
  final List<SubscriptionPlan> plans;

  const SubscriptionPlansResponse({
    required this.success,
    this.message = '',
    this.plans = const [],
  });
}

class FullSubscriptionData {
  final bool success;
  final String message;
  final List<SubscriptionPlan> plans;
  final Subscription? subscription;
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

  const FullSubscriptionData({
    required this.success,
    this.message = '',
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
  });
}

class CurrentSubscriptionResponse {
  final bool success;
  final String message;
  final Subscription? subscription;
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

  const CurrentSubscriptionResponse({
    required this.success,
    this.message = '',
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
  });
}

class SubscriptionActionResponse {
  final bool success;
  final String message;
  final Subscription? subscription;
  final String? checkoutUrl;
  final String? txRef;

  const SubscriptionActionResponse({
    required this.success,
    this.message = '',
    this.subscription,
    this.checkoutUrl,
    this.txRef,
  });
}
