import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_client.dart';
import 'package:wavemart/data/services/job_seeker_service.dart';

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

  Map<String, dynamic> profileJson() => {
        'id': 1,
        'user_id': 1,
        'professional_title': 'Engineer',
        'full_name': 'Test User',
        'education_level': 'bachelors',
        'is_public': true,
      };

  Map<String, dynamic> profilePayload() => {
        'full_name': 'Test User',
        'professional_title': 'Engineer',
        'education_level': 'bachelors',
        'description': 'About me',
        'is_public': '1',
        'educations': [
          {'education_level': 'bachelors', 'field_of_study': 'Computer Science'},
        ],
        'experiences': [
          {'job_title': 'Developer', 'company': 'ACME', 'years': 2},
        ],
      };

  Future<Map<String, dynamic>> captureRequest({required bool update}) async {
    final client = ApiClient();
    client.dio.httpClientAdapter = _StubAdapter({
      'success': true,
      'message': 'ok',
      'data': profileJson(),
    });

    final captured = <String, dynamic>{};
    client.dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured['method'] = options.method;
          final data = options.data;
          if (data is FormData) {
            captured['fields'] = {
              for (final field in data.fields) field.key: field.value,
            };
          }
          handler.next(options);
        },
      ),
    );

    await JobSeekerService(apiClient: client).createOrUpdateProfile(
      data: profilePayload(),
      update: update,
    );

    return captured;
  }

  test('profile update is sent as POST with Laravel method spoofing', () async {
    final captured = await captureRequest(update: true);

    // PHP does not parse multipart bodies on PUT, so the app must POST and
    // let Laravel spoof the method from the _method field.
    expect(captured['method'], 'POST');
    final fields = captured['fields'] as Map<String, dynamic>;
    expect(fields['_method'], 'PUT');
    expect(fields['professional_title'], 'Engineer');
    expect(fields['educations[0][education_level]'], 'bachelors');
    expect(fields['experiences[0][company]'], 'ACME');
  });

  test('profile creation is sent as POST without method spoofing', () async {
    final captured = await captureRequest(update: false);

    expect(captured['method'], 'POST');
    final fields = captured['fields'] as Map<String, dynamic>;
    expect(fields.containsKey('_method'), isFalse);
  });
}
