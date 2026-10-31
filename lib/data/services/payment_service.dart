import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../models/payment.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/payment_service.dart';

/// Service for Chapa payment history and details backed by V2 API.
class PaymentService {
  final PaymentServiceV2 _v2;
  final Map<int, String> _cursors = {};

  PaymentService({ApiClient? apiClient, PaymentServiceV2? v2Service})
      : _v2 = v2Service ?? PaymentServiceV2();

  Future<PaymentHistoryResponse> getPaymentHistory({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      if (page <= 1) {
        _cursors.clear();
      }
      final cursor = page > 1 ? _cursors[page] : null;
      final result = await _v2.fetch(cursor: cursor, limit: perPage);
      if (result.nextCursor != null) {
        _cursors[page + 1] = result.nextCursor!;
      }
      final payments = result.items.map((p) => p.toLegacyPayment()).toList();

      return PaymentHistoryResponse(
        success: true,
        payments: payments,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: payments.length,
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
      final payment = await _v2.fetchOne(paymentId.toString());

      return PaymentResponse(
        success: true,
        payment: payment.toLegacyPayment(),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return PaymentResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<PaymentResponse> verifyPayment(String txRef) async {
    try {
      final result = await _v2.verify(txRef);

      return PaymentResponse(
        success: result.isActivated,
        verified: result.isSuccess,
        message: result.isSuccess ? 'Payment verified successfully' : 'Payment pending',
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
