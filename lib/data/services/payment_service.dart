import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/payment.dart';

/// Service for Chapa payment history and details
class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

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
