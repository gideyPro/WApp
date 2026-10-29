import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/app_config.dart';

/// Loads the v2 bootstrap document used for feature flags and force-update.
class AppConfigService {
  final ApiV2Client _client;

  AppConfigService({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<AppConfig> fetch() async {
    final data = await _client.getItem(ApiV2Constants.appConfig);
    return AppConfig.fromJson(data);
  }
}
