import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/api_client.dart';
import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/fcm_service.dart';
import '../../data/services/restore_credential_service.dart';
import '../../data/services/v2/auth_service.dart';
import '../../data/services/v2/profile_service.dart';
import 'app_providers.dart';
import 'v2_providers.dart';

/// Auth State - Current authenticated user
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authV2ServiceProvider),
    ref.watch(profileV2ServiceProvider),
    ref.watch(apiClientProvider),
    ref,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthServiceV2 _authService;
  final ProfileServiceV2 _profileService;
  final ApiClient _apiClient;
  final Ref _ref;
  bool _forcingLogout = false;

  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  AuthNotifier(
    this._authService,
    this._profileService,
    this._apiClient,
    this._ref,
  ) : super(const AuthState.initial());

  /// Set authenticated user directly (used during Zero-Tap Sign-In)
  void setAuthenticatedUser(User user) {
    state = AuthState.authenticated(user);
  }

  /// Check if user is authenticated
  Future<void> checkAuth() async {
    final token = await _apiClient.getAuthToken();
    if (token != null && token.isNotEmpty) {
      await loadUser();
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Load current user data
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _profileService.fetch();
      state = AuthState.authenticated(profile.user.toUser());
    } catch (_) {
      final token = await _apiClient.getAuthToken();
      if (token == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Send OTP to phone number
  Future<AuthResponse> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dispatch = await _authService.sendLoginOtp(phoneNumber);
      state = state.copyWith(
        isLoading: false,
        phoneNumber: phoneNumber,
        otpSent: true,
        otpMessage: 'OTP sent to ${dispatch.destination}',
        destination: dispatch.destination,
        isLocked: false,
        retryAfter: null,
      );
      return AuthResponse(
        success: true,
        message: 'OTP sent to ${dispatch.destination}',
        destination: dispatch.destination,
      );
    } on ApiV2Exception catch (e) {
      final isLocked = e.isRateLimited;
      final retryAfter = e.retryAfter?.inSeconds;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
      return AuthResponse(
        success: false,
        message: e.message,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
    } catch (_) {
      state =
          state.copyWith(isLoading: false, errorMessage: 'Failed to send OTP');
      return const AuthResponse(success: false, message: 'Failed to send OTP');
    }
  }

  /// Login with OTP
  Future<AuthResponse> login(String otpCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await _authService.login(
        phoneNumber: state.phoneNumber ?? '',
        otpCode: otpCode,
      );
      await _apiClient.setAuthToken(session.token);
      final user = session.user.toUser();
      try {
        final restoreService = _ref.read(restoreCredentialServiceProvider);
        await restoreService.registerCredential(
          deviceName: await _getDeviceName(),
        );
      } catch (_) {}
      state = AuthState.authenticated(user);
      return AuthResponse(
        success: true,
        message: 'Login successful',
        user: user,
        token: session.token,
      );
    } on ApiV2Exception catch (e) {
      final isLocked = e.isRateLimited;
      final retryAfter = e.retryAfter?.inSeconds;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        otpMessage: state.otpMessage,
        destination: state.destination,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
      return AuthResponse(
        success: false,
        message: e.message,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Login failed');
      return const AuthResponse(success: false, message: 'Login failed');
    }
  }

  Future<AuthResponse> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _googleWebClientId,
        scopes: ['email', 'profile'],
      );

      await googleSignIn.signOut();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return const AuthResponse(
            success: false, message: 'Google Sign-In cancelled');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      if (idToken == null) {
        const msg = 'Failed to get ID token';
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return const AuthResponse(success: false, message: msg);
      }

      final response = await AuthService(apiClient: _apiClient)
          .googleLogin(idToken: idToken);
      if (response.success && response.user != null) {
        try {
          final restoreService = _ref.read(restoreCredentialServiceProvider);
          await restoreService.registerCredential(
            deviceName: await _getDeviceName(),
          );
        } catch (_) {}
        state = AuthState.authenticated(response.user!);
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: response.message);
      }
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return AuthResponse(success: false, message: e.toString());
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp(String otpCode) async {
    return login(otpCode);
  }

  /// Resend OTP
  Future<AuthResponse> resendOtp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dispatch = await _authService.resendOtp(state.phoneNumber ?? '');
      state = state.copyWith(
        isLoading: false,
        otpMessage: 'OTP resent to ${dispatch.destination}',
        destination: dispatch.destination,
        isLocked: false,
        retryAfter: null,
      );
      return AuthResponse(
        success: true,
        message: 'OTP resent to ${dispatch.destination}',
        destination: dispatch.destination,
      );
    } on ApiV2Exception catch (e) {
      final isLocked = e.isRateLimited;
      final retryAfter = e.retryAfter?.inSeconds;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        otpMessage: state.otpMessage,
        destination: state.destination,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
      return AuthResponse(
        success: false,
        message: e.message,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
    } catch (_) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to resend OTP');
      return const AuthResponse(
          success: false, message: 'Failed to resend OTP');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _ref.read(fcmServiceProvider).cleanup();
    } catch (_) {}
    try {
      await _ref.read(restoreCredentialServiceProvider).clearCredential();
    } catch (_) {}
    try {
      await _authService.logout();
    } catch (_) {}
    await _apiClient.clearAuthToken();
    state = const AuthState.unauthenticated();
  }

  /// Force logout on session expiry / token revocation
  Future<void> forceLogout() async {
    if (_forcingLogout) return;
    _forcingLogout = true;

    state = const AuthState.unauthenticated();

    try {
      _ref.read(fcmServiceProvider).cleanup();
    } catch (_) {}
    try {
      await _ref.read(restoreCredentialServiceProvider).clearCredential();
    } catch (_) {}
    try {
      await _apiClient.clearAuthToken();
    } catch (_) {}

    _forcingLogout = false;
  }

  /// Clear a stale OTP lockout once its countdown has elapsed.
  void clearLockout() {
    if (!state.isLocked && state.retryAfter == null) return;

    state = state.copyWith(
      clearLockout: true,
      errorMessage: state.isLocked ? null : state.errorMessage,
      otpMessage: state.otpMessage,
      destination: state.destination,
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Go back to phone input step
  void clearOtpSent() {
    state = state.copyWith(
      otpSent: false,
      errorMessage: null,
      isLocked: false,
      retryAfter: null,
    );
  }

  /// Reset auth state to initial (used when canceling registration)
  void resetState() {
    state = const AuthState.initial();
  }

  /// Get device name for restore credential
  Future<String> _getDeviceName() async {
    try {
      return 'Android Device';
    } catch (_) {
      return 'Unknown Device';
    }
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
    try {
      if (otpCode == null) {
        final dispatch = await _authService.sendRegistrationOtp(
          phoneNumber,
          email: email,
        );
        state = state.copyWith(
          isLoading: false,
          phoneNumber: phoneNumber,
          otpSent: true,
          otpMessage: 'OTP sent to ${dispatch.destination}',
          destination: dispatch.destination,
          isLocked: false,
          retryAfter: null,
        );
        return AuthResponse(
          success: true,
          message: 'OTP sent to ${dispatch.destination}',
          destination: dispatch.destination,
        );
      } else {
        final session = await _authService.register(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          gender: gender,
          otpCode: otpCode,
          email: email,
        );
        await _apiClient.setAuthToken(session.token);
        final user = session.user.toUser();
        try {
          final restoreService = _ref.read(restoreCredentialServiceProvider);
          await restoreService.registerCredential(
            deviceName: await _getDeviceName(),
          );
        } catch (_) {}
        state = AuthState.authenticated(user);
        return AuthResponse(
          success: true,
          message: 'Registration successful',
          user: user,
          token: session.token,
        );
      }
    } on ApiV2Exception catch (e) {
      final isLocked = e.isRateLimited;
      final retryAfter = e.retryAfter?.inSeconds;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
      return AuthResponse(
        success: false,
        message: e.message,
        isLocked: isLocked,
        retryAfter: retryAfter,
      );
    } catch (_) {
      state =
          state.copyWith(isLoading: false, errorMessage: 'Registration failed');
      return const AuthResponse(success: false, message: 'Registration failed');
    }
  }
}

/// Auth State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool otpSent;
  final String? phoneNumber;
  final String? errorMessage;
  final String? otpMessage;
  final String? destination;
  final bool isLocked;
  final int? retryAfter;
  final User? user;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.otpSent = false,
    this.phoneNumber,
    this.errorMessage,
    this.otpMessage,
    this.destination,
    this.isLocked = false,
    this.retryAfter,
    this.user,
  });

  const AuthState.initial()
      : isAuthenticated = false,
        isLoading = false,
        otpSent = false,
        phoneNumber = null,
        errorMessage = null,
        otpMessage = null,
        destination = null,
        isLocked = false,
        retryAfter = null,
        user = null;

  const AuthState.authenticated(this.user)
      : isAuthenticated = true,
        isLoading = false,
        otpSent = false,
        phoneNumber = null,
        errorMessage = null,
        otpMessage = null,
        destination = null,
        isLocked = false,
        retryAfter = null;

  const AuthState.unauthenticated()
      : isAuthenticated = false,
        isLoading = false,
        otpSent = false,
        phoneNumber = null,
        errorMessage = null,
        otpMessage = null,
        destination = null,
        isLocked = false,
        retryAfter = null,
        user = null;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? otpSent,
    String? phoneNumber,
    String? errorMessage,
    String? otpMessage,
    String? destination,
    bool? isLocked,
    int? retryAfter,
    bool clearLockout = false,
    User? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      otpSent: otpSent ?? this.otpSent,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
      otpMessage: otpMessage,
      destination: destination,
      isLocked: clearLockout ? false : (isLocked ?? this.isLocked),
      retryAfter: clearLockout ? null : (retryAfter ?? this.retryAfter),
      user: user ?? this.user,
    );
  }
}
