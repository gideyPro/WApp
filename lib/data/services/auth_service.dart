import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/user.dart';

/// Authentication service handling OTP-based login
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<AuthResponse> sendOtp({required String phoneNumber}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sendOtp,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'OTP sent successfully'),
          destination: ApiEnvelope.extractDestination(response.data),
        );
      }

      return AuthResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to send OTP'),
        destination: ApiEnvelope.extractDestination(response.data),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

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
            message: ApiEnvelope.extractMessage(data, 'Login failed'),
          );
        }

        if (token != null) {
          await _apiClient.setAuthToken(token.toString());
        }

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
        message: ApiEnvelope.extractMessage(response.data, 'Login failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

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
          message: ApiEnvelope.extractMessage(response.data, 'OTP verified successfully'),
        );
      }

      return AuthResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'OTP verification failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<AuthResponse> resendOtp({required String phoneNumber}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.resendOtp,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        return AuthResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'OTP resent successfully'),
          destination: ApiEnvelope.extractDestination(response.data),
        );
      }

      return AuthResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to resend OTP'),
        destination: ApiEnvelope.extractDestination(response.data),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<AuthResponse> googleLogin({required String idToken}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.googleLogin,
        data: {'credential': idToken},
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final token = data['token'] ?? data['access_token'];

        if (token == null &&
            data['user'] == null &&
            data['data'] == null) {
          return AuthResponse(
            success: false,
            message: ApiEnvelope.extractMessage(data, 'Google Sign-In failed'),
          );
        }

        if (token != null) {
          await _apiClient.setAuthToken(token.toString());
        }

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
        message: ApiEnvelope.extractMessage(response.data, 'Google Sign-In failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AuthResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Even if API fails, clear local token
    } finally {
      await _apiClient.clearAuthToken();
    }
  }

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
            message: ApiEnvelope.extractMessage(response.data, 'OTP sent successfully'),
            destination: ApiEnvelope.extractDestination(response.data),
          );
        }

        return AuthResponse(
          success: false,
          message: ApiEnvelope.extractMessage(response.data, 'Failed to send OTP'),
          destination: ApiEnvelope.extractDestination(response.data),
        );
      } else {
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
          final token = data['token'] ?? data['access_token'];

          if (token != null) {
            await _apiClient.setAuthToken(token.toString());
          }

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
          message: ApiEnvelope.extractMessage(response.data, 'Registration failed'),
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

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final String? destination;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.destination,
  });

  @override
  String toString() => 'AuthResponse(success: $success, message: $message)';
}
