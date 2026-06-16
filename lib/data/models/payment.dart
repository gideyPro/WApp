import 'user.dart';
import '../../l10n/app_localizations.dart';

enum PaymentStatus { pending, success, failed, cancelled, refunded }

enum PaymentType { subscription, featuredListing, directPayment }

/// Payment Model
class Payment {
  final int id;
  final int userId;
  final String transactionReference;
  final PaymentType paymentType;
  final int? relatedId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? paymentMethod;
  final String? chapaTransactionId;
  final String? callbackUrl;
  final String? returnUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;

  Payment({
    required this.id,
    required this.userId,
    required this.transactionReference,
    required this.paymentType,
    this.relatedId,
    required this.amount,
    this.currency = 'ETB',
    this.status = PaymentStatus.pending,
    this.paymentMethod,
    this.chapaTransactionId,
    this.callbackUrl,
    this.returnUrl,
    this.metadata,
    this.paidAt,
    required this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      transactionReference: json['transaction_reference'] ?? '',
      paymentType: PaymentType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['payment_type'] ?? 'subscription'),
        orElse: () => PaymentType.subscription,
      ),
      relatedId: json['related_id'],
      amount: _parseAmount(json['amount']),
      currency: json['currency'] ?? 'ETB',
      status: _parseStatus(json['status']),
      paymentMethod: json['payment_method'],
      chapaTransactionId: json['chapa_transaction_id'],
      callbackUrl: json['callback_url'],
      returnUrl: json['return_url'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  /// Parse status with robustness for varied backend strings
  static PaymentStatus _parseStatus(String? status) {
    if (status == null) return PaymentStatus.pending;
    final s = status.toLowerCase();
    
    if (s == 'success') return PaymentStatus.success;
    if (s.contains('fail')) return PaymentStatus.failed;
    if (s.contains('cancel')) return PaymentStatus.cancelled;
    if (s.contains('refund')) return PaymentStatus.refunded;
    
    return PaymentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == s,
      orElse: () => PaymentStatus.pending,
    );
  }

  /// Parse amount from various types (String, num, double)
  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'transaction_reference': transactionReference,
      'payment_type': paymentType.toString().split('.').last,
      'related_id': relatedId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'payment_method': paymentMethod,
      'chapa_transaction_id': chapaTransactionId,
      'callback_url': callbackUrl,
      'return_url': returnUrl,
      'metadata': metadata,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayAmount => '${amount.toStringAsFixed(2)} $currency';

  bool get isPending => status == PaymentStatus.pending;
  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;

  String getStatusLabel(AppLocalizations l10n) {
    switch (status) {
      case PaymentStatus.pending:
        return l10n.statusPending;
      case PaymentStatus.success:
        return l10n.statusSuccess;
      case PaymentStatus.failed:
        return l10n.statusFailed;
      case PaymentStatus.cancelled:
        return l10n.statusCancelled;
      case PaymentStatus.refunded:
        return l10n.statusRefunded;
    }
  }
}
