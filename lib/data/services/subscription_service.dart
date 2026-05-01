import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
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
        final data = response.data['data'] ?? response.data;
        final plansData = data['plans'] ?? [];

        final plans = (plansData as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((json) => SubscriptionPlan.fromJson(json))
            .toList();

        return SubscriptionPlansResponse(
          success: true,
          plans: plans,
        );
      }

      return SubscriptionPlansResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch plans',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionPlansResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }


  /// Get current user subscription
  Future<CurrentSubscriptionResponse> getCurrentSubscription() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.currentSubscription,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final subscription = data['current_subscription'] != null
            ? Subscription.fromJson(data['current_subscription'])
            : null;

        return CurrentSubscriptionResponse(
          success: true,
          subscription: subscription,
          canCreateListing: data['can_create_listing'] ?? true,
          canFeatureListing: data['can_feature_listing'] ?? true,
        );
      }

      return const CurrentSubscriptionResponse(
        success: false,
        canCreateListing: true,
        canFeatureListing: true,
      );
    } catch (e) {
      return const CurrentSubscriptionResponse(
        success: false,
        canCreateListing: true,
        canFeatureListing: true,
      );
    }
  }

  /// Subscribe to a plan (initiates payment)
  Future<SubscriptionResponse> subscribe(int planId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.subscribeToPlan}/$planId/subscribe',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final planData = data['plan'] != null
            ? SubscriptionPlan.fromJson(data['plan'])
            : null;

        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Subscription initiated',
          checkoutUrl: data['checkout_url'],
          plan: planData,
          requiresPayment: data['requires_payment'] == true,
        );
      }

      return SubscriptionResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to subscribe',
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
        final data = response.data['data'] ?? response.data;
        
        if (data['free_plan'] == true) {
          return SubscriptionResponse(
            success: true,
            message: data['message'] ?? 'Free plan activated',
            requiresPayment: false,
          );
        }
        
        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Payment initiated',
          txRef: data['tx_ref'],
          paymentId: data['payment_id'],
          amount: data['amount'] != null 
              ? (data['amount'] is num ? data['amount'] : double.tryParse(data['amount'].toString()))
              : null,
          requiresPayment: true,
        );
      }

      return SubscriptionResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to initiate payment',
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


  /// Process subscription payment
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
        final data = response.data['data'] ?? response.data;
        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Payment processed',
          checkoutUrl: data['checkout_url'],
        );
      }

      return SubscriptionResponse(
        success: false,
        message: response.data['message'] ?? 'Payment processing failed',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Activate subscription after payment
  Future<SubscriptionResponse> activateSubscription({String? txRef}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.activateSubscription,
        queryParameters: txRef != null ? {'tx_ref': txRef} : null,
      );

      if (response.statusCode == 200) {
        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Subscription activated',
        );
      }

      return SubscriptionResponse(
        success: false,
        message: response.data['message'] ?? 'Activation failed',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Cancel current subscription
  Future<SubscriptionResponse> cancelSubscription() async {
    try {
      final response = await _apiClient.dio.delete(
        ApiConstants.cancelSubscription,
      );

      if (response.statusCode == 200) {
        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Subscription cancelled',
        );
      }

      return SubscriptionResponse(
        success: false,
        message: response.data['message'] ?? 'Cancellation failed',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for subscription plans
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

/// Response wrapper for current subscription
class CurrentSubscriptionResponse {
  final bool success;
  final String message;
  final Subscription? subscription;
  final bool canCreateListing;
  final bool canFeatureListing;

  const CurrentSubscriptionResponse({
    required this.success,
    this.message = '',
    this.subscription,
    this.canCreateListing = true,
    this.canFeatureListing = true,
  });
}

/// Response wrapper for subscription operations
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
