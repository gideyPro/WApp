import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';

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

class VersionNotifier extends StateNotifier<VersionState> {
  VersionNotifier() : super(const VersionState.initial()) {
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final response = await ApiClient()
          .dio
          .get('${ApiConstants.apiBase}/settings');
      final data = response.data['data'] ?? {};

      final latestVersionCode = (data['latest_app_version_code'] ?? 0) as int;

      // Only check if a newer version exists
      if (currentBuild >= latestVersionCode) {
        state = const VersionState(
          isLoading: false,
          updateType: UpdateType.none,
        );
        return;
      }

      const updateTypeMap = {
        'none': UpdateType.none,
        'non_blocking': UpdateType.nonBlocking,
        'blocking': UpdateType.blocking,
      };
      final updateType = updateTypeMap[
            data['update_type'] as String? ?? 'none'
          ] ??
          UpdateType.none;

      state = VersionState(
        isLoading: false,
        updateType: updateType,
        latestVersion: data['latest_app_version'] as String? ?? '',
        updateUrl: data['app_update_url'] as String? ?? '',
        whatsNew: data['whats_new'] as String? ?? '',
      );
    } catch (_) {
      state = const VersionState(
        isLoading: false,
        updateType: UpdateType.none,
      );
    }
  }
}

final versionProvider =
    StateNotifierProvider<VersionNotifier, VersionState>((ref) {
  return VersionNotifier();
});
