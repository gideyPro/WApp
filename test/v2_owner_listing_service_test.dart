import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_client.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';
import 'package:wavemart/data/models/v2/owner_listing.dart';
import 'package:wavemart/data/services/v2/listing_media_service.dart';
import 'package:wavemart/data/services/v2/owner_listing_service.dart';
import 'package:wavemart/data/services/v2/promotion_service.dart';

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

  Map<String, dynamic> fixtureItem() {
    final data = loadV2Fixture('my-listings.index.json')['data'] as List;
    return Map<String, dynamic>.from(data.single as Map);
  }

  group('owner feed', () {
    test('sends filters and clamps the page size', () async {
      final service = OwnerListingService(
        client: client((_) => ok(loadV2Fixture('my-listings.index.json'))),
      );

      final page = await service.fetch(
        type: ListingKind.house,
        status: OwnerListingStatus.active,
        cursor: 'next-page',
        limit: 500,
      );

      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/v2/me/listings');
      expect(request.queryParameters['type'], 'house');
      expect(request.queryParameters['status'], 'active');
      expect(request.queryParameters['cursor'], 'next-page');
      expect(request.queryParameters['limit'], 50);

      expect(page.items.single.id, 101);
      expect(page.items.single.status, OwnerListingStatus.active);
    });

    test('omits unknown type and status', () async {
      final service = OwnerListingService(
        client: client((_) => ok(loadV2Fixture('my-listings.index.json'))),
      );

      await service.fetch(type: ListingKind.unknown);

      final query = requests.single.queryParameters;
      expect(query.containsKey('type'), isFalse);
      expect(query.containsKey('status'), isFalse);
      expect(query['limit'], 20);
    });
  });

  group('draft writes', () {
    test('creates a property draft with the nested payload', () async {
      final service = OwnerListingService(
        client: client((_) => ok({'data': fixtureItem()}, status: 201)),
      );

      final payload = {
        'type': 'house',
        'submission_key': '3f4c2f2d-0000-4000-8000-000000000000',
        'price': 8500000,
        'attributes': {'total_square_meters': 320},
        'details': {'bedrooms': 4},
        'holding': {
          'type': 'Free Hold',
          'private': {'tax_paid_until_year': 2026},
        },
      };

      final listing = await service.createProperty(payload);

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v2/listings');
      expect(request.data, isA<Map>());
      expect((request.data as Map)['attributes'], {'total_square_meters': 320});
      expect(
          (request.data as Map)['submission_key'], payload['submission_key']);
      expect(listing.id, 101);
      expect(listing.canDelete, isTrue);
    });

    test('updates a car and submits through the generic route', () async {
      final service = OwnerListingService(
        client: client((options) {
          expect(options.method, anyOf('PATCH', 'POST'));
          return ok({'data': fixtureItem()});
        }),
      );

      await service.updateCar(88, {'make': 'Toyota', 'year': 2022});
      expect(requests.last.method, 'PATCH');
      expect(requests.last.uri.path, '/api/v2/cars/88');

      await service.submit(88);
      expect(requests.last.method, 'POST');
      expect(requests.last.uri.path, '/api/v2/listings/88/submit');
    });

    test('deletes an owned listing and accepts 204', () async {
      final service = OwnerListingService(
        client: client((_) => ResponseBody.fromString('', 204)),
      );

      await service.delete(88);

      expect(requests.single.method, 'DELETE');
      expect(requests.single.uri.path, '/api/v2/listings/88');
    });

    test('converts a conflict into a typed error', () async {
      final service = OwnerListingService(
        client: client(
          (_) => ok(
            {
              'error': {
                'code': 'CONFLICT',
                'message': 'This listing is under review.',
                'fields': <String, dynamic>{},
              },
            },
            status: 409,
          ),
        ),
      );

      await expectLater(
        service.submit(88),
        throwsA(
          isA<ApiV2Exception>()
              .having((error) => error.code, 'code', 'CONFLICT')
              .having((error) => error.statusCode, 'status', 409)
              .having(
                (error) => error.message,
                'message',
                contains('under review'),
              ),
        ),
      );
    });
  });

  group('media uploads', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('wavemart_v2_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    File file(String name, [List<int> bytes = const [1, 2, 3]]) {
      final file = File('${tempDir.path}/$name');
      file.writeAsBytesSync(bytes);
      return file;
    }

    test('uploads images as a multipart images[] field', () async {
      final service = ListingMediaServiceV2(
        client: client(
          (_) => ok({
            'data': [
              {
                'id': 1,
                'url': 'https://cdn.test/first.jpg',
                'is_primary': true,
              },
              {
                'id': 2,
                'url': 'https://cdn.test/second.jpg',
                'is_primary': false,
              },
            ],
          }, status: 201),
        ),
      );

      final images = await service.uploadImages(101, [
        file('first.jpg'),
        file('second.jpg'),
      ]);

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v2/listings/101/images');

      final form = request.data as FormData;
      expect(form.files, hasLength(2));
      expect(form.files[0].key, 'images[]');
      expect(form.files[0].value.filename, 'first.jpg');
      expect(form.files[1].key, 'images[]');

      expect(images, hasLength(2));
      expect(images.first.isPrimary, isTrue);
      expect(images.last.id, 2);
    });

    test('rejects an empty or oversized image batch before sending', () {
      final service = ListingMediaServiceV2(client: client((_) => ok({})));

      expect(
        () => service.uploadImages(101, const []),
        throwsArgumentError,
      );
      expect(
        () => service.uploadImages(
          101,
          List.generate(
              ListingMediaServiceV2.maxImages + 1, (i) => file('$i.jpg')),
        ),
        throwsArgumentError,
      );
      expect(requests, isEmpty);
    });

    test('uploads a video and parses the processing state', () async {
      final service = ListingMediaServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'status': 'pending',
              'url': 'https://cdn.test/tour.mp4',
              'thumbnail_url': null,
              'error_message': null,
              'uploaded_at': '2026-10-29T09:00:00Z',
            },
          }, status: 201),
        ),
      );

      final state = await service.uploadVideo(101, file('tour.mp4'));

      expect(requests.single.uri.path, '/api/v2/listings/101/video');
      final form = requests.single.data as FormData;
      expect(form.files.single.key, 'video');
      expect(form.files.single.value.filename, 'tour.mp4');
      expect(state.status, VideoStateStatus.pending);
      expect(state.status.isBusy, isTrue);
    });

    test('uploads a site plan and deletes it', () async {
      var call = 0;
      final service = ListingMediaServiceV2(
        client: client((_) {
          call++;
          if (call == 1) {
            return ok({
              'data': {'id': 9, 'url': 'https://cdn.test/site-plan.jpg'},
            }, status: 201);
          }
          return ResponseBody.fromString('', 204);
        }),
      );

      final asset = await service.uploadSitePlan(101, file('plan.jpg'));
      expect(asset.id, 9);
      expect(asset.hasUrl, isTrue);
      expect(requests.first.uri.path, '/api/v2/listings/101/site-plan');
      final form = requests.first.data as FormData;
      expect(form.files.single.key, 'file');

      await service.deleteSitePlan(101);
      expect(requests.last.method, 'DELETE');
      expect(requests.last.uri.path, '/api/v2/listings/101/site-plan');
    });
  });

  group('promotions', () {
    test('feature and unfeature return the current state', () async {
      var featured = false;
      final service = PromotionServiceV2(
        client: client((options) {
          featured = options.method == 'POST';
          return ok({
            'data': {
              'listing_id': 101,
              'is_featured': featured,
              'featured_until': featured ? '2026-11-28T08:00:00Z' : null,
              'is_vip': false,
            },
          });
        }),
      );

      final on = await service.feature(101);
      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/listings/101/feature');
      expect(on.isFeatured, isTrue);
      expect(on.featuredUntil?.toUtc(), DateTime.utc(2026, 11, 28, 8));

      final off = await service.unfeature(101);
      expect(requests.last.method, 'DELETE');
      expect(off.isFeatured, isFalse);
      expect(off.featuredUntil, isNull);
    });

    test('vip uses its own path', () async {
      final service = PromotionServiceV2(
        client: client(
          (_) => ok({
            'data': {
              'listing_id': 101,
              'is_featured': false,
              'featured_until': null,
              'is_vip': true,
            },
          }),
        ),
      );

      final state = await service.vip(101);

      expect(requests.single.method, 'POST');
      expect(requests.single.uri.path, '/api/v2/listings/101/vip');
      expect(state.isVip, isTrue);
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
