import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/plan.dart';

/// Loads subscription plans from `/v2/plans`.
class PlanService {
  final ApiV2Client _client;

  PlanService({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<List<Plan>> fetchPlans() {
    return _client.getList(
      ApiV2Constants.plans,
      parse: Plan.fromJson,
    );
  }
}
