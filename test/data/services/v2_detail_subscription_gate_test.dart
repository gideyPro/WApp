import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_client.dart';
import 'package:wavemart/data/services/car_service.dart';
import 'package:wavemart/data/services/job_service.dart';
import 'package:wavemart/data/services/listing_service.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  (ApiClient, _StubAdapter) gatedClient() {
    final adapter = _StubAdapter((_) {
      return ResponseBody.fromString(
        jsonEncode({
          'error': {
            'code': 'SUBSCRIPTION_REQUIRED',
            'message': 'Your plan does not include VIP listings.',
            'fields': <String, dynamic>{},
          },
        }),
        403,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final apiClient = ApiClient();
    apiClient.dio.httpClientAdapter = adapter;
    return (apiClient, adapter);
  }

  test('listing detail maps SUBSCRIPTION_REQUIRED to a subscription gate',
      () async {
    final (apiClient, adapter) = gatedClient();

    final response =
        await ListingService(apiClient: apiClient).getListingDetail(1);

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, endsWith('/api/v2/listings/1'));
    expect(response.success, isFalse);
    expect(response.message, 'Your plan does not include VIP listings.');
    expect(response.subscriptionGate?.required, isTrue);
  });

  test('car detail maps SUBSCRIPTION_REQUIRED to a subscription gate',
      () async {
    final (apiClient, adapter) = gatedClient();

    final response = await CarService(apiClient: apiClient).getListingDetail(1);

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, endsWith('/api/v2/cars/1'));
    expect(response.success, isFalse);
    expect(response.message, 'Your plan does not include VIP listings.');
    expect(response.subscriptionGate?.required, isTrue);
  });

  test('job detail maps SUBSCRIPTION_REQUIRED to a subscription gate',
      () async {
    final (apiClient, adapter) = gatedClient();

    final response = await JobService(apiClient: apiClient).getListingDetail(1);

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, endsWith('/api/v2/jobs/1'));
    expect(response.success, isFalse);
    expect(response.message, 'Your plan does not include VIP listings.');
    expect(response.subscriptionGate?.required, isTrue);
  });
}
