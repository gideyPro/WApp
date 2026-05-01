import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/user.dart';

/// Authentication service handling OTP-based login
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Check if response data is a valid JSON map (not HTML/error page)
  bool _isJsonResponse(dynamic data) => data is Map;

  /// Send OTP to phone number for registration/login
  ///
  /// Returns success message if OTP sent successfully
  Future<AuthResponse> sendOtp({required String phoneNumber}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sendOtp,
        data: {'phone_number': phoneNumber},
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          _isJsonResponse(response.data)) {
        return AuthResponse(
          success: true,
          message: response.data['message'] ?? 'OTP sent successfully',
        );
      }

      return AuthResponse(
        success: false,
        message: _isJsonResponse(response.data)
            ? (response.data['message'] ?? 'Failed to send OTP')
            : 'Server returned an unexpected response',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Login with phone number and OTP code
  ///
  /// Returns user data and stores auth token
  Future<AuthResponse> login({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
        },
      );

      // Server returns 200 for both success AND error (e.g. "Invalid or expired OTP")
      // So we check if actual token/user data exists
      if (response.statusCode == 200 && _isJsonResponse(response.data)) {
        final token = response.data['token'] ?? response.data['access_token'];

        // If server returned an error message (no token, no user), treat as failure
        if (token == null &&
            response.data['user'] == null &&
            response.data['data'] == null) {
          return AuthResponse(
            success: false,
            message: response.data['message'] ?? 'Login failed',
          );
        }

        // Store token if available
        if (token != null) {
          await _apiClient.setAuthToken(token);
        }

        // Parse user data
        User? user;
        if (response.data['user'] != null) {
          user = User.fromJson(response.data['user']);
        } else if (response.data['data'] != null) {
          user = User.fromJson(response.data['data']);
        }

        return AuthResponse(
          success: true,
          message: 'Login successful',
          user: user,
          token: token,
        );
      }

      return AuthResponse(
        success: false,
        message: _isJsonResponse(response.data)
            ? (response.data['message'] ?? 'Login failed')
            : 'Server returned an unexpected response',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Verify OTP code (standalone verification)
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.verifyOtp,
        data: {
          'phone_number': phoneNumber,
          'otp': otpCode,
        },
      );

      if (response.statusCode == 200 && _isJsonResponse(response.data)) {
        return AuthResponse(
          success: true,
          message: response.data['message'] ?? 'OTP verified successfully',
        );
      }

      return AuthResponse(
        success: false,
        message: _isJsonResponse(response.data)
            ? (response.data['message'] ?? 'OTP verification failed')
            : 'This feature is not available yet',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Resend OTP to phone number
  Future<AuthResponse> resendOtp({required String phoneNumber}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.resendOtp,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200 && _isJsonResponse(response.data)) {
        return AuthResponse(
          success: true,
          message: response.data['message'] ?? 'OTP resent successfully',
        );
      }

      return AuthResponse(
        success: false,
        message: _isJsonResponse(response.data)
            ? (response.data['message'] ?? 'Failed to resend OTP')
            : 'This feature is not available yet',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Logout user and clear stored token
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Even if API fails, clear local token
    } finally {
      await _apiClient.clearAuthToken();
    }
  }

  /// Register new account with phone, name, and gender
  /// If otpCode is null, sends OTP for registration
  /// If otpCode is provided, verifies and creates account
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    String? otpCode,
  }) async {
    try {
      if (otpCode == null) {
        // Step 1: Send OTP for registration
        final response = await _apiClient.dio.post(
          ApiConstants.register,
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'phone_number': phoneNumber,
            'gender': gender,
            'send_otp': true,
          },
        );

        if ((response.statusCode == 200 || response.statusCode == 201) &&
            _isJsonResponse(response.data)) {
          return AuthResponse(
            success: true,
            message: response.data['message'] ?? 'OTP sent successfully',
          );
        }

        return AuthResponse(
          success: false,
          message: _isJsonResponse(response.data)
              ? (response.data['message'] ?? 'Failed to send OTP')
              : 'Registration endpoint is not available on the server yet',
        );
      } else {
        // Step 2: Verify OTP and create account
        final response = await _apiClient.dio.post(
          ApiConstants.register,
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'phone_number': phoneNumber,
            'gender': gender,
            'otp_code': otpCode,
          },
        );

final statusCode = response.statusCode;
        if ((statusCode == 200 || statusCode == 201) && _isJsonResponse(response.data)) {
          // Extract token from response
          final token = response.data['token'] ?? response.data['access_token'];

          // Store token if available
          if (token != null) {
            await _apiClient.setAuthToken(token);
          }

          // Parse user data
          User? user;
          if (response.data['user'] != null) {
            user = User.fromJson(response.data['user']);
          } else if (response.data['data'] != null) {
            user = User.fromJson(response.data['data']);
          }

          return AuthResponse(
            success: true,
            message: 'Registration successful',
            user: user,
            token: token,
          );
        }

        return AuthResponse(
          success: false,
          message: _isJsonResponse(response.data)
              ? (response.data['message'] ?? 'Registration failed')
              : 'Registration endpoint is not available on the server yet',
        );
      }
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.currentUser);

      if (response.statusCode == 200 &&
          response.data != null &&
          _isJsonResponse(response.data)) {
        return User.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }
}

/// Response wrapper for authentication operations
class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  @override
  String toString() => 'AuthResponse(success: $success, message: $message)';
}
