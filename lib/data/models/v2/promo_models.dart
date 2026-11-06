import '../../../core/utils/type_utils.dart';

class PromoValidationResult {
  final bool valid;
  final String? code;
  final double discountPercent;
  final String? inviterName;
  final String? message;

  const PromoValidationResult({
    required this.valid,
    this.code,
    this.discountPercent = 0.0,
    this.inviterName,
    this.message,
  });

  factory PromoValidationResult.fromJson(dynamic json) {
    if (json is! Map) {
      return const PromoValidationResult(valid: false, message: 'Invalid response');
    }
    final map = Map<String, dynamic>.from(json);
    return PromoValidationResult(
      valid: TypeUtils.safeBool(map['valid']),
      code: map['code']?.toString(),
      discountPercent:
          TypeUtils.safeDouble(map['discount_percent'] ?? map['discount_percentage']) ??
              0.0,
      inviterName: map['inviter_name']?.toString(),
      message: map['message']?.toString(),
    );
  }
}

class ReferralEarningItem {
  final int id;
  final String inviteeName;
  final String planName;
  final double planBasePrice;
  final double commissionPercentage;
  final double earnedAmount;
  final String status;
  final DateTime? createdAt;

  const ReferralEarningItem({
    required this.id,
    required this.inviteeName,
    required this.planName,
    required this.planBasePrice,
    required this.commissionPercentage,
    required this.earnedAmount,
    required this.status,
    this.createdAt,
  });

  factory ReferralEarningItem.fromJson(Map<String, dynamic> json) {
    return ReferralEarningItem(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      inviteeName: json['invitee_name']?.toString() ?? 'Friend',
      planName: json['plan_name']?.toString() ?? 'Subscription',
      planBasePrice: TypeUtils.safeDouble(json['plan_base_price']) ?? 0.0,
      commissionPercentage:
          TypeUtils.safeDouble(json['commission_percentage']) ?? 0.0,
      earnedAmount: TypeUtils.safeDouble(json['earned_amount']) ?? 0.0,
      status: json['status']?.toString() ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class PromoDashboardData {
  final String promoCode;
  final String inviteLink;
  final double discountPercentage;
  final double minWithdrawAmount;
  final double walletBalance;
  final bool canWithdraw;
  final int totalInvited;
  final int totalSubscribed;
  final double totalEarned;
  final List<ReferralEarningItem> earnings;

  const PromoDashboardData({
    required this.promoCode,
    required this.inviteLink,
    required this.discountPercentage,
    required this.minWithdrawAmount,
    required this.walletBalance,
    required this.canWithdraw,
    required this.totalInvited,
    required this.totalSubscribed,
    required this.totalEarned,
    required this.earnings,
  });

  factory PromoDashboardData.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'])
        : const <String, dynamic>{};
    final rawEarnings =
        json['earnings'] is List ? json['earnings'] as List : const [];

    return PromoDashboardData(
      promoCode: json['promo_code']?.toString() ?? '',
      inviteLink: json['invite_link']?.toString() ?? '',
      discountPercentage: TypeUtils.safeDouble(
              json['discount_percentage'] ?? json['discount_percent']) ??
          10.0,
      minWithdrawAmount:
          TypeUtils.safeDouble(json['min_withdraw_amount']) ?? 500.0,
      walletBalance: TypeUtils.safeDouble(json['wallet_balance']) ?? 0.0,
      canWithdraw: TypeUtils.safeBool(json['can_withdraw']),
      totalInvited: TypeUtils.safeInt(stats['total_invited']) ?? 0,
      totalSubscribed: TypeUtils.safeInt(stats['total_subscribed']) ?? 0,
      totalEarned: TypeUtils.safeDouble(stats['total_earned']) ?? 0.0,
      earnings: rawEarnings
          .whereType<Map>()
          .map((e) =>
              ReferralEarningItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
