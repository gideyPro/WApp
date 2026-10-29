import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/payment_state.dart';
import '../../models/v2/subscription_state.dart';

/// Subscription overview, cycle checkout and trial start.
///
/// Checkout is cycle-authoritative: the client sends `cycle_months` and lets
/// the server resolve the price. It must never send an amount.
class SubscriptionServiceV2 {
  final ApiV2Client _client;

  SubscriptionServiceV2({ApiV2Client? client})
      : _client = client ?? ApiV2Client();

  Future<SubscriptionOverview> fetchOverview() async {
    final data = await _client.getItem(ApiV2Constants.subscription);
    return SubscriptionOverview.fromJson(data);
  }

  Future<CheckoutResult> checkout(
    int planId, {
    int? cycleMonths,
    String currency = 'ETB',
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.planCheckout(planId),
      method: 'POST',
      body: {
        if (cycleMonths != null) 'cycle_months': cycleMonths,
        'currency': currency,
      },
    );

    return CheckoutResult.fromJson(data);
  }

  Future<SubscriptionState> startTrial(int planId) async {
    final data = await _client.sendItem(
      ApiV2Constants.planTrial(planId),
      method: 'POST',
    );

    return SubscriptionState.fromJson(data);
  }
}
