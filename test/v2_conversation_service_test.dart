import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/services/v2/conversation_service.dart';

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

  final conversationData = loadV2Fixture('conversation.show.json')['data'];
  final indexPage = loadV2Fixture('conversations.index.json');
  final messagesPage = loadV2Fixture('messages.index.json');
  final messageData = (messagesPage['data'] as List).first;

  group('read', () {
    test('lists threads with cursor and a clamped limit', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok(indexPage)),
      );

      final page = await service.fetch(cursor: 'abc', limit: 90);

      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v2/conversations');
      expect(request.uri.queryParameters['cursor'], 'abc');
      expect(request.uri.queryParameters['limit'], '50');
      expect(page.items.single.id, 88);
    });

    test('loads one thread', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok({'data': conversationData})),
      );

      final conversation = await service.fetchConversation(88);

      expect(requests.single.uri.path, '/api/v2/conversations/88');
      expect(conversation.listing?.id, 4821);
      expect(conversation.unreadCount, 1);
    });

    test('loads messages newest first with a cursor', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok(messagesPage)),
      );

      final page = await service.fetchMessages(
        88,
        cursor: 'older',
        limit: 30,
      );

      final request = requests.single;
      expect(request.uri.path, '/api/v2/conversations/88/messages');
      expect(request.uri.queryParameters['cursor'], 'older');
      expect(request.uri.queryParameters['limit'], '30');
      expect(page.items.single.body, contains('available'));
    });
  });

  group('writes', () {
    test('starts a direct thread', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok({'data': conversationData}, status: 201)),
      );

      final conversation = await service.start(userId: 502);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/conversations');
      expect(requests.single.data, {'user_id': 502});
      expect(conversation.id, 88);
    });

    test('starts a listing thread and accepts an existing one', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok({'data': conversationData})),
      );

      await service.start(listingId: 4821);

      expect(requests.single.data, {'listing_id': 4821});
    });

    test('rejects an ambiguous start before sending', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok({'data': conversationData})),
      );

      expect(
        () => service.start(),
        throwsArgumentError,
      );
      expect(
        () => service.start(listingId: 4821, userId: 502),
        throwsArgumentError,
      );
      expect(requests, isEmpty);
    });

    test('sends a trimmed message', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok({'data': messageData}, status: 201)),
      );

      final message = await service.sendMessage(88, '  Hello there  ');

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/conversations/88/messages');
      expect(requests.single.data, {'body': 'Hello there'});
      expect(message.conversationId, 88);
      expect(message.body, 'Yes, it is still available.');
    });

    test('rejects an empty message before sending', () async {
      final service = ConversationServiceV2(
        client: client((_) => ok({'data': messageData})),
      );

      expect(
        () => service.sendMessage(88, '   '),
        throwsArgumentError,
      );
      expect(requests, isEmpty);
    });

    test('marks a thread read', () async {
      final service = ConversationServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'conversation_id': 88,
              'marked_read': 2,
              'unread_count': 0,
              'read_at': '2026-10-29T10:30:00Z',
            },
          }),
        ),
      );

      final receipt = await service.markRead(88);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/conversations/88/read');
      expect(receipt.markedRead, 2);
      expect(receipt.unreadCount, 0);
    });

    test('surfaces a self-message conflict', () async {
      final service = ConversationServiceV2(
        client: client(
          (_) => ok({
            'error': {
              'code': 'CONFLICT',
              'message': 'You cannot start a conversation with yourself.',
              'fields': <String, dynamic>{},
            },
          }, status: 409),
        ),
      );

      await expectLater(
        service.start(userId: 501),
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
