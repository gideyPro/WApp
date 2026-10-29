import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/conference.dart';

import 'v2_fixtures.dart';

void main() {
  group('conferences.index fixture', () {
    late Paginated<CallConference> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('conferences.index.json'),
        CallConference.fromJson,
      );
    });

    test('parses the call row, host and viewer permissions', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.perPage, 20);

      final call = page.items.single;
      expect(call.id, 1);
      expect(call.status, CallStatus.scheduled);
      expect(call.isScheduled, isTrue);
      expect(call.isVideo, isFalse);
      expect(call.listing?.id, 1);
      expect(call.listing?.title, 'Spacious family house');
      expect(call.host?.id, 1);
      expect(call.host?.role, CallParticipantRole.host);
      expect(call.host?.isHost, isTrue);
      expect(call.host?.displayName, 'Abebe Kebede');
      expect(call.participantCount, 3);
      expect(call.viewer?.role, CallParticipantRole.buyer);
      expect(call.canJoin, isFalse);
      expect(call.canStart, isFalse);
      expect(call.canCancel, isFalse);
      expect(call.title, 'Spacious family house');
      expect(call.scheduledAt?.toUtc(), DateTime.utc(2026, 10, 30, 9, 58, 31));
      expect(call.startedAt, isNull);
      expect(call.endedAt, isNull);
      expect(call.durationSeconds, 0);
      expect(call.hasParticipants, isFalse);
    });
  });

  group('conference.show fixture', () {
    test('parses notes and every participant role', () {
      final call = CallConference.fromJson(
        loadV2Fixture('conference.show.json')['data'] as Map<String, dynamic>,
      );

      expect(call.id, 1);
      expect(call.notes, 'Discuss the villa and the payment plan.');
      expect(call.hasNotes, isTrue);
      expect(call.conversationId, isNull);
      expect(call.participants, hasLength(3));
      expect(call.hasParticipants, isTrue);
      expect(
        call.participants.map((participant) => participant.role).toList(),
        [
          CallParticipantRole.host,
          CallParticipantRole.seller,
          CallParticipantRole.buyer,
        ],
      );
      expect(call.participants.last.displayName, 'Liya Bekele');
      expect(call.participants.last.initials, 'LB');
      expect(call.participants.last.hasAvatar, isFalse);
      expect(call.participants.last.joined, isFalse);
    });
  });

  group('conference.join fixture', () {
    test('parses room credentials and the started call', () {
      final result = CallJoinResult.fromJson(
        loadV2Fixture('conference.join.json')['data'] as Map<String, dynamic>,
      );

      final call = result.conference;
      expect(call.status, CallStatus.active);
      expect(call.isActive, isTrue);
      expect(call.isHost, isTrue);
      expect(call.canEnd, isTrue);
      expect(call.canStart, isFalse);
      expect(call.viewer?.joined, isTrue);
      expect(call.host?.joined, isTrue);
      expect(call.startedAt, isNotNull);

      final credentials = result.credentials;
      expect(credentials.room, startsWith('WM_'));
      expect(credentials.domain, '8x8.vc');
      expect(credentials.appId, 'app-id');
      expect(credentials.method, 'jaas');
      expect(credentials.isJaas, isTrue);
      expect(credentials.isCommunity, isFalse);
      expect(credentials.token, 'jwt-token');
      expect(credentials.hasToken, isTrue);
      expect(credentials.url, contains('/app-id/'));
      expect(credentials.isVideo, isFalse);
    });
  });

  group('conferences.incoming fixture', () {
    test('parses the ringing call', () {
      final state = IncomingCallState.fromJson(
        loadV2Fixture('conferences.incoming.json')['data']
            as Map<String, dynamic>,
      );

      expect(state.incoming, isTrue);
      expect(state.hasIncoming, isTrue);
      expect(state.conference?.id, 1);
      expect(state.conference?.status, CallStatus.active);
      expect(state.conference?.canJoin, isTrue);
      expect(state.conference?.startedAt, isNotNull);
    });

    test('handles no incoming call', () {
      final state = IncomingCallState.fromJson(const {
        'incoming': false,
        'conference': null,
      });

      expect(state.incoming, isFalse);
      expect(state.hasIncoming, isFalse);
      expect(state.conference, isNull);
    });
  });

  group('call helpers', () {
    test('defaults missing payloads safely', () {
      final call = CallConference.fromJson(const {});
      expect(call.id, 0);
      expect(call.status, CallStatus.unknown);
      expect(call.isVideo, isFalse);
      expect(call.hasListing, isFalse);
      expect(call.hasHost, isFalse);
      expect(call.hasNotes, isFalse);
      expect(call.participantCount, 0);
      expect(call.viewer, isNull);
      expect(call.canJoin, isFalse);
      expect(call.title, 'Call');

      final participant = CallParticipant.fromJson({
        'id': 9,
        'first_name': 'Liya',
        'last_name': 'Bekele',
      });
      expect(participant.displayName, 'Liya Bekele');
      expect(participant.name, '');
      expect(participant.role, CallParticipantRole.unknown);
      expect(participant.joinedAt, isNull);

      final credentials = CallCredentials.fromJson(const {});
      expect(credentials.method, 'jaas');
      expect(credentials.hasToken, isFalse);
      expect(credentials.isVideo, isFalse);
    });

    test('parses a leave receipt and moderator alias', () {
      final state = CallParticipantState.fromJson({
        'conference_id': 1,
        'status': 'active',
        'participant': {
          'id': 2,
          'first_name': 'Sara',
          'last_name': 'Tesfaye',
          'name': 'Sara Tesfaye',
          'initials': 'ST',
          'avatar_url': 'https://cdn.test/avatar.png',
          'role': 'moderator',
          'is_host': false,
          'joined': false,
          'joined_at': '2026-10-29T09:58:31Z',
          'left_at': '2026-10-29T10:03:31Z',
          'duration_seconds': 300,
        },
      });

      expect(state.conferenceId, 1);
      expect(state.status, CallStatus.active);
      expect(state.participant.role, CallParticipantRole.moderator);
      expect(state.participant.hasAvatar, isTrue);
      expect(state.participant.joined, isFalse);
      expect(state.participant.leftAt?.toUtc(),
          DateTime.utc(2026, 10, 29, 10, 3, 31));
      expect(state.participant.durationSeconds, 300);
    });

    test('marks finished statuses', () {
      expect(CallStatus.parse('ended').isFinished, isTrue);
      expect(CallStatus.parse('cancelled').isFinished, isTrue);
      expect(CallStatus.parse('active').isFinished, isFalse);
      expect(CallStatus.parse('weird'), CallStatus.unknown);
    });
  });
}
