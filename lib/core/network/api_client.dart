import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

/// Dio API Client with interceptors for authentication, logging, and error handling
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // In-memory token cache shared across ALL ApiClient instances
  static String? _cachedToken;
  
  // Shared locale for API requests
  static String currentLocale = 'en';

  // Android storage options for device compatibility
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: false,
    resetOnError: true,
  );

  ApiClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(aOptions: _androidOptions) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          ApiConstants.headerAccept: ApiConstants.contentTypeJson,
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
        validateStatus: (status) => status! < 500,
        followRedirects: false,
      ),
    );

    _addInterceptors();
  }

  /// Add interceptors for auth, logging, and error handling
  void _addInterceptors() {
    // Auth Interceptor - Add Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check in-memory cache first, then fall back to secure storage
          String? token = _cachedToken;
          if (token == null) {
            try {
              token = await _secureStorage.read(key: 'auth_token');
              if (token != null && token.isNotEmpty) {
                _cachedToken = token;
              }
            } catch (e) {
              // Secure storage read failed — continue without token
            }
          }
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.headerAuthorization] =
                '${ApiConstants.headerBearer} $token';
          }
          
          // Add Localization Header
          options.headers['Accept-Language'] = currentLocale;
          
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Clear in-memory cache immediately
            _cachedToken = null;
            // Clear storage asynchronously — don't block the error handler
            _secureStorage.deleteAll().catchError((_) {});
          }
          return handler.next(error);
        },
      ),
    );

    // Logging Interceptor - Only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            log('[API] $obj', name: 'Wavemart');
          },
        ),
      );
    }
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Update base URL (for environment switching)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Store auth token — saves to disk AND in-memory cache
  Future<void> setAuthToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  /// Clear auth token — clears both disk and memory
  Future<void> clearAuthToken() async {
    _cachedToken = null;
    await _secureStorage.delete(key: 'auth_token');
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Cache current user data for offline access
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await _secureStorage.write(
      key: 'cached_user',
      value: json.encode(userData),
    );
  }

  /// Retrieve cached user data (null if absent or corrupted)
  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final raw = await _secureStorage.read(key: 'cached_user');
      if (raw == null) return null;
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clear cached user data
  Future<void> clearCachedUser() async {
    await _secureStorage.delete(key: 'cached_user');
  }
}
