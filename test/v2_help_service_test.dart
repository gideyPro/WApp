import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/models/v2/help_ticket.dart';
import 'package:wavemart/data/services/v2/help_service.dart';

import 'v2_fixtures.dart';

void main() {
  late List<RequestOptions> requests;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('help_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File file(String name) {
    return File('${tempDir.path}/$name')
      ..writeAsBytesSync(const [0xFF, 0xD8, 0xFF]);
  }

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

  final homeData = loadV2Fixture('help.index.json')['data'];
  final articleData = loadV2Fixture('help.article.json')['data'];
  final ticketData = loadV2Fixture('help.ticket.show.json')['data'];
  final ticketsPage = loadV2Fixture('help.tickets.index.json');
  final articlePage = {
    'data': (homeData as Map)['featured_articles'],
    'meta': {'next_cursor': null, 'has_more': false, 'per_page': 20},
  };

  group('public help', () {
    test('loads the home payload', () async {
      final service = HelpServiceV2(
        client: client((_) => ok({'data': homeData})),
      );

      final home = await service.fetchHome();

      expect(requests.single.method, 'GET');
      expect(requests.single.uri.path, '/api/v2/help');
      expect(home.categories.single.slug, 'general');
      expect(home.featuredArticles.single.isFeatured, isTrue);
      expect(home.isSignedIn, isFalse);
    });

    test('loads a category and an article detail', () async {
      var call = 0;
      final service = HelpServiceV2(
        client: client((_) {
          call++;
          return call == 1
              ? ok({'data': homeData['categories'][0]})
              : ok({'data': articleData});
        }),
      );

      final category = await service.fetchCategory('getting-started');

      expect(requests.last.method, 'GET');
      expect(requests.last.uri.path, '/api/v2/help/categories/getting-started');
      expect(category.slug, 'general');

      final article = await service.fetchArticle('what-is-wavemart');

      expect(requests.last.uri.path, '/api/v2/help/articles/what-is-wavemart');
      expect(article.content, contains('marketplace'));
      expect(article.relatedArticles, hasLength(1));
    });

    test('lists articles with search filters and clamps the limit', () async {
      final service = HelpServiceV2(
        client: client((_) => ok(articlePage)),
      );

      final page = await service.fetchArticles(
        category: 'general',
        query: '  listing  ',
        limit: 80,
      );

      final request = requests.single;
      expect(request.uri.path, '/api/v2/help/articles');
      expect(request.uri.queryParameters['category'], 'general');
      expect(request.uri.queryParameters['q'], 'listing');
      expect(request.uri.queryParameters['limit'], '50');
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
    });

    test('records a vote and reports a repeat', () async {
      var call = 0;
      final service = HelpServiceV2(
        client: client((_) {
          call++;
          return ok({
            'data': {
              'article_id': 10,
              'is_helpful': true,
              'recorded': call == 1,
              'helpful_count': 22,
              'not_helpful_count': 1,
            },
          }, status: call == 1 ? 201 : 200);
        }),
      );

      final first = await service.submitArticleFeedback(
        'what-is-wavemart',
        isHelpful: true,
        comment: ' Clear explanation. ',
      );

      expect(requests.single.method, 'POST');
      expect(
        requests.single.uri.path,
        '/api/v2/help/articles/what-is-wavemart/feedback',
      );
      expect(requests.single.data, {
        'is_helpful': true,
        'comment': 'Clear explanation.',
      });
      expect(first.recorded, isTrue);

      final repeat = await service.submitArticleFeedback(
        'what-is-wavemart',
        isHelpful: true,
      );

      expect(repeat.recorded, isFalse);
      expect(repeat.alreadyVoted, isTrue);
    });
  });

  group('tickets', () {
    test('lists the user tickets', () async {
      final service = HelpServiceV2(
        client: client((_) => ok(ticketsPage)),
      );

      final page = await service.fetchTickets(limit: 10);

      expect(requests.single.method, 'GET');
      expect(requests.single.uri.path, '/api/v2/help/tickets');
      expect(requests.single.uri.queryParameters['limit'], '10');
      expect(page.items.single.status, HelpTicketStatus.inProgress);
      expect(page.items.single.hasUnreadMessages, isTrue);
    });

    test('creates a ticket with category and priority', () async {
      final service = HelpServiceV2(
        client: client((_) => ok({'data': ticketData}, status: 201)),
      );

      final ticket = await service.createTicket(
        categoryId: 2,
        subject: 'Cannot upload listing photos',
        message: 'The photo upload keeps failing for my new house listing.',
        priority: HelpTicketPriority.high,
      );

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/help/tickets');
      expect(requests.single.data, {
        'category_id': 2,
        'subject': 'Cannot upload listing photos',
        'message': 'The photo upload keeps failing for my new house listing.',
        'priority': 'high',
      });
      expect(ticket.ticketNumber, 'WM-2026-00001');
      expect(ticket.messages, hasLength(2));
    });

    test('loads one ticket', () async {
      final service = HelpServiceV2(
        client: client((_) => ok({'data': ticketData})),
      );

      final ticket = await service.fetchTicket('WM-2026-00001');

      expect(requests.single.uri.path, '/api/v2/help/tickets/WM-2026-00001');
      expect(ticket.subject, 'Cannot upload listing photos');
      expect(ticket.lastMessage?.isStaff, isTrue);
    });

    test('sends a JSON reply when there are no attachments', () async {
      final service = HelpServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'id': 60,
              'body': 'It happens on both networks.',
              'is_staff': false,
              'attachments': [],
              'is_read': false,
              'created_at': '2026-10-29T10:00:00Z',
            },
          }, status: 201),
        ),
      );

      final message = await service.sendMessage(
        'WM-2026-00001',
        message: 'It happens on both networks.',
      );

      expect(requests.single.method, 'POST');
      expect(
        requests.single.uri.path,
        '/api/v2/help/tickets/WM-2026-00001/messages',
      );
      expect(requests.single.data, {'message': 'It happens on both networks.'});
      expect(message.body, 'It happens on both networks.');
      expect(message.isStaff, isFalse);
    });

    test('uploads attachments as multipart', () async {
      final service = HelpServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'id': 61,
              'body': 'Screenshots attached.',
              'is_staff': false,
              'attachments': [
                {'url': 'https://cdn.test/attachments/one.jpg'},
              ],
              'is_read': false,
              'created_at': '2026-10-29T10:00:00Z',
            },
          }, status: 201),
        ),
      );

      final message = await service.sendMessage(
        'WM-2026-00001',
        message: 'Screenshots attached.',
        attachments: [file('one.jpg'), file('two.jpg')],
      );

      final form = requests.single.data as FormData;
      expect(form.fields.single.key, 'message');
      expect(form.fields.single.value, 'Screenshots attached.');
      expect(form.files, hasLength(2));
      expect(form.files.every((entry) => entry.key == 'attachments[]'), isTrue);
      expect(form.files.first.value.filename, 'one.jpg');
      expect(message.hasAttachments, isTrue);
    });

    test('rejects more than five attachments before sending', () async {
      final service = HelpServiceV2(client: client((_) => ok({})));

      expect(
        () => service.sendMessage(
          'WM-2026-00001',
          message: 'Too many files.',
          attachments: List.generate(6, (index) => file('$index.jpg')),
        ),
        throwsArgumentError,
      );
      expect(requests, isEmpty);
    });

    test('rates a resolved ticket', () async {
      final service = HelpServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'ticket_number': 'WM-2026-00001',
              'rating': 5,
              'comment': 'Resolved quickly.',
            },
          }),
        ),
      );

      final rating = await service.rateTicket(
        'WM-2026-00001',
        rating: 5,
        comment: 'Resolved quickly.',
      );

      expect(
        requests.single.uri.path,
        '/api/v2/help/tickets/WM-2026-00001/rating',
      );
      expect(requests.single.data, {
        'rating': 5,
        'comment': 'Resolved quickly.',
      });
      expect(rating.rating, 5);
      expect(rating.comment, 'Resolved quickly.');
    });

    test('surfaces an unresolved rating conflict', () async {
      final service = HelpServiceV2(
        client: client(
          (_) => ok({
            'error': {
              'code': 'CONFLICT',
              'message': 'Only resolved tickets can be rated.',
              'fields': <String, dynamic>{},
            },
          }, status: 409),
        ),
      );

      await expectLater(
        service.rateTicket('WM-2026-00001', rating: 5),
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
