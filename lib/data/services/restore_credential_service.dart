import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_constants.dart';

/// Service for managing Restore Credentials API
/// Used for Zero-Tap Sign-In during device migration
class RestoreCredentialService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  RestoreCredentialService({Dio? dio, FlutterSecureStorage? secureStorage})
      : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save a restore credential after successful login
  Future<bool> saveCredential({
    required String type, // 'otp' or 'google'
    required String credential,
    String? deviceName,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await _dio.post(
        ApiConstants.restoreCredentials,
        data: {
          'type': type,
          'credential': credential,
          'device_name': deviceName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Restore a credential on new device
  Future<Map<String, dynamic>?> restoreCredential({
    required String credentialId,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await _dio.post(
        '${ApiConstants.restoreCredentials}/restore',
        data: {
          'credential_id': credentialId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'credential': response.data['credential'],
          'type': response.data['type'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// List all restore credentials for the user
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

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          response.data['credentials'] ?? [],
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Delete a restore credential
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
