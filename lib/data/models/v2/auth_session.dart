import 'account_user.dart';

/// Result of `POST /auth/send-otp` and its registration/resend variants.
class OtpDispatch {
  final String channel;
  final String destination;

  const OtpDispatch({required this.channel, required this.destination});

  bool get isSms => channel == 'sms';

  bool get isEmail => channel == 'email';

  factory OtpDispatch.fromJson(Map<String, dynamic> json) {
    return OtpDispatch(
      channel: json['channel']?.toString() ?? 'sms',
      destination: json['destination']?.toString() ?? '',
    );
  }
}

/// Bearer session returned by login and registration.
class AuthSession {
  final String token;
  final String tokenType;
  final AccountUser user;

  const AuthSession({
    required this.token,
    this.tokenType = 'Bearer',
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    if (rawUser is! Map) {
      throw const FormatException('Auth response is missing the user object');
    }

    return AuthSession(
      token: json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      user: AccountUser.fromJson(Map<String, dynamic>.from(rawUser)),
    );
  }
}
