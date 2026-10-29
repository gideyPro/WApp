import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/owner_listing.dart';

/// Idempotent feature/VIP actions.
///
/// Every call returns the current state, so repeating a request after a
/// dropped response is safe.
class PromotionServiceV2 {
  final ApiV2Client _client;

  PromotionServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<PromotionState> feature(int listingId) {
    return _send(ApiV2Constants.listingFeature(listingId), 'POST');
  }

  Future<PromotionState> unfeature(int listingId) {
    return _send(ApiV2Constants.listingFeature(listingId), 'DELETE');
  }

  Future<PromotionState> vip(int listingId) {
    return _send(ApiV2Constants.listingVip(listingId), 'POST');
  }

  Future<PromotionState> unvip(int listingId) {
    return _send(ApiV2Constants.listingVip(listingId), 'DELETE');
  }

  Future<PromotionState> _send(String path, String method) async {
    final data = await _client.sendItem(path, method: method);
    return PromotionState.fromJson(data);
  }
}
