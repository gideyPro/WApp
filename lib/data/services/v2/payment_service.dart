import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/payment_state.dart';

/// Payment history plus the idempotent verify/cancel actions.
class PaymentServiceV2 {
  final ApiV2Client _client;

  PaymentServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<Paginated<PaymentState>> fetch({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
    PaymentStatusV2? status,
    String? type,
  }) {
    return _client.getCollection(
      ApiV2Constants.payments,
      parse: PaymentState.fromJson,
      query: {
        if (status != null && status != PaymentStatusV2.unknown)
          'status': status.wireValue,
        if (type != null && type.isNotEmpty) 'type': type,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<PaymentState> fetchOne(String txRef) async {
    final data = await _client.getItem(ApiV2Constants.payment(txRef));
    return PaymentState.fromJson(data);
  }

  /// Verify with the gateway and activate the plan exactly once. Safe to
  /// retry: a replay returns the same subscription without re-charging.
  Future<PaymentVerification> verify(String txRef) async {
    final data = await _client.sendItem(
      ApiV2Constants.paymentVerify(txRef),
      method: 'POST',
    );

    return PaymentVerification.fromJson(data);
  }

  Future<PaymentState> cancel(String txRef) async {
    final data = await _client.sendItem(
      ApiV2Constants.paymentCancel(txRef),
      method: 'POST',
    );

    return PaymentState.fromJson(data);
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit ? ApiV2Constants.maxLimit : limit;
  }
}
