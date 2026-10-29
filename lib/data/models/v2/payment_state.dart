import '../../../core/utils/type_utils.dart';
import '../../../l10n/app_localizations.dart';
import 'subscription_state.dart';

/// Payment lifecycle reported by v2.
enum PaymentStatusV2 {
  pending('pending'),
  success('success'),
  failed('failed'),
  cancelled('cancelled'),
  unknown('unknown');

  final String wireValue;

  const PaymentStatusV2(this.wireValue);

  static PaymentStatusV2 parse(dynamic value) {
    switch (value?.toString()) {
      case 'pending':
        return PaymentStatusV2.pending;
      case 'success':
        return PaymentStatusV2.success;
      case 'failed':
        return PaymentStatusV2.failed;
      case 'cancelled':
        return PaymentStatusV2.cancelled;
      default:
        return PaymentStatusV2.unknown;
    }
  }

  bool get isPending => this == PaymentStatusV2.pending;

  bool get isSettled =>
      this == PaymentStatusV2.success ||
      this == PaymentStatusV2.failed ||
      this == PaymentStatusV2.cancelled;
}

/// Payment row returned by `/payments` and the checkout/verify actions.
class PaymentState {
  final int id;
  final String txRef;
  final String type;
  final PaymentStatusV2 status;
  final double amount;
  final String currency;
  final SubscriptionPlanRef? plan;
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime? activatedAt;
  final DateTime? createdAt;

  const PaymentState({
    required this.id,
    required this.txRef,
    this.type = 'subscription',
    this.status = PaymentStatusV2.pending,
    this.amount = 0,
    this.currency = 'ETB',
    this.plan,
    this.paymentMethod,
    this.paidAt,
    this.activatedAt,
    this.createdAt,
  });

  bool get isPending => status == PaymentStatusV2.pending;

  bool get isSuccessful => status == PaymentStatusV2.success;

  bool get isSuccess => isSuccessful;

  bool get isFailed => status == PaymentStatusV2.failed;

  bool get isCancelled => status == PaymentStatusV2.cancelled;

  bool get isActivated => activatedAt != null;

  String get transactionReference => txRef;

  String get displayAmount =>
      '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} $currency';

  String getStatusLabel(AppLocalizations l10n) {
    switch (status) {
      case PaymentStatusV2.success:
        return l10n.statusSuccess;
      case PaymentStatusV2.failed:
        return l10n.statusFailed;
      case PaymentStatusV2.cancelled:
        return l10n.statusCancelled;
      case PaymentStatusV2.pending:
      default:
        return l10n.statusPending;
    }
  }

  factory PaymentState.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return PaymentState(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      txRef: map['tx_ref']?.toString() ?? '',
      type: map['type']?.toString() ?? 'subscription',
      status: PaymentStatusV2.parse(map['status']),
      amount: TypeUtils.safeDouble(map['amount']) ?? 0,
      currency: map['currency']?.toString() ?? 'ETB',
      plan:
          map['plan'] is Map ? SubscriptionPlanRef.fromJson(map['plan']) : null,
      paymentMethod: _text(map['payment_method']),
      paidAt: _date(map['paid_at']),
      activatedAt: _date(map['activated_at']),
      createdAt: _date(map['created_at']),
    );
  }
}

/// Response of `POST /subscriptions/{plan}/checkout`.
///
/// Free plans activate immediately, so `activated` is true and both
/// [checkoutUrl] and [payment] are null. Paid plans return a gateway URL and a
/// pending payment.
class CheckoutResult {
  final bool activated;
  final String? checkoutUrl;
  final PaymentState? payment;
  final SubscriptionState? subscription;

  const CheckoutResult({
    this.activated = false,
    this.checkoutUrl,
    this.payment,
    this.subscription,
  });

  bool get needsGateway => !activated && hasCheckoutUrl;

  bool get hasCheckoutUrl => checkoutUrl != null && checkoutUrl!.isNotEmpty;

  factory CheckoutResult.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return CheckoutResult(
      activated: TypeUtils.safeBool(map['activated']),
      checkoutUrl: _text(map['checkout_url']),
      payment:
          map['payment'] is Map ? PaymentState.fromJson(map['payment']) : null,
      subscription: map['subscription'] is Map
          ? SubscriptionState.fromJson(map['subscription'])
          : null,
    );
  }
}

/// Response of `POST /payments/{tx_ref}/verify`.
class PaymentVerification {
  final PaymentStatusV2 status;
  final PaymentState payment;
  final SubscriptionState? subscription;

  const PaymentVerification({
    required this.status,
    required this.payment,
    this.subscription,
  });

  bool get isSuccess => status == PaymentStatusV2.success;

  bool get isPending => status == PaymentStatusV2.pending;

  bool get activatedSubscription => isSuccess && subscription?.isActive == true;

  bool get isActivated => isSuccess || activatedSubscription;

  factory PaymentVerification.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return PaymentVerification(
      status: PaymentStatusV2.parse(map['status']),
      payment: PaymentState.fromJson(map['payment']),
      subscription: map['subscription'] is Map
          ? SubscriptionState.fromJson(map['subscription'])
          : null,
    );
  }
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
