import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/subscription.dart';

/// Service for subscription management
class SubscriptionServiceApi {
  final ApiClient _apiClient;

  SubscriptionServiceApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all subscription plans with current subscription info
  /// Uses the combined /subscriptions endpoint for efficiency (single call)
  Future<SubscriptionPlansResponse> getPlans() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.currentSubscription,
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);

        final plansData = data['plans'];
        final plans = (plansData is List ? plansData : [])
            .whereType<Map>()
            .map((json) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        return SubscriptionPlansResponse(
          success: true,
          plans: plans,
        );
      }

      return SubscriptionPlansResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch plans'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionPlansResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get plans + current subscription + capability flags in a single API call
  Future<FullSubscriptionData> getFullData() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.currentSubscription,
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);

        final plansData = data['plans'];
        final plans = (plansData is List ? plansData : [])
            .whereType<Map>()
            .map((json) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final subData = data['current_subscription'];
        final subscription = subData is Map
            ? Subscription.fromJson(Map<String, dynamic>.from(subData))
            : null;

        return FullSubscriptionData(
          success: true,
          plans: plans,
          subscription: subscription,
          canCreateListing: data['can_create_listing'] ?? false,
          canFeatureListing: data['can_feature_listing'] ?? false,
          canViewVip: data['can_view_vip'] ?? false,
          canCreateOrder: data['can_create_order'] ?? false,
          hasPaidSubscription: data['has_paid_subscription'] ?? false,
          canSeeVideo: data['can_see_video'] ?? false,
          canSeeContact: data['can_see_contact'] ?? false,
          contactViewsUsed: data['contact_views_used'] ?? 0,
          contactViewsRemaining: data['contact_views_remaining'] ?? 0,
        );
      }

      return FullSubscriptionData(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch subscription data'),
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
      final response = await _apiClient.dio.get(
        ApiConstants.currentSubscription,
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);

        final subData = data['current_subscription'];
        final subscription = subData is Map
            ? Subscription.fromJson(Map<String, dynamic>.from(subData))
            : null;

        return CurrentSubscriptionResponse(
          success: true,
          subscription: subscription,
          canCreateListing: data['can_create_listing'] ?? false,
          canFeatureListing: data['can_feature_listing'] ?? false,
          canViewVip: data['can_view_vip'] ?? false,
          canCreateOrder: data['can_create_order'] ?? false,
          hasPaidSubscription: data['has_paid_subscription'] ?? false,
          canSeeVideo: data['can_see_video'] ?? false,
          canSeeContact: data['can_see_contact'] ?? false,
          contactViewsUsed: data['contact_views_used'] ?? 0,
          contactViewsRemaining: data['contact_views_remaining'] ?? 0,
        );
      }

      return const CurrentSubscriptionResponse(
        success: false,
        canCreateListing: false,
        canFeatureListing: false,
      );
    } catch (e) {
      return const CurrentSubscriptionResponse(
        success: false,
        canCreateListing: false,
        canFeatureListing: false,
      );
    }
  }

  Future<SubscriptionResponse> subscribe(int planId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.subscribeToPlan}/$planId/subscribe',
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);

        final planData = data['plan'];
        final planObj = planData is Map
            ? SubscriptionPlan.fromJson(Map<String, dynamic>.from(planData))
            : null;

        return SubscriptionResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Subscription initiated'),
          checkoutUrl: data['checkout_url']?.toString(),
          plan: planObj,
          requiresPayment: data['requires_payment'] == true,
        );
      }

      return SubscriptionResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to subscribe'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
        requiresPayment: false,
      );
    }
  }

  /// Initiate payment for mobile SDK - gets tx_ref without calling Chapa
  Future<SubscriptionResponse> initiatePayment({
    required int planId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.initiateSubscriptionPayment}/$planId/initiate-payment',
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);

        if (data['free_plan'] == true) {
          return SubscriptionResponse(
            success: true,
            message: ApiEnvelope.extractMessage(response.data, 'Free plan activated'),
            requiresPayment: false,
          );
        }

        return SubscriptionResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Payment initiated'),
          txRef: data['tx_ref']?.toString(),
          paymentId: data['payment_id'] is int ? data['payment_id'] as int : null,
          amount: data['amount'] != null
              ? (data['amount'] is num
                  ? (data['amount'] as num).toDouble()
                  : double.tryParse(data['amount'].toString()))
              : null,
          requiresPayment: true,
        );
      }

      return SubscriptionResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to initiate payment'),
        requiresPayment: false,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
        requiresPayment: false,
      );
    }
  }


  Future<SubscriptionResponse> processPayment({
    required int planId,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.processSubscriptionPayment}/$planId/process-payment',
        data: paymentData,
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);

        return SubscriptionResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Payment processed'),
          checkoutUrl: data['checkout_url']?.toString(),
          txRef: data['tx_ref']?.toString(),
        );
      }

      return SubscriptionResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Payment processing failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<SubscriptionResponse> activateSubscription({String? txRef}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.activateSubscription,
        queryParameters: txRef != null ? {'tx_ref': txRef} : null,
      );

      if (response.statusCode == 200) {
        return SubscriptionResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Subscription activated'),
        );
      }

      return SubscriptionResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Activation failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Check payment status for a specific transaction reference.
  /// Returns 'pending', 'success', 'failed', 'cancelled' or null.
  Future<String?> checkPaymentStatus(String txRef) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.payments}/status/$txRef',
      );

      if (response.statusCode == 200) {
        final data = ApiEnvelope.extractData(response.data);
        return data['status']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class FullSubscriptionData {
  final bool success;
  final String message;
  final List<SubscriptionPlan> plans;
  final Subscription? subscription;
  final bool canCreateListing;
  final bool canFeatureListing;
  final bool canViewVip;
  final bool canCreateOrder;
  final bool hasPaidSubscription;
  final bool canSeeVideo;
  final bool canSeeContact;
  final int contactViewsUsed;
  final int contactViewsRemaining;

  const FullSubscriptionData({
    required this.success,
    this.message = '',
    this.plans = const [],
    this.subscription,
    this.canCreateListing = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
  });
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

class CurrentSubscriptionResponse {
  final bool success;
  final String message;
  final Subscription? subscription;
  final bool canCreateListing;
  final bool canFeatureListing;
  final bool canViewVip;
  final bool canCreateOrder;
  final bool hasPaidSubscription;
  final bool canSeeVideo;
  final bool canSeeContact;
  final int contactViewsUsed;
  final int contactViewsRemaining;

  const CurrentSubscriptionResponse({
    required this.success,
    this.message = '',
    this.subscription,
    this.canCreateListing = true,
    this.canFeatureListing = true,
    this.canViewVip = true,
    this.canCreateOrder = true,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
  });
}

class SubscriptionResponse {
  final bool success;
  final String message;
  final SubscriptionPlan? plan;
  final String? checkoutUrl;
  final String? txRef;
  final int? paymentId;
  final double? amount;
  final bool requiresPayment;

  const SubscriptionResponse({
    required this.success,
    this.message = '',
    this.plan,
    this.checkoutUrl,
    this.txRef,
    this.paymentId,
    this.amount,
    this.requiresPayment = false,
  });
}
