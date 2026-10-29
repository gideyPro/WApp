import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/models/v2/conference.dart';
import 'package:wavemart/data/services/v2/conference_service.dart';

import 'v2_fixtures.dart';

void main() {
  late List<RequestOptions> requests;

  ApiV2Client client(ResponseBody Function(RequestOptions) handler) {
    requests = [];
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.test',
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    dio.httpClientAdapter = _FakeAdapter((options) {
      requests.add(options);
      return handler(options);
    });
    return ApiV2Client(dio: dio);
  }

  ResponseBody ok(Object payload, {int status = 200}) {
    return ResponseBody.fromString(
      jsonEncode(payload),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  final indexPage = loadV2Fixture('conferences.index.json');
  final showData = loadV2Fixture('conference.show.json')['data'];
  final joinData = loadV2Fixture('conference.join.json')['data'];
  final incomingData = loadV2Fixture('conferences.incoming.json')['data'];
  final participantData = (loadV2Fixture('conference.join.json')['data']
      ['conference']['participants'] as List)[1];

  group('read', () {
    test('lists calls with status, cursor and a clamped limit', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok(indexPage)),
      );

      final page = await service.fetch(
        status: CallStatus.scheduled,
        cursor: 'abc',
        limit: 90,
      );

      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v2/conferences');
      expect(request.uri.queryParameters['status'], 'scheduled');
      expect(request.uri.queryParameters['cursor'], 'abc');
      expect(request.uri.queryParameters['limit'], '50');
      expect(page.items.single.id, 1);
    });

    test('omits status when not supplied', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok(indexPage)),
      );

      await service.fetch();

      expect(
        requests.single.uri.queryParameters.containsKey('status'),
        isFalse,
      );
      expect(requests.single.uri.queryParameters['limit'], '20');
    });

    test('loads one call', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': showData})),
      );

      final call = await service.fetchConference(1);

      expect(requests.single.uri.path, '/api/v2/conferences/1');
      expect(call.participants, hasLength(3));
      expect(call.notes, isNotNull);
    });

    test('polls for an incoming call', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': incomingData})),
      );

      final state = await service.incoming();

      expect(requests.single.uri.path, '/api/v2/conferences/incoming');
      expect(state.hasIncoming, isTrue);
      expect(state.conference?.canJoin, isTrue);
    });
  });

  group('writes', () {
    test('schedules a call with the full payload', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': showData}, status: 201)),
      );

      final call = await service.schedule(
        submissionKey: '  call-key-1  ',
        listingId: 1,
        participantIds: [2, 3],
        scheduledAt: DateTime.utc(2026, 10, 30, 9, 58),
        isVideo: true,
        notes: '  Discuss the villa  ',
      );

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v2/conferences');
      expect(request.data, {
        'submission_key': 'call-key-1',
        'listing_id': 1,
        'participant_ids': [2, 3],
        'scheduled_at': '2026-10-30T09:58:00.000Z',
        'is_video': true,
        'notes': 'Discuss the villa',
      });
      expect(call.id, 1);
      expect(call.status, CallStatus.scheduled);
    });

    test('sends only the required keys for a minimal schedule', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': showData}, status: 201)),
      );

      await service.schedule(
        submissionKey: 'call-key-2',
        listingId: 1,
        participantIds: [2],
        notes: '   ',
      );

      expect(requests.single.data, {
        'submission_key': 'call-key-2',
        'listing_id': 1,
        'participant_ids': [2],
        'is_video': false,
      });
    });

    test('rejects an invalid schedule before sending', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': showData})),
      );

      expect(
        () => service.schedule(
          submissionKey: '   ',
          listingId: 1,
          participantIds: [2],
        ),
        throwsArgumentError,
      );
      expect(
        () => service.schedule(
          submissionKey: 'key',
          listingId: 1,
          participantIds: const [],
        ),
        throwsArgumentError,
      );
      expect(
        () => service.schedule(
          submissionKey: 'key',
          listingId: 1,
          participantIds: [2, 2],
        ),
        throwsArgumentError,
      );
      expect(requests, isEmpty);
    });

    test('starts a direct call from a conversation', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': showData}, status: 201)),
      );

      await service.startDirect(conversationId: 88, isVideo: true);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/conferences/direct');
      expect(requests.single.data, {
        'conversation_id': 88,
        'is_video': true,
      });
    });

    test('joins and returns the credentials', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': joinData})),
      );

      final result = await service.join(1);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/conferences/1/join');
      expect(result.credentials.room, startsWith('WM_'));
      expect(result.credentials.token, 'jwt-token');
      expect(result.conference.status, CallStatus.active);
    });

    test('leaves and parses the participant state', () async {
      final service = ConferenceServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'conference_id': 1,
              'status': 'active',
              'participant': participantData,
            },
          }),
        ),
      );

      final state = await service.leave(1);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/conferences/1/leave');
      expect(state.conferenceId, 1);
      expect(state.status, CallStatus.active);
      expect(state.participant.role, CallParticipantRole.seller);
    });

    test('ends and cancels calls', () async {
      final service = ConferenceServiceV2(
        client: client((_) => ok({'data': showData})),
      );

      await service.end(1);
      await service.cancel(2);

      expect(
        requests.map((request) => request.uri.path).toList(),
        ['/api/v2/conferences/1/end', '/api/v2/conferences/2/cancel'],
      );
      expect(requests.every((request) => request.method == 'POST'), isTrue);
    });

    test('surfaces a join conflict', () async {
      final service = ConferenceServiceV2(
        client: client(
          (_) => ok({
            'error': {
              'code': 'CONFLICT',
              'message': 'The host has not started this call yet.',
              'fields': <String, dynamic>{},
            },
          }, status: 409),
        ),
      );

      await expectLater(
        service.join(1),
        throwsA(
          isA<ApiV2Exception>()
              .having((error) => error.code, 'code', 'CONFLICT')
              .having((error) => error.statusCode, 'status', 409),
        ),
      );
    });
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
