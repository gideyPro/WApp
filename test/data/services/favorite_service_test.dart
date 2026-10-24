import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_client.dart';
import 'package:wavemart/data/services/favorite_service.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('toggleFavorite extracts added flag from root and data payload', () async {
    final clientWithRootAdded = ApiClient();
    clientWithRootAdded.dio.httpClientAdapter = _StubAdapter({
      'success': true,
      'message': 'Added to favorites',
      'added': true,
    });
    final service1 = FavoriteService(apiClient: clientWithRootAdded);
    final res1 = await service1.toggleFavorite(12);
    expect(res1.success, isTrue);
    expect(res1.isFavorite, isTrue);

    final clientWithNestedAdded = ApiClient();
    clientWithNestedAdded.dio.httpClientAdapter = _StubAdapter({
      'success': true,
      'message': 'Removed from favorites',
      'data': {'added': false},
    });
    final service2 = FavoriteService(apiClient: clientWithNestedAdded);
    final res2 = await service2.toggleFavorite(12);
    expect(res2.success, isTrue);
    expect(res2.isFavorite, isFalse);
  });
}
