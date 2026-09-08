import 'dart:developer';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_constants.dart';
import '../../data/models/user.dart';
import '../../presentation/providers/app_providers.dart';
import '../../presentation/providers/auth_provider.dart';

/// Provider for restore credential service
final restoreCredentialServiceProvider = Provider<RestoreCredentialService>((ref) {
  return RestoreCredentialService();
});

/// Service for managing Restore Credentials API
/// Fulfills Google Play Zero-Tap Sign-In requirement for seamless device migration
class RestoreCredentialService {

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  static const MethodChannel _channel = MethodChannel('et.wavemart.app/restore_credentials');

  RestoreCredentialService({Dio? dio, FlutterSecureStorage? secureStorage})
      : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Register a restore credential after successful login (OTP, Google, or registration).
  /// Requests a secure restore token from backend, then passes it to Android CredentialManager.
  Future<bool> registerCredential({String? deviceName}) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await _dio.post(
        ApiConstants.restoreCredentials,
        data: {
          'device_name': deviceName ?? (Platform.isAndroid ? 'Android Device' : 'Device'),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final restoreToken = data['restore_token'] ?? data['credential_id'];

        if (restoreToken != null && Platform.isAndroid) {
          try {
            await _channel.invokeMethod('createRestoreCredential', {
              'credentialData': restoreToken.toString(),
            });
            log('[RestoreCredentials] Credential registered with Android CredentialManager', name: 'Wavemart');
          } catch (e) {
            log('[RestoreCredentials] Native CredentialManager error: $e', name: 'Wavemart');
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      log('[RestoreCredentials] Failed to register credential: $e', name: 'Wavemart');
      return false;
    }
  }

  /// Attempt Zero-Tap Sign-In on a new or restored device without user interaction.
  /// Queries Android CredentialManager, then exchanges restore token with backend for a fresh Sanctum token.
  Future<bool> attemptRestore(Ref ref) async {
    if (!Platform.isAndroid) return false;

    try {
      // 1. Check if native Android restored a credential key during device setup
      final String? restoreKey = await _channel.invokeMethod<String>('getRestoreCredential');
      if (restoreKey == null || restoreKey.isEmpty) {
        log('[RestoreCredentials] No restore credential found on device', name: 'Wavemart');
        return false;
      }

      log('[RestoreCredentials] Found restore key. Exchanging with backend...', name: 'Wavemart');

      // 2. Call public unauthenticated restore endpoint
      final response = await _dio.post(
        ApiConstants.restoreSession,
        data: {
          'restore_token': restoreKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final token = data['token'];

        if (token != null) {
          final apiClient = ref.read(apiClientProvider);
          await apiClient.setAuthToken(token.toString());

          User? user;
          if (data['user'] != null) {
            user = User.fromJson(data['user']);
            await apiClient.cacheUserData(user.toJson());
            ref.read(authStateProvider.notifier).setAuthenticatedUser(user);
          }

          log('[RestoreCredentials] Zero-Tap Sign-In successful for user: ${user?.firstName}', name: 'Wavemart');
          return true;
        }
      }

      return false;
    } catch (e) {
      log('[RestoreCredentials] Restore attempt error: $e', name: 'Wavemart');
      return false;
    }
  }

  /// Clear the restore credential on logout
  Future<void> clearCredential() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('clearRestoreCredential');
      } catch (e) {
        log('[RestoreCredentials] Error clearing native credential: $e', name: 'Wavemart');
      }
    }
  }

  /// Backward-compatible wrapper for previous calls
  Future<bool> saveCredential({
    required String type,
    required String credential,
    String? deviceName,
  }) async {
    return await registerCredential(deviceName: deviceName);
  }

  /// Backward-compatible list of credentials
  Future<List<Map<String, dynamic>>> listCredentials() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return [];

      final response = await _dio.get(
        ApiConstants.restoreCredentials,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return List<Map<String, dynamic>>.from(
          response.data['credentials'] ?? [],
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Backward-compatible delete credential
  Future<bool> deleteCredential({
    required String credentialId,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await _dio.delete(
        '${ApiConstants.restoreCredentials}/$credentialId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

