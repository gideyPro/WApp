import '../../../core/utils/type_utils.dart';

/// Force-update mode reported by `/v2/app-config`.
enum AppUpdateType {
  none,
  nonBlocking,
  blocking;

  static AppUpdateType parse(dynamic value) {
    switch (value?.toString()) {
      case 'non_blocking':
        return AppUpdateType.nonBlocking;
      case 'blocking':
        return AppUpdateType.blocking;
      default:
        return AppUpdateType.none;
    }
  }
}

/// Boot-time feature flags and update contract.
class AppConfig {
  final int apiVersion;

  /// Builds below this number must update before using the app.
  final int minSupportedBuild;
  final int latestBuild;
  final String latestVersion;
  final AppUpdateType updateType;
  final String updateUrl;
  final String whatsNew;
  final bool subscriptionEnabled;
  final bool rentalEnabled;
  final String currency;

  const AppConfig({
    this.apiVersion = 2,
    this.minSupportedBuild = 0,
    this.latestBuild = 0,
    this.latestVersion = '',
    this.updateType = AppUpdateType.none,
    this.updateUrl = '',
    this.whatsNew = '',
    this.subscriptionEnabled = true,
    this.rentalEnabled = false,
    this.currency = 'ETB',
  });

  bool isSupported(int currentBuild) =>
      currentBuild >= minSupportedBuild;

  bool isUpdateRequired(int currentBuild) =>
      updateType == AppUpdateType.blocking && !isSupported(currentBuild);

  bool isUpdateRecommended(int currentBuild) =>
      updateType == AppUpdateType.nonBlocking &&
      currentBuild < latestBuild;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiVersion: TypeUtils.safeInt(json['api_version']) ?? 2,
      minSupportedBuild: TypeUtils.safeInt(json['min_supported_build']) ?? 0,
      latestBuild: TypeUtils.safeInt(json['latest_build']) ?? 0,
      latestVersion: json['latest_version']?.toString() ?? '',
      updateType: AppUpdateType.parse(json['update_type']),
      updateUrl: json['update_url']?.toString() ?? '',
      whatsNew: json['whats_new']?.toString() ?? '',
      subscriptionEnabled:
          TypeUtils.safeBool(json['subscription_enabled'], defaultValue: true),
      rentalEnabled:
          TypeUtils.safeBool(json['rental_enabled'], defaultValue: false),
      currency: json['currency']?.toString() ?? 'ETB',
    );
  }
}
