import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/restore_credential_service.dart';

/// Provider for restore credential service
final restoreCredentialServiceProvider = Provider<RestoreCredentialService>((ref) {
  return RestoreCredentialService();
});

/// State for restore credentials
class RestoreCredentialsState {
  final List<Map<String, dynamic>> credentials;
  final bool isLoading;
  final String? error;

  RestoreCredentialsState({
    this.credentials = const [],
    this.isLoading = false,
    this.error,
  });

  RestoreCredentialsState copyWith({
    List<Map<String, dynamic>>? credentials,
    bool? isLoading,
    String? error,
  }) {
    return RestoreCredentialsState(
      credentials: credentials ?? this.credentials,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing restore credentials
class RestoreCredentialsNotifier extends StateNotifier<RestoreCredentialsState> {
  final RestoreCredentialService _service;

  RestoreCredentialsNotifier(this._service) : super(RestoreCredentialsState());

  /// Save a restore credential after successful login
  Future<bool> saveCredential({
    required String type,
    required String credential,
    String? deviceName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final success = await _service.saveCredential(
      type: type,
      credential: credential,
      deviceName: deviceName,
    );

    if (success) {
      await loadCredentials();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save credential',
      );
    }

    return success;
  }

  /// Load all credentials for the user
  Future<void> loadCredentials() async {
    state = state.copyWith(isLoading: true, error: null);

    final credentials = await _service.listCredentials();

    state = state.copyWith(
      credentials: credentials,
      isLoading: false,
    );
  }

  /// Delete a credential
  Future<bool> deleteCredential({
    required String credentialId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final success = await _service.deleteCredential(
      credentialId: credentialId,
    );

    if (success) {
      await loadCredentials();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete credential',
      );
    }

    return success;
  }
}

/// Provider for restore credentials state
final restoreCredentialsProvider =
    StateNotifierProvider<RestoreCredentialsNotifier, RestoreCredentialsState>((ref) {
  final service = ref.watch(restoreCredentialServiceProvider);
  return RestoreCredentialsNotifier(service);
});
