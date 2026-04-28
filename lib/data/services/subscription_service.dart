import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/subscription.dart';

/// Service for subscription management
class SubscriptionServiceApi {
  final ApiClient _apiClient;

  SubscriptionServiceApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all subscription plans
  Future<SubscriptionPlansResponse> getPlans() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.subscriptionPlans,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<Map<String, dynamic>> plansList = [];

        if (data is Map && data['success'] == true) {
          final plansData = data['data'];
          if (plansData is List) {
            plansList = plansData.cast<Map<String, dynamic>>();
          }
        }

        final plans =
            plansList.map((json) => SubscriptionPlan.fromJson(json)).toList();

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

        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Subscription initiated',
          checkoutUrl: data['checkout_url'],
          plan: data['plan'] != null
              ? SubscriptionPlan.fromJson(data['plan'])
              : null,
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
        return SubscriptionResponse(
          success: true,
          message: response.data['message'] ?? 'Payment processed',
          checkoutUrl: response.data['checkout_url'],
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
  Future<SubscriptionResponse> activateSubscription() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.activateSubscription,
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

  const SubscriptionResponse({
    required this.success,
    this.message = '',
    this.plan,
    this.checkoutUrl,
  });
}
