import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/payment.dart';
// Removed unused import

/// Service for Chapa payment processing
class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Initialize Chapa payment
  ///
  /// [paymentType]: subscription, featured_listing
  /// [amount]: Amount in ETB
  /// [relatedId]: ID of related entity (plan ID, listing ID)
  Future<PaymentResponse> initializePayment({
    required String paymentType,
    required double amount,
    int? relatedId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.initializePayment,
        data: {
          'payment_type': paymentType,
          'amount': amount,
          if (relatedId != null) 'related_id': relatedId,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final paymentData = (data is Map) ? (data['data'] ?? data) : {};

        return PaymentResponse(
          success: true,
          message: _extractMessage(data, 'Payment initialized'),
          checkoutUrl: paymentData['checkout_url'],
          payment: paymentData['payment'] != null
              ? Payment.fromJson(paymentData['payment'])
              : null,
          txRef: paymentData['tx_ref'],
        );
      }

      return PaymentResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to initialize payment'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Verify payment by transaction reference
  Future<PaymentResponse> verifyPayment(String txRef) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.verifyPayment,
        queryParameters: {'tx_ref': txRef},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final verified = (data is Map) ? (data['verified'] ?? true) : true;
        final paymentData = (data is Map) ? (data['data'] ?? data) : null;
        
        return PaymentResponse(
          success: true,
          message: _extractMessage(data, 'Payment verified'),
          verified: verified,
          payment: (paymentData is Map)
              ? Payment.fromJson(paymentData as Map<String, dynamic>)
              : null,
        );
      }

      return PaymentResponse(
        success: false,
        message: _extractMessage(response.data, 'Payment verification failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get payment history
  Future<PaymentHistoryResponse> getPaymentHistory({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.payments,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> paymentsList = _extractList(responseData);
        int currentPage = page;
        int totalPages = 1;
        int total = 0;

        if (responseData is Map) {
          final dataField = responseData['data'];
          if (dataField is Map) {
            currentPage = _safeInt(dataField['current_page']) ?? page;
            totalPages = _safeInt(dataField['last_page']) ?? 1;
            total = _safeInt(dataField['total']) ?? 0;
          }
        }

        final payments = paymentsList
            .whereType<Map>()
            .map((json) => Payment.fromJson(json as Map<String, dynamic>))
            .toList();

        return PaymentHistoryResponse(
          success: true,
          payments: payments,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return PaymentHistoryResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch payments'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentHistoryResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Get single payment details
  Future<PaymentResponse> getPaymentDetail(int paymentId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.paymentDetail}/$paymentId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final paymentData = (data is Map) ? (data['data'] ?? data) : {};
        
        final payment = Payment.fromJson(
          paymentData is Map ? paymentData as Map<String, dynamic> : {},
        );

        return PaymentResponse(
          success: true,
          payment: payment,
        );
      }

      return PaymentResponse(
        success: false,
        message: _extractMessage(response.data, 'Payment not found'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Helper to extract list from dynamic response
  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'] ?? raw['payments'];
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
    }
    return [];
  }

  /// Helper to extract message from dynamic response
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map && raw['message'] != null) {
      return raw['message'].toString();
    }
    return defaultMessage;
  }
}

/// Response wrapper for payment operations
class PaymentResponse {
  final bool success;
  final String message;
  final Payment? payment;
  final String? checkoutUrl;
  final String? txRef;
  final bool? verified;

  const PaymentResponse({
    required this.success,
    this.message = '',
    this.payment,
    this.checkoutUrl,
    this.txRef,
    this.verified,
  });
}

/// Response wrapper for payment history
class PaymentHistoryResponse {
  final bool success;
  final String message;
  final List<Payment> payments;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const PaymentHistoryResponse({
    required this.success,
    this.message = '',
    this.payments = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });
}
