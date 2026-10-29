import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/v2/auth_session.dart';
import 'package:wavemart/data/models/v2/profile.dart';

import 'v2_fixtures.dart';

void main() {
  group('auth.login fixture', () {
    late AuthSession session;

    setUp(() {
      session = AuthSession.fromJson(
        Map<String, dynamic>.from(
          loadV2Fixture('auth.login.json')['data'] as Map,
        ),
      );
    });

    test('parses the bearer token', () {
      expect(session.token, isNotEmpty);
      expect(session.tokenType, 'Bearer');
    });

    test('parses the account user', () {
      expect(session.user.id, 1);
      expect(session.user.name, 'Abebe Kebede');
      expect(session.user.phoneNumber, '+251911234567');
      expect(session.user.phoneVerified, isTrue);
      expect(session.user.kyc.verified, isFalse);
      expect(session.user.kyc.status, isNull);
      expect(session.user.initials, 'AK');
      expect(session.user.isStaff, isFalse);
    });

    test('parses an OTP dispatch payload', () {
      final dispatch = OtpDispatch.fromJson({
        'channel': 'sms',
        'destination': '+251911234567',
      });

      expect(dispatch.isSms, isTrue);
      expect(dispatch.isEmail, isFalse);
      expect(dispatch.destination, '+251911234567');
    });
  });

  group('profile fixture', () {
    test('parses the user and account counters', () {
      final profile = Profile.fromJson(loadV2Fixture('profile.json')['data']
          as Map<String, dynamic>);

      expect(profile.user.id, 1);
      expect(profile.user.email, 'abebe@example.com');
      expect(profile.stats.listings, 3);
      expect(profile.stats.favorites, 5);
      expect(profile.stats.interests, 2);
      expect(profile.stats.unreadMessages, 0);
    });
  });
}
