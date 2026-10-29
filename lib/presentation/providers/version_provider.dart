import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/services/v2/app_config_service.dart';
import 'v2_providers.dart';

enum UpdateType { none, blocking, nonBlocking }

class VersionState {
  final bool isLoading;
  final UpdateType updateType;
  final String latestVersion;
  final String updateUrl;
  final String whatsNew;

  const VersionState({
    required this.isLoading,
    this.updateType = UpdateType.none,
    this.latestVersion = '',
    this.updateUrl = '',
    this.whatsNew = '',
  });

  const VersionState.initial()
      : isLoading = true,
        updateType = UpdateType.none,
        latestVersion = '',
        updateUrl = '',
        whatsNew = '';
}

/// Applies the `/v2/app-config` update policy for the build that is running.
///
/// A blocking update is only shown when the current build is below
/// `min_supported_build`; a non-blocking prompt only when a newer build exists.
/// If the config cannot be loaded the app starts normally — an offline launch
/// must never be locked out by the update gate.
class VersionNotifier extends StateNotifier<VersionState> {
  VersionNotifier(this._service) : super(const VersionState.initial()) {
    checkForUpdate();
  }

  final AppConfigService _service;

  Future<void> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;
      final config = await _service.fetch();

      if (config.isUpdateRequired(currentBuild)) {
        state = VersionState(
          isLoading: false,
          updateType: UpdateType.blocking,
          latestVersion: config.latestVersion,
          updateUrl: config.updateUrl,
          whatsNew: config.whatsNew,
        );
        return;
      }

      if (config.isUpdateRecommended(currentBuild)) {
        state = VersionState(
          isLoading: false,
          updateType: UpdateType.nonBlocking,
          latestVersion: config.latestVersion,
          updateUrl: config.updateUrl,
          whatsNew: config.whatsNew,
        );
        return;
      }

      state = const VersionState(isLoading: false);
    } catch (_) {
      state = const VersionState(isLoading: false);
    }
  }
}

final versionProvider =
    StateNotifierProvider<VersionNotifier, VersionState>((ref) {
  return VersionNotifier(ref.watch(appConfigServiceProvider));
});
