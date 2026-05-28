import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/user.dart';

/// Authentication service handling OTP-based login
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Send OTP to phone number for registration/login
  ///
  /// Returns success message if OTP sent successfully
  Future<AuthResponse> sendOtp({required String phoneNumber}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sendOtp,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse(
          success: true,
          message: _extractMessage(response.data, 'OTP sent successfully'),
        );
      }

      return AuthResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to send OTP'),
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
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final token = data['token'] ?? data['access_token'];

        // If server returned an error message (no token, no user), treat as failure
        if (token == null &&
            data['user'] == null &&
            data['data'] == null) {
          return AuthResponse(
            success: false,
            message: _extractMessage(data, 'Login failed'),
          );
        }

        // Store token if available
        if (token != null) {
          await _apiClient.setAuthToken(token.toString());
        }

        // Parse user data
        User? user;
        if (data['user'] != null) {
          user = User.fromJson(data['user']);
        } else if (data['data'] != null) {
          user = User.fromJson(data['data']);
        }

        return AuthResponse(
          success: true,
          message: 'Login successful',
          user: user,
          token: token?.toString(),
        );
      }

      return AuthResponse(
        success: false,
        message: _extractMessage(response.data, 'Login failed'),
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

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: _extractMessage(response.data, 'OTP verified successfully'),
        );
      }

      return AuthResponse(
        success: false,
        message: _extractMessage(response.data, 'OTP verification failed'),
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

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: _extractMessage(response.data, 'OTP resent successfully'),
        );
      }

      return AuthResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to resend OTP'),
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
    String? email,
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
            'email': email,
            'send_otp': true,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return AuthResponse(
            success: true,
            message: _extractMessage(response.data, 'OTP sent successfully'),
          );
        }

        return AuthResponse(
          success: false,
          message: _extractMessage(response.data, 'Failed to send OTP'),
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
            'email': email,
            'otp_code': otpCode,
          },
        );

        final statusCode = response.statusCode;
        if ((statusCode == 200 || statusCode == 201) && response.data is Map) {
          final data = response.data as Map;
          // Extract token from response
          final token = data['token'] ?? data['access_token'];

          // Store token if available
          if (token != null) {
            await _apiClient.setAuthToken(token.toString());
          }

          // Parse user data
          User? user;
          if (data['user'] != null) {
            user = User.fromJson(data['user']);
          } else if (data['data'] != null) {
            user = User.fromJson(data['data']);
          }

          return AuthResponse(
            success: true,
            message: 'Registration successful',
            user: user,
            token: token?.toString(),
          );
        }

        return AuthResponse(
          success: false,
          message: _extractMessage(response.data, 'Registration failed'),
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

      if (response.statusCode == 200 && response.data is Map) {
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

  /// Helper to extract message from dynamic response
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map && raw['message'] != null) {
      return raw['message'].toString();
    }
    return defaultMessage;
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
