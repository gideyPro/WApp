import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_client.dart';
import 'package:wavemart/data/services/job_service.dart';
import 'package:wavemart/presentation/providers/job_providers.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

  group('JobDetailNotifier', () {
    test('deleteListing returns null on success', () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        expect(options.method, 'DELETE');
        expect(options.path, contains('/jobs/42'));
        return ResponseBody.fromString(
          jsonEncode({'success': true, 'message': 'Job listing deleted'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final jobService = JobService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          jobServiceProvider.overrideWithValue(jobService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(jobDetailProvider.notifier);
      final error = await notifier.deleteListing(42);

      expect(error, isNull);
    });

    test('deleteListing returns error message on failure', () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({'success': false, 'message': 'Unauthorized'}),
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final jobService = JobService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          jobServiceProvider.overrideWithValue(jobService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(jobDetailProvider.notifier);
      final error = await notifier.deleteListing(42);

      expect(error, equals('Unauthorized'));
    });
  });
}
