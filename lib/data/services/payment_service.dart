import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
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
        final paymentData = ApiEnvelope.extractData(data);

        return PaymentResponse(
          success: true,
          message: ApiEnvelope.extractMessage(data, 'Payment initialized'),
          checkoutUrl: paymentData['checkout_url'],
          payment: paymentData['payment'] != null
              ? Payment.fromJson(Map<String, dynamic>.from(paymentData['payment'] as Map))
              : null,
          txRef: paymentData['tx_ref'],
        );
      }

      return PaymentResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to initialize payment'),
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
        final paymentData = ApiEnvelope.extractData(data);

        return PaymentResponse(
          success: true,
          message: ApiEnvelope.extractMessage(data, 'Payment verified'),
          verified: verified,
          payment: paymentData.isNotEmpty ? Payment.fromJson(paymentData) : null,
        );
      }

      return PaymentResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Payment verification failed'),
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
        List<dynamic> paymentsList = ApiEnvelope.extractList(
          responseData,
          itemKeys: const ['payments', 'items'],
        );
        final pagination = ApiEnvelope.extractPagination(responseData, fallbackPage: page);

        final payments = paymentsList
            .whereType<Map>()
            .map((json) => Payment.fromJson(json as Map<String, dynamic>))
            .toList();

        return PaymentHistoryResponse(
          success: true,
          payments: payments,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }

      return PaymentHistoryResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch payments'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentHistoryResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get single payment details
  Future<PaymentResponse> getPaymentDetail(int paymentId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.paymentDetail}/$paymentId',
      );

      if (response.statusCode == 200) {
        final paymentData = ApiEnvelope.extractData(response.data);
        final payment = paymentData.isNotEmpty
            ? Payment.fromJson(paymentData)
            : Payment.fromJson(const <String, dynamic>{});

        return PaymentResponse(
          success: true,
          payment: payment,
        );
      }

      return PaymentResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Payment not found'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
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
