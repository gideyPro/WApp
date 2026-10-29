import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/auth_session.dart';

/// Passwordless v2 authentication.
///
/// The service returns the session; persisting the token remains the auth
/// provider's job so v1 and v2 share one secure-storage cache.
class AuthServiceV2 {
  final ApiV2Client _client;

  AuthServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<OtpDispatch> sendLoginOtp(String phoneNumber) {
    return _dispatch(ApiV2Constants.authSendOtp, phoneNumber);
  }

  Future<OtpDispatch> sendRegistrationOtp(
    String phoneNumber, {
    String? email,
  }) {
    return _dispatch(
      ApiV2Constants.authRegisterSendOtp,
      phoneNumber,
      email: email,
    );
  }

  Future<OtpDispatch> resendOtp(String phoneNumber, {String? email}) {
    return _dispatch(
      ApiV2Constants.authResendOtp,
      phoneNumber,
      email: email,
    );
  }

  Future<AuthSession> login({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.authLogin,
      method: 'POST',
      body: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      },
    );

    return AuthSession.fromJson(data);
  }

  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String otpCode,
    String? email,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.authRegister,
      method: 'POST',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'gender': gender,
        'otp_code': otpCode,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );

    return AuthSession.fromJson(data);
  }

  Future<void> logout() async {
    await _client.send(ApiV2Constants.authLogout, method: 'POST');
  }

  Future<OtpDispatch> _dispatch(
    String path,
    String phoneNumber, {
    String? email,
  }) async {
    final data = await _client.sendItem(
      path,
      method: 'POST',
      body: {
        'phone_number': phoneNumber,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );

    return OtpDispatch.fromJson(data);
  }
}
