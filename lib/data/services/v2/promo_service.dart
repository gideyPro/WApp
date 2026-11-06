import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/api_v2_error.dart';
import '../../models/v2/promo_models.dart';

class PromoServiceV2 {
  final ApiV2Client _client;

  PromoServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  /// Validate a promo code before registration or checkout.
  Future<PromoValidationResult> validateCode(String code) async {
    try {
      final data = await _client.sendItem(
        ApiV2Constants.promoValidate,
        method: 'POST',
        body: {'code': code.trim()},
      );
      return PromoValidationResult.fromJson(data);
    } on ApiV2Exception catch (e) {
      return PromoValidationResult(
        valid: false,
        message: e.message,
      );
    } catch (e) {
      return PromoValidationResult(
        valid: false,
        message: e.toString(),
      );
    }
  }

  /// Claim a promo code for the authenticated user (e.g. from WelcomePromoScreen).
  Future<Map<String, dynamic>> claimCode(String code) async {
    final data = await _client.sendItem(
      ApiV2Constants.promoClaim,
      method: 'POST',
      body: {'code': code.trim()},
    );
    return Map<String, dynamic>.from(data);
  }

  /// Get aggregated referral stats, promo code, wallet balance, and earnings list.
  Future<PromoDashboardData> fetchDashboard() async {
    final data = await _client.getItem(ApiV2Constants.promoDashboard);
    return PromoDashboardData.fromJson(data);
  }

  /// Submit a payout withdrawal request to Telebirr.
  Future<Map<String, dynamic>> withdraw({
    required double amount,
    required String phoneNumber,
    required String accountName,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.promoWithdraw,
      method: 'POST',
      body: {
        'amount': amount,
        'phone_number': phoneNumber.trim(),
        'account_name': accountName.trim(),
      },
    );
    return Map<String, dynamic>.from(data);
  }
}
