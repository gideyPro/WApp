import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/data/models/v2/promo_models.dart';
import 'package:wavemart/data/services/v2/promo_service.dart';

void main() {
  late List<RequestOptions> requests;

  ApiV2Client createClient(ResponseBody Function(RequestOptions) handler) {
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

  group('Promo models JSON serialization', () {
    test('PromoValidationResult parses valid and invalid payloads', () {
      final valid = PromoValidationResult.fromJson({
        'valid': true,
        'code': 'WAVE-1234',
        'discount_percent': 15.0,
        'inviter_name': 'Abebe',
      });
      expect(valid.valid, isTrue);
      expect(valid.code, 'WAVE-1234');
      expect(valid.discountPercent, 15.0);
      expect(valid.inviterName, 'Abebe');

      final invalid = PromoValidationResult.fromJson({
        'valid': false,
        'message': 'Code does not exist',
      });
      expect(invalid.valid, isFalse);
      expect(invalid.message, 'Code does not exist');
    });

    test('PromoDashboardData parses stats, wallet and earnings list', () {
      final dashboard = PromoDashboardData.fromJson({
        'promo_code': 'WM-TEST99',
        'invite_link': 'https://wavemart.et/r/WM-TEST99',
        'discount_percentage': 10.0,
        'min_withdraw_amount': 500.0,
        'wallet_balance': 750.50,
        'can_withdraw': true,
        'stats': {
          'total_invited': 8,
          'total_subscribed': 3,
          'total_earned': 750.50,
        },
        'earnings': [
          {
            'id': 1,
            'invitee_name': 'Almaz',
            'plan_name': 'Standard Pro',
            'plan_base_price': 1000.0,
            'commission_percentage': 10.0,
            'earned_amount': 100.0,
            'status': 'available',
            'created_at': '2026-11-05T10:00:00Z',
          }
        ],
      });

      expect(dashboard.promoCode, 'WM-TEST99');
      expect(dashboard.canWithdraw, isTrue);
      expect(dashboard.walletBalance, 750.50);
      expect(dashboard.totalInvited, 8);
      expect(dashboard.totalSubscribed, 3);
      expect(dashboard.totalEarned, 750.50);
      expect(dashboard.earnings.length, 1);

      final item = dashboard.earnings.first;
      expect(item.inviteeName, 'Almaz');
      expect(item.planName, 'Standard Pro');
      expect(item.earnedAmount, 100.0);
      expect(item.planBasePrice, 1000.0);
    });
  });

  group('PromoServiceV2 API endpoints', () {
    test('validateCode posts code to /promo/validate', () async {
      final service = PromoServiceV2(
        client: createClient(
          (_) => ok({
            'data': {
              'valid': true,
              'code': 'WAVE-ABCD',
              'discount_percent': 10,
              'inviter_name': 'Kebede',
            }
          }),
        ),
      );

      final res = await service.validateCode('wave-abcd');
      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/promo-codes/validate');
      expect(requests.single.data, {'code': 'wave-abcd'});
      expect(res.valid, isTrue);
      expect(res.discountPercent, 10.0);
    });

    test('claimCode posts code to /promo/claim', () async {
      final service = PromoServiceV2(
        client: createClient(
          (_) => ok({
            'data': {
              'success': true,
              'discount_percent': 10,
            }
          }),
        ),
      );

      final res = await service.claimCode('WAVE-XYZ');
      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/promo/claim');
      expect(requests.single.data, {'code': 'WAVE-XYZ'});
      expect(res['success'], isTrue);
    });

    test('withdraw posts payout request to /promo/withdraw', () async {
      final service = PromoServiceV2(
        client: createClient(
          (_) => ok({
            'data': {
              'success': true,
              'message': 'Withdrawal submitted',
            }
          }),
        ),
      );

      final res = await service.withdraw(
        amount: 500.0,
        phoneNumber: '+251911223344',
        accountName: 'Dawit Mengistu',
      );
      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/promo/withdraw');
      expect(requests.single.data, {
        'amount': 500.0,
        'phone_number': '+251911223344',
        'account_name': 'Dawit Mengistu',
      });
      expect(res['success'], isTrue);
    });
  });
}

class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) _handler;

  _FakeAdapter(this._handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
