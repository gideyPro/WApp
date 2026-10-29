import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/models/v2/kyc_state.dart';
import 'package:wavemart/data/services/v2/kyc_service.dart';

import 'v2_fixtures.dart';

void main() {
  late List<RequestOptions> requests;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('kyc_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File file(String name) {
    final created = File('${tempDir.path}/$name')
      ..writeAsBytesSync(const [0xFF, 0xD8, 0xFF]);
    return created;
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

  final overviewData = loadV2Fixture('kyc.show.json')['data'];

  group('status', () {
    test('loads the overview from /kyc', () async {
      final service = KycServiceV2(
        client: client((_) => ok({'data': overviewData})),
      );

      final overview = await service.fetchStatus();

      expect(requests.single.method, 'GET');
      expect(requests.single.uri.path, '/api/v2/kyc');
      expect(overview.status, KycStatus.pending);
      expect(overview.canSubmit, isFalse);
    });
  });

  group('submission', () {
    test('uploads both document sides and the selfie as multipart', () async {
      final service = KycServiceV2(
        client: client((_) => ok({'data': overviewData}, status: 201)),
      );

      final overview = await service.submit(
        documentType: 'national_id',
        frontImage: file('front.jpg'),
        backImage: file('back.jpg'),
        selfieImage: file('selfie.jpg'),
      );

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v2/kyc');

      final form = request.data as FormData;
      expect(form.fields.single.key, 'document_type');
      expect(form.fields.single.value, 'national_id');
      expect(
        form.files.map((entry) => entry.key),
        containsAll(['front_image', 'back_image', 'selfie_image']),
      );
      expect(
        form.files
            .firstWhere((entry) => entry.key == 'selfie_image')
            .value
            .filename,
        'selfie.jpg',
      );

      expect(overview.status, KycStatus.pending);
    });

    test('omits back_image for a passport', () async {
      final service = KycServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'verified': false,
              'status': 'pending',
              'can_submit': false,
              'verification': {
                'id': 10,
                'document_type': 'passport',
                'status': 'pending',
                'rejection_reason': null,
                'submitted_at': '2026-10-29T09:00:00Z',
                'verified_at': null,
              },
            },
          }, status: 201),
        ),
      );

      await service.submit(
        documentType: 'passport',
        frontImage: file('front.jpg'),
        selfieImage: file('selfie.jpg'),
      );

      final form = requests.single.data as FormData;
      expect(
        form.files.map((entry) => entry.key),
        isNot(contains('back_image')),
      );
      expect(form.files, hasLength(2));
    });

    test('surfaces a pending-review conflict as a typed error', () async {
      final service = KycServiceV2(
        client: client(
          (_) => ok(
            {
              'error': {
                'code': 'CONFLICT',
                'message': 'You already have a pending verification request.',
                'fields': <String, dynamic>{},
              },
            },
            status: 409,
          ),
        ),
      );

      await expectLater(
        service.submit(
          documentType: 'national_id',
          frontImage: file('front.jpg'),
          backImage: file('back.jpg'),
          selfieImage: file('selfie.jpg'),
        ),
        throwsA(
          isA<ApiV2Exception>()
              .having((error) => error.code, 'code', 'CONFLICT')
              .having((error) => error.statusCode, 'status', 409),
        ),
      );
    });
  });

  group('phone change', () {
    test('sends and verifies the OTP', () async {
      var call = 0;
      final service = KycServiceV2(
        client: client((_) {
          call++;
          if (call == 1) {
            return ok({
              'data': {
                'channel': 'sms',
                'destination': '+251911000109',
              },
            });
          }
          return ok({
            'data': {
              'phone_number': '+251911000109',
              'phone_verified': true,
            },
          });
        }),
      );

      final dispatch = await service.sendPhoneOtp('0911000109');

      expect(requests.last.method, 'POST');
      expect(requests.last.uri.path, '/api/v2/kyc/phone/send-otp');
      expect(requests.last.data, {'phone_number': '0911000109'});
      expect(dispatch.sentBySms, isTrue);

      final verified = await service.verifyPhoneOtp(
        phoneNumber: '+251911000109',
        otpCode: '123456',
      );

      expect(requests.last.uri.path, '/api/v2/kyc/phone/verify');
      expect(requests.last.data, {
        'phone_number': '+251911000109',
        'otp_code': '123456',
      });
      expect(verified.phoneNumber, '+251911000109');
      expect(verified.phoneVerified, isTrue);
    });

    test('surfaces a rate limit with retry information', () async {
      final service = KycServiceV2(
        client: client(
          (_) => ResponseBody.fromString(
            jsonEncode({
              'error': {
                'code': 'RATE_LIMITED',
                'message': 'Too many failed attempts.',
                'fields': <String, dynamic>{},
              },
            }),
            429,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
              'retry-after': ['900'],
            },
          ),
        ),
      );

      await expectLater(
        service.sendPhoneOtp('+251911000109'),
        throwsA(
          isA<ApiV2Exception>()
              .having((error) => error.code, 'code', 'RATE_LIMITED')
              .having(
                (error) => error.retryAfter,
                'retryAfter',
                const Duration(seconds: 900),
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
