import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/models/v2/payment_state.dart';
import 'package:wavemart/data/services/v2/payment_service.dart';
import 'package:wavemart/data/services/v2/subscription_service.dart';

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

  final overviewData = loadV2Fixture('subscription.show.json')['data'];

  group('subscription overview and checkout', () {
    test('loads the overview from /subscription', () async {
      final service = SubscriptionServiceV2(
        client: client((_) => ok({'data': overviewData})),
      );

      final overview = await service.fetchOverview();

      expect(requests.single.method, 'GET');
      expect(requests.single.uri.path, '/api/v2/subscription');
      expect(overview.subscription?.plan?.slug, 'free');
      expect(overview.capabilities.maxListings?.max, 0);
    });

    test('checkout sends only the cycle and currency', () async {
      final service = SubscriptionServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'activated': false,
              'checkout_url': 'https://checkout.chapa.test/abc',
              'payment': null,
              'subscription': null,
            },
          }, status: 201),
        ),
      );

      final result = await service.checkout(2, cycleMonths: 3);

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v2/subscriptions/2/checkout');
      expect(request.data, {'cycle_months': 3, 'currency': 'ETB'});
      expect(result.needsGateway, isTrue);
    });

    test('omits cycle_months so the server picks the first cycle', () async {
      final service = SubscriptionServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'activated': true,
              'checkout_url': null,
              'payment': null,
              'subscription': null,
            },
          }),
        ),
      );

      await service.checkout(1);

      expect(requests.single.data, {'currency': 'ETB'});
    });

    test('startTrial posts to the plan trial route', () async {
      final service = SubscriptionServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'id': 15,
              'status': 'active',
              'plan': {'id': 2, 'slug': 'basic', 'name': 'Basic'},
              'billing_cycle_months': 1,
              'listing_duration_days': 30,
              'is_active': true,
              'is_trial': true,
            },
          }, status: 201),
        ),
      );

      final subscription = await service.startTrial(2);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/subscriptions/2/trial');
      expect(subscription.isTrial, isTrue);
      expect(subscription.isOnTrial, isTrue);
    });
  });

  group('payments', () {
    test('lists payments with filters and clamps the limit', () async {
      final service = PaymentServiceV2(
        client: client((_) => ok(loadV2Fixture('payments.index.json'))),
      );

      final page = await service.fetch(
        status: PaymentStatusV2.success,
        type: 'subscription',
        cursor: 'next',
        limit: 500,
      );

      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v2/payments');
      expect(request.queryParameters['status'], 'success');
      expect(request.queryParameters['type'], 'subscription');
      expect(request.queryParameters['cursor'], 'next');
      expect(request.queryParameters['limit'], 50);

      expect(page.items.single.txRef, 'wm-sub-20261029-abc123');
    });

    test('omits unknown status and blank type', () async {
      final service = PaymentServiceV2(
        client: client((_) => ok(loadV2Fixture('payments.index.json'))),
      );

      await service.fetch(status: PaymentStatusV2.unknown, type: '');

      final query = requests.single.queryParameters;
      expect(query.containsKey('status'), isFalse);
      expect(query.containsKey('type'), isFalse);
      expect(query['limit'], 20);
    });

    test('fetches, verifies and cancels by tx_ref', () async {
      var call = 0;
      final service = PaymentServiceV2(
        client: client((options) {
          call++;
          if (call == 1) {
            return ok({
              'data': {
                'id': 32,
                'tx_ref': 'tx-paid',
                'type': 'subscription',
                'status': 'pending',
                'amount': 1350,
                'currency': 'ETB',
                'plan': null,
              },
            });
          }
          if (call == 2) {
            return ok({
              'data': {
                'status': 'success',
                'payment': {
                  'id': 32,
                  'tx_ref': 'tx-paid',
                  'type': 'subscription',
                  'status': 'success',
                  'amount': 1350,
                  'currency': 'ETB',
                  'plan': null,
                  'activated_at': '2026-10-29T09:05:10Z',
                },
                'subscription': null,
              },
            });
          }
          return ok({
            'data': {
              'id': 32,
              'tx_ref': 'tx-paid',
              'type': 'subscription',
              'status': 'cancelled',
              'amount': 1350,
              'currency': 'ETB',
              'plan': null,
            },
          });
        }),
      );

      final payment = await service.fetchOne('tx-paid');
      expect(payment.isPending, isTrue);
      expect(requests.last.uri.path, '/api/v2/payments/tx-paid');

      final verification = await service.verify('tx-paid');
      expect(verification.isSuccess, isTrue);
      expect(verification.payment.isActivated, isTrue);
      expect(requests.last.method, 'POST');
      expect(requests.last.uri.path, '/api/v2/payments/tx-paid/verify');

      final cancelled = await service.cancel('tx-paid');
      expect(cancelled.status, PaymentStatusV2.cancelled);
      expect(requests.last.method, 'POST');
      expect(requests.last.uri.path, '/api/v2/payments/tx-paid/cancel');
    });

    test('surfaces a cancellation conflict as a typed error', () async {
      final service = PaymentServiceV2(
        client: client(
          (_) => ok(
            {
              'error': {
                'code': 'CONFLICT',
                'message': 'Only pending payments can be cancelled.',
                'fields': <String, dynamic>{},
              },
            },
            status: 409,
          ),
        ),
      );

      await expectLater(
        service.cancel('tx-paid'),
        throwsA(
          isA<ApiV2Exception>()
              .having((error) => error.code, 'code', 'CONFLICT')
              .having((error) => error.statusCode, 'status', 409)
              .having(
                (error) => error.message,
                'message',
                contains('pending payments'),
              ),
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
