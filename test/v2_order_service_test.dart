import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/models/v2/buyer_order.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';
import 'package:wavemart/data/services/v2/order_service.dart';

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

  final orderData = loadV2Fixture('orders.show.json')['data'];
  final indexPage = loadV2Fixture('orders.index.json');
  final suggestionsPage = loadV2Fixture('orders.suggestions.index.json');
  final pendingSuggestion =
      (suggestionsPage['data'] as List).first as Map<String, dynamic>;

  group('read', () {
    test('lists with filters, cursor and a clamped limit', () async {
      final service = OrderServiceV2(
        client: client((_) => ok(indexPage)),
      );

      final page = await service.fetch(
        status: BuyerOrderStatus.active,
        type: ListingKind.house,
        listingType: 'rental',
        cursor: 'abc',
        limit: 80,
      );

      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v2/orders');
      expect(request.uri.queryParameters['status'], 'active');
      expect(request.uri.queryParameters['type'], 'house');
      expect(request.uri.queryParameters['listing_type'], 'rental');
      expect(request.uri.queryParameters['cursor'], 'abc');
      expect(request.uri.queryParameters['limit'], '50');
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
    });

    test('omits unknown filters from the query', () async {
      final service = OrderServiceV2(
        client: client((_) => ok(indexPage)),
      );

      await service.fetch(
        status: BuyerOrderStatus.unknown,
        type: ListingKind.unknown,
      );

      final query = requests.single.uri.queryParameters;
      expect(query.containsKey('status'), isFalse);
      expect(query.containsKey('type'), isFalse);
      expect(query['limit'], '20');
    });

    test('loads one order', () async {
      final service = OrderServiceV2(
        client: client((_) => ok({'data': orderData})),
      );

      final order = await service.fetchOrder(1204);

      expect(requests.single.method, 'GET');
      expect(requests.single.uri.path, '/api/v2/orders/1204');
      expect(order.id, 1204);
      expect(order.suggestionsCount, 2);
    });

    test('lists suggestions with pagination', () async {
      final service = OrderServiceV2(
        client: client((_) => ok(suggestionsPage)),
      );

      final page = await service.fetchSuggestions(
        1204,
        cursor: 'next',
        limit: 10,
      );

      final request = requests.single;
      expect(request.uri.path, '/api/v2/orders/1204/suggestions');
      expect(request.uri.queryParameters['cursor'], 'next');
      expect(request.uri.queryParameters['limit'], '10');
      expect(page.items.single.listing?.id, 4821);
    });
  });

  group('writes', () {
    test('creates an order with the caller payload', () async {
      final service = OrderServiceV2(
        client: client((_) => ok({'data': orderData}, status: 201)),
      );

      const payload = {
        'submission_key': 'order-key-1',
        'type': 'house',
        'listing_type': 'sale',
        'description': 'Looking for a family house near schools.',
        'budget': {'min': 1000000, 'max': 5000000},
        'area': {'min': 120, 'max': 400},
        'attributes': {
          'holding_type': 'Free Hold',
          'facing_direction': 'north',
        },
      };

      final order = await service.create(payload);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/orders');
      expect(requests.single.data, payload);
      expect(order.id, 1204);
      expect(order.status, BuyerOrderStatus.active);
    });

    test('cancels an order', () async {
      final service = OrderServiceV2(
        client: client(
          (_) => ok({
            'data': {...orderData, 'status': 'cancelled'},
          }),
        ),
      );

      final order = await service.cancel(1204);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/orders/1204/cancel');
      expect(requests.single.data, isNull);
      expect(order.status, BuyerOrderStatus.cancelled);
      expect(order.canCancel, isFalse);
    });

    test('accepts and declines suggestions', () async {
      var call = 0;
      final service = OrderServiceV2(
        client: client((_) {
          call++;
          return ok({
            'data': {
              ...pendingSuggestion,
              'status': call == 1 ? 'accepted' : 'declined',
              'stage': call == 1 ? 'negotiating' : 'lost',
              'can_accept': false,
              'can_decline': false,
            },
          });
        }),
      );

      final accepted = await service.acceptSuggestion(1204, 9001);

      expect(requests.last.method, 'POST');
      expect(
        requests.last.uri.path,
        '/api/v2/orders/1204/suggestions/9001/accept',
      );
      expect(accepted.status, OrderSuggestionStatus.accepted);
      expect(accepted.canAccept, isFalse);
      expect(accepted.hasListing, isTrue);

      final declined = await service.declineSuggestion(1204, 9001);

      expect(
        requests.last.uri.path,
        '/api/v2/orders/1204/suggestions/9001/decline',
      );
      expect(declined.status, OrderSuggestionStatus.declined);
    });

    test('surfaces an opposite-action conflict', () async {
      final service = OrderServiceV2(
        client: client(
          (_) => ok({
            'error': {
              'code': 'CONFLICT',
              'message': 'This suggestion was already accepted.',
              'fields': <String, dynamic>{},
            },
          }, status: 409),
        ),
      );

      await expectLater(
        service.declineSuggestion(1204, 9001),
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
