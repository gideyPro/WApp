import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/v2/kyc_state.dart';

import 'v2_fixtures.dart';

void main() {
  group('kyc fixture', () {
    late KycOverview overview;

    setUp(() {
      overview = KycOverview.fromJson(
        loadV2Fixture('kyc.show.json')['data'] as Map,
      );
    });

    test('parses a pending submission', () {
      expect(overview.verified, isFalse);
      expect(overview.status, KycStatus.pending);
      expect(overview.status.isPending, isTrue);
      expect(overview.canSubmit, isFalse);
      expect(overview.hasSubmission, isTrue);
      expect(overview.showRejection, isFalse);

      final verification = overview.verification!;
      expect(verification.id, 7);
      expect(verification.documentType, 'national_id');
      expect(verification.status, KycStatus.pending);
      expect(verification.rejectionReason, isNull);
      expect(
        verification.submittedAt?.toUtc(),
        DateTime.utc(2026, 10, 29, 9),
      );
      expect(verification.verifiedAt, isNull);
    });

    test('a new user has no submission and can apply', () {
      final fresh = KycOverview.fromJson({
        'verified': false,
        'status': 'none',
        'can_submit': true,
        'verification': null,
      });

      expect(fresh.status, KycStatus.none);
      expect(fresh.canSubmit, isTrue);
      expect(fresh.hasSubmission, isFalse);
      expect(fresh.verification, isNull);
    });

    test('an approved user is verified and cannot resubmit', () {
      final approved = KycOverview.fromJson({
        'verified': true,
        'status': 'approved',
        'can_submit': false,
        'verification': {
          'id': 8,
          'document_type': 'passport',
          'status': 'approved',
          'rejection_reason': null,
          'submitted_at': '2026-10-28T08:00:00Z',
          'verified_at': '2026-10-29T08:00:00Z',
        },
      });

      expect(approved.verified, isTrue);
      expect(approved.status.isApproved, isTrue);
      expect(approved.canSubmit, isFalse);
      expect(approved.verification?.verifiedAt, isNotNull);
      expect(approved.verification?.documentType, 'passport');
      expect(approved.showRejection, isFalse);
    });

    test('a rejected submission exposes its reason and can be resubmitted', () {
      final rejected = KycOverview.fromJson({
        'verified': false,
        'status': 'rejected',
        'can_submit': true,
        'verification': {
          'id': 9,
          'document_type': 'national_id',
          'status': 'rejected',
          'rejection_reason': 'The document photo is blurred.',
          'submitted_at': '2026-10-27T08:00:00Z',
          'verified_at': null,
        },
      });

      expect(rejected.status.isRejected, isTrue);
      expect(rejected.canSubmit, isTrue);
      expect(rejected.showRejection, isTrue);
      expect(
        rejected.verification?.rejectionReason,
        'The document photo is blurred.',
      );
    });

    test('unknown wire values fall back safely', () {
      expect(KycStatus.parse('archived'), KycStatus.unknown);
      expect(KycStatus.parse(null), KycStatus.unknown);

      final blank = KycOverview.fromJson(const {});
      expect(blank.verified, isFalse);
      expect(blank.status, KycStatus.unknown);
      expect(blank.canSubmit, isTrue);
      expect(blank.verification, isNull);
    });
  });

  group('phone change', () {
    test('parses the dispatch channel and destination', () {
      final dispatch = KycPhoneDispatch.fromJson({
        'channel': 'sms',
        'destination': '+251911000109',
      });

      expect(dispatch.sentBySms, isTrue);
      expect(dispatch.sentByEmail, isFalse);
      expect(dispatch.destination, '+251911000109');

      final email = KycPhoneDispatch.fromJson({
        'channel': 'email',
        'destination': 'user@example.com',
      });

      expect(email.sentByEmail, isTrue);
    });

    test('parses the verified phone', () {
      final verified = KycPhoneVerified.fromJson({
        'phone_number': '+251911000109',
        'phone_verified': true,
      });

      expect(verified.phoneNumber, '+251911000109');
      expect(verified.phoneVerified, isTrue);
    });
  });
}
