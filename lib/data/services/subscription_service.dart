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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final plansData = data?['plans'];
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
        message: _extractMessage(response.data, 'Failed to fetch plans'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionPlansResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Robustly extract a list from various API response structures
  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'];
      if (data is List) return data;
      if (data is Map) {
        final nestedData = data['data'] ?? data['plans'] ?? data['items'] ?? data['subscriptions'];
        if (nestedData is List) return nestedData;
      }
      final directList = raw['plans'] ?? raw['items'] ?? raw['subscriptions'];
      if (directList is List) return directList;
    }
    return [];
  }

  /// Robustly extract a message from various API response structures
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map) {
      return raw['message']?.toString() ?? 
             raw['error']?.toString() ?? 
             raw['errors']?.toString() ?? 
             defaultMessage;
    }
    if (raw is String) return raw;
    return defaultMessage;
  }

  /// Get plans + current subscription + capability flags in a single API call
  Future<FullSubscriptionData> getFullData() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.currentSubscription,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final plansData = data?['plans'];
        final plans = (plansData is List ? plansData : [])
            .whereType<Map>()
            .map((json) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final subData = data?['current_subscription'];
        final subscription = subData is Map
            ? Subscription.fromJson(Map<String, dynamic>.from(subData))
            : null;

        return FullSubscriptionData(
          success: true,
          plans: plans,
          subscription: subscription,
          canCreateListing: data?['can_create_listing'] ?? false,
          canFeatureListing: data?['can_feature_listing'] ?? false,
          canViewVip: data?['can_view_vip'] ?? false,
          canCreateOrder: data?['can_create_order'] ?? false,
          hasPaidSubscription: data?['has_paid_subscription'] ?? false,
          canSeeVideo: data?['can_see_video'] ?? false,
          canSeeContact: data?['can_see_contact'] ?? false,
          contactViewsUsed: data?['contact_views_used'] ?? 0,
          contactViewsRemaining: data?['contact_views_remaining'] ?? 0,
        );
      }

      return FullSubscriptionData(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch subscription data'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return FullSubscriptionData(
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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final subData = data?['current_subscription'];
        final subscription = subData is Map
            ? Subscription.fromJson(Map<String, dynamic>.from(subData))
            : null;

        return CurrentSubscriptionResponse(
          success: true,
          subscription: subscription,
          canCreateListing: data?['can_create_listing'] ?? false,
          canFeatureListing: data?['can_feature_listing'] ?? false,
          canViewVip: data?['can_view_vip'] ?? false,
          canCreateOrder: data?['can_create_order'] ?? false,
          hasPaidSubscription: data?['has_paid_subscription'] ?? false,
          canSeeVideo: data?['can_see_video'] ?? false,
          canSeeContact: data?['can_see_contact'] ?? false,
          contactViewsUsed: data?['contact_views_used'] ?? 0,
          contactViewsRemaining: data?['contact_views_remaining'] ?? 0,
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

  /// Subscribe to a plan (initiates payment)
  Future<SubscriptionResponse> subscribe(int planId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.subscribeToPlan}/$planId/subscribe',
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final planData = data?['plan'];
        final planObj = planData is Map
            ? SubscriptionPlan.fromJson(Map<String, dynamic>.from(planData))
            : null;

        return SubscriptionResponse(
          success: true,
          message: _extractMessage(response.data, 'Subscription initiated'),
          checkoutUrl: data?['checkout_url']?.toString(),
          plan: planObj,
          requiresPayment: data?['requires_payment'] == true,
        );
      }

      return SubscriptionResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to subscribe'),
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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }
        
        if (data?['free_plan'] == true) {
          return SubscriptionResponse(
            success: true,
            message: _extractMessage(response.data, 'Free plan activated'),
            requiresPayment: false,
          );
        }
        
        return SubscriptionResponse(
          success: true,
          message: _extractMessage(response.data, 'Payment initiated'),
          txRef: data?['tx_ref']?.toString(),
          paymentId: data?['payment_id'] is int ? data!['payment_id'] : null,
          amount: data?['amount'] != null 
              ? (data!['amount'] is num ? (data['amount'] as num).toDouble() : double.tryParse(data['amount'].toString()))
              : null,
          requiresPayment: true,
        );
      }

      return SubscriptionResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to initiate payment'),
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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }
        
        return SubscriptionResponse(
          success: true,
          message: _extractMessage(response.data, 'Payment processed'),
          checkoutUrl: data?['checkout_url']?.toString(),
          txRef: data?['tx_ref']?.toString(),
        );
      }

      return SubscriptionResponse(
        success: false,
        message: _extractMessage(response.data, 'Payment processing failed'),
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
          message: _extractMessage(response.data, 'Subscription activated'),
        );
      }

      return SubscriptionResponse(
        success: false,
        message: _extractMessage(response.data, 'Activation failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SubscriptionResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Check latest payment status - returns 'pending', 'success', 'failed', 'cancelled' or null
  Future<String?> getLatestPaymentStatus() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.payments,
        queryParameters: {'per_page': 1},
      );

      if (response.statusCode == 200) {
        final dataList = _extractList(response.data);
        if (dataList.isNotEmpty && dataList[0] is Map) {
          final payment = dataList[0] as Map;
          return payment['status']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
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
          message: _extractMessage(response.data, 'Subscription cancelled'),
        );
      }

      return SubscriptionResponse(
        success: false,
        message: _extractMessage(response.data, 'Cancellation failed'),
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

/// Combined response with plans + current subscription info (single API call)
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
