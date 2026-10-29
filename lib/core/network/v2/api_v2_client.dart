import 'dart:io';

import 'package:dio/dio.dart';

import '../api_client.dart';
import 'api_v2_constants.dart';
import 'api_v2_error.dart';
import 'paginated.dart';

/// A decoded v2 response, including the headers callers may need for caching.
class ApiV2Document {
  final int statusCode;
  final Map<String, dynamic> data;
  final String? etag;

  const ApiV2Document({
    required this.statusCode,
    required this.data,
    this.etag,
  });

  bool get notModified => statusCode == 304;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Thin transport for the v2 contract.
///
/// Responsibilities:
///   * unwrap `{ data: ... }` and `{ data, meta }`
///   * convert every failure into [ApiV2Exception]
///   * expose ETag / 304 for cached endpoints
///
/// Authentication, locale headers and 401 session handling stay in the
/// existing [ApiClient] interceptors, so v1 and v2 share one login state.
class ApiV2Client {
  final Dio _dio;

  /// Production callers share [ApiClient] so v1 and v2 reuse one Dio with the
  /// auth/locale interceptors. Tests inject a bare [Dio] instead.
  ApiV2Client({ApiClient? apiClient, Dio? dio})
      : assert(
          apiClient == null || dio == null,
          'Pass either apiClient or dio, not both',
        ),
        _dio = dio ?? (apiClient ?? ApiClient()).dio;

  Dio get dio => _dio;

  /// Fetch a raw document. A 304 is returned instead of thrown so callers can
  /// reuse a cached payload.
  Future<ApiV2Document> fetch(
    String path, {
    Map<String, dynamic>? query,
    String? etag,
    CancelToken? cancelToken,
  }) async {
    final response = await _execute(
      () => dio.get<dynamic>(
        path,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            if (etag != null) HttpHeaders.ifNoneMatchHeader: etag,
          },
        ),
      ),
    );

    final statusCode = response.statusCode ?? 0;
    final responseEtag = response.headers.value(HttpHeaders.etagHeader);

    if (statusCode == HttpStatus.notModified) {
      return ApiV2Document(
        statusCode: statusCode,
        data: const {},
        etag: responseEtag ?? etag,
      );
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw _exceptionFrom(response);
    }

    return ApiV2Document(
      statusCode: statusCode,
      data: _asJsonMap(response.data),
      etag: responseEtag,
    );
  }

  /// Fetch a single resource and return its `data` object.
  Future<Map<String, dynamic>> getItem(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final document = await fetch(path, query: query, cancelToken: cancelToken);
    final data = document.data['data'];

    if (data is! Map) {
      throw ApiV2Exception.unexpected(
        'Expected an object at data for $path',
        statusCode: document.statusCode,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  /// Fetch a plain collection (`{ data: [ ... ] }`) with no pagination.
  Future<List<T>> getList<T>(
    String path, {
    required T Function(Map<String, dynamic> item) parse,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final document = await fetch(path, query: query, cancelToken: cancelToken);
    final data = document.data['data'];

    if (data is! List) {
      throw ApiV2Exception.unexpected(
        'Expected a list at data for $path',
        statusCode: document.statusCode,
      );
    }

    return data
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  /// Fetch a cursor-paginated collection.
  Future<Paginated<T>> getCollection<T>(
    String path, {
    required T Function(Map<String, dynamic> item) parse,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final document = await fetch(path, query: query, cancelToken: cancelToken);

    try {
      return Paginated.fromJson<T>(
        document.data,
        parse,
        fallbackPerPage: _limitFrom(query),
      );
    } on FormatException catch (error) {
      throw ApiV2Exception.unexpected(
        'Malformed collection for $path: ${error.message}',
        statusCode: document.statusCode,
      );
    }
  }

  /// Send a write request and return the raw document (may be empty for 204).
  Future<ApiV2Document> send(
    String path, {
    required String method,
    Object? body,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final response = await _execute(
      () => dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          contentType: Headers.jsonContentType,
        ),
      ),
    );

    final statusCode = response.statusCode ?? 0;

    if (statusCode < 200 || statusCode >= 300) {
      throw _exceptionFrom(response);
    }

    if (statusCode == HttpStatus.noContent || response.data == null) {
      return ApiV2Document(statusCode: statusCode, data: const {});
    }

    return ApiV2Document(
      statusCode: statusCode,
      data: _asJsonMap(response.data),
      etag: response.headers.value(HttpHeaders.etagHeader),
    );
  }

  /// Send a write request that returns `{ data: { ... } }`.
  Future<Map<String, dynamic>> sendItem(
    String path, {
    required String method,
    Object? body,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final document = await send(
      path,
      method: method,
      body: body,
      query: query,
      cancelToken: cancelToken,
    );
    final data = document.data['data'];

    if (data is! Map) {
      throw ApiV2Exception.unexpected(
        'Expected an object at data for $path',
        statusCode: document.statusCode,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  /// Send a multipart form (file upload) and return the raw document.
  Future<ApiV2Document> sendForm(
    String path, {
    required FormData formData,
    String method = 'POST',
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final response = await _execute(
      () => dio.request<dynamic>(
        path,
        data: formData,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(method: method),
      ),
    );

    final statusCode = response.statusCode ?? 0;

    if (statusCode < 200 || statusCode >= 300) {
      throw _exceptionFrom(response);
    }

    if (statusCode == HttpStatus.noContent || response.data == null) {
      return ApiV2Document(statusCode: statusCode, data: const {});
    }

    return ApiV2Document(
      statusCode: statusCode,
      data: _asJsonMap(response.data),
      etag: response.headers.value(HttpHeaders.etagHeader),
    );
  }

  /// Send a multipart form that returns `{ data: { ... } }`.
  Future<Map<String, dynamic>> sendFormItem(
    String path, {
    required FormData formData,
    String method = 'POST',
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final document = await sendForm(
      path,
      formData: formData,
      method: method,
      query: query,
      cancelToken: cancelToken,
    );
    final data = document.data['data'];

    if (data is! Map) {
      throw ApiV2Exception.unexpected(
        'Expected an object at data for $path',
        statusCode: document.statusCode,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  /// Send a multipart form that returns `{ data: [ ... ] }`.
  Future<List<T>> sendFormList<T>(
    String path, {
    required FormData formData,
    required T Function(Map<String, dynamic> item) parse,
    String method = 'POST',
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    final document = await sendForm(
      path,
      formData: formData,
      method: method,
      query: query,
      cancelToken: cancelToken,
    );
    final data = document.data['data'];

    if (data is! List) {
      throw ApiV2Exception.unexpected(
        'Expected a list at data for $path',
        statusCode: document.statusCode,
      );
    }

    return data
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<Response<dynamic>> _execute(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _exceptionFromDio(error);
    }
  }

  ApiV2Exception _exceptionFromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiV2Exception.timeout();
      case DioExceptionType.cancel:
        return ApiV2Exception.cancelled();
      case DioExceptionType.connectionError:
        return ApiV2Exception.network();
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) return _exceptionFrom(response);
        return ApiV2Exception.unexpected(error.message ?? 'Bad response');
      case DioExceptionType.badCertificate:
        return ApiV2Exception.network(
            'Could not verify the server certificate');
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return ApiV2Exception.network();
        }
        return ApiV2Exception.unexpected(error.message ?? 'Request failed');
    }
  }

  ApiV2Exception _exceptionFrom(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final body = response.data;
    final retryAfter = _retryAfter(response);

    if (body is Map && body['error'] is Map) {
      return ApiV2Exception(
        ApiV2Error.fromJson(
          body['error'],
          statusCode: statusCode,
          retryAfter: retryAfter,
        ),
      );
    }

    return ApiV2Exception(
      ApiV2Error(
        code: _codeForStatus(statusCode),
        message: _messageForStatus(statusCode),
        statusCode: statusCode,
        retryAfter: retryAfter,
      ),
    );
  }

  static Map<String, dynamic> _asJsonMap(dynamic body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    return const {};
  }

  static int _limitFrom(Map<String, dynamic>? query) {
    final raw = query?['limit'];
    final limit = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    if (limit == null || limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit ? ApiV2Constants.maxLimit : limit;
  }

  static Duration? _retryAfter(Response<dynamic> response) {
    final raw = response.headers.value(HttpHeaders.retryAfterHeader);
    final seconds = int.tryParse(raw ?? '');
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  static String _codeForStatus(int statusCode) {
    switch (statusCode) {
      case HttpStatus.unauthorized:
        return ApiV2ErrorCodes.unauthenticated;
      case HttpStatus.forbidden:
        return ApiV2ErrorCodes.forbidden;
      case HttpStatus.notFound:
        return ApiV2ErrorCodes.notFound;
      case HttpStatus.methodNotAllowed:
        return ApiV2ErrorCodes.methodNotAllowed;
      case HttpStatus.conflict:
        return ApiV2ErrorCodes.conflict;
      case HttpStatus.unprocessableEntity:
        return ApiV2ErrorCodes.validationFailed;
      case HttpStatus.tooManyRequests:
        return ApiV2ErrorCodes.rateLimited;
      default:
        return statusCode >= 500
            ? ApiV2ErrorCodes.serverError
            : ApiV2ErrorCodes.unknown;
    }
  }

  static String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case HttpStatus.unauthorized:
        return 'Please sign in to continue';
      case HttpStatus.forbidden:
        return 'You do not have access to this resource';
      case HttpStatus.notFound:
        return 'Resource not found';
      case HttpStatus.methodNotAllowed:
        return 'This action is not allowed';
      case HttpStatus.conflict:
        return 'The request conflicts with the current state';
      case HttpStatus.unprocessableEntity:
        return 'The given data was invalid';
      case HttpStatus.tooManyRequests:
        return 'Too many requests. Please try again shortly';
      default:
        return statusCode >= 500
            ? 'Something went wrong on our side'
            : 'Request failed';
    }
  }
}
