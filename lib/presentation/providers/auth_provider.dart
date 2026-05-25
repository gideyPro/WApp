import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/fcm_service.dart';
import '../../data/models/user.dart';

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth State - Current authenticated user
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(AuthState.initial());

  /// Check if user is authenticated
  Future<void> checkAuth() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated) {
      await loadUser();
    }
  }

  /// Load current user data
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      // Keep existing user data on network errors - don't wipe cached state
      if (state.user == null) {
        state = AuthState.unauthenticated();
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Send OTP to phone number
  Future<AuthResponse> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.sendOtp(phoneNumber: phoneNumber);
    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        phoneNumber: phoneNumber,
        otpSent: true,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }

  /// Login with OTP
  Future<AuthResponse> login(String otpCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.login(
      phoneNumber: state.phoneNumber ?? '',
      otpCode: otpCode,
    );
    if (response.success && response.user != null) {
      state = AuthState.authenticated(response.user!);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp(String otpCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.verifyOtp(
      phoneNumber: state.phoneNumber ?? '',
      otpCode: otpCode,
    );
    if (response.success) {
      state = state.copyWith(isLoading: false, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }

  /// Resend OTP
  Future<AuthResponse> resendOtp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.resendOtp(
      phoneNumber: state.phoneNumber ?? '',
    );
    if (response.success) {
      state = state.copyWith(isLoading: false, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }

  /// Logout
  Future<void> logout() async {
    // Clean up FCM token before logging out to stop receiving pushes
    try {
      _ref.read(fcmServiceProvider).cleanup();
    } catch (_) {}
    await _authService.logout();
    state = AuthState.unauthenticated();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Go back to phone input step
  void clearOtpSent() {
    state = state.copyWith(otpSent: false, errorMessage: null);
  }

  /// Reset auth state to initial (used when canceling registration)
  void resetState() {
    state = AuthState.initial();
  }

  /// Register new account
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    String? email,
    String? otpCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      gender: gender,
      email: email,
      otpCode: otpCode,
    );
    if (response.success) {
      if (otpCode == null) {
        // OTP sent successfully
        state = state.copyWith(
          isLoading: false,
          phoneNumber: phoneNumber,
          otpSent: true,
        );
      } else {
        // Registration complete, user authenticated
        if (response.user != null) {
          state = AuthState.authenticated(response.user!);
        }
      }
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response;
  }
}

/// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool otpSent;
  final User? user;
  final String? phoneNumber;
  final String? errorMessage;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.otpSent = false,
    this.user,
    this.phoneNumber,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(
    isAuthenticated: false,
    isLoading: false,
    otpSent: false,
  );

  factory AuthState.authenticated(User user) => AuthState(
    isAuthenticated: true,
    isLoading: false,
    otpSent: false,
    user: user,
    phoneNumber: user.phoneNumber,
    errorMessage: null,
  );

  factory AuthState.unauthenticated() => const AuthState(
    isAuthenticated: false,
    isLoading: false,
    otpSent: false,
    user: null,
    phoneNumber: null,
    errorMessage: null,
  );

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? otpSent,
    User? user,
    String? phoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      otpSent: otpSent ?? this.otpSent,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
    );
  }
}
