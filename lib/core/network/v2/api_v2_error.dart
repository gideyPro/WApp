/// Error codes emitted by the v2 API contract.
///
/// The backend owns the server-side codes; the client-side constants at the
/// bottom cover transport failures that never reach Laravel.
abstract final class ApiV2ErrorCodes {
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String forbidden = 'FORBIDDEN';
  static const String subscriptionRequired = 'SUBSCRIPTION_REQUIRED';
  static const String kycRequired = 'KYC_REQUIRED';
  static const String notFound = 'NOT_FOUND';
  static const String methodNotAllowed = 'METHOD_NOT_ALLOWED';
  static const String conflict = 'CONFLICT';
  static const String validationFailed = 'VALIDATION_FAILED';
  static const String rateLimited = 'RATE_LIMITED';
  static const String serverError = 'SERVER_ERROR';

  // Client-side only.
  static const String networkError = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String cancelled = 'CANCELLED';
  static const String unexpectedResponse = 'UNEXPECTED_RESPONSE';
  static const String unknown = 'UNKNOWN';
}

/// The `error` object from a v2 failure response:
///
/// ```json
/// { "error": { "code": "VALIDATION_FAILED", "message": "...", "fields": {} } }
/// ```
class ApiV2Error {
  final String code;
  final String message;
  final Map<String, List<String>> fields;
  final int? statusCode;
  final Duration? retryAfter;

  const ApiV2Error({
    required this.code,
    required this.message,
    this.fields = const {},
    this.statusCode,
    this.retryAfter,
  });

  factory ApiV2Error.fromJson(
    dynamic json, {
    int? statusCode,
    Duration? retryAfter,
  }) {
    if (json is Map) {
      final rawFields = json['fields'];
      return ApiV2Error(
        code: (json['code'] ?? ApiV2ErrorCodes.unknown).toString(),
        message: (json['message'] ?? 'Request failed').toString(),
        fields: _parseFields(rawFields),
        statusCode: statusCode,
        retryAfter: retryAfter,
      );
    }

    return ApiV2Error(
      code: ApiV2ErrorCodes.unknown,
      message: json?.toString() ?? 'Request failed',
      statusCode: statusCode,
      retryAfter: retryAfter,
    );
  }

  bool get isValidation => code == ApiV2ErrorCodes.validationFailed;

  bool get isUnauthenticated => code == ApiV2ErrorCodes.unauthenticated;

  bool get isForbidden => code == ApiV2ErrorCodes.forbidden;

  bool get requiresSubscription =>
      code == ApiV2ErrorCodes.subscriptionRequired;

  bool get requiresKyc => code == ApiV2ErrorCodes.kycRequired;

  bool get isRateLimited => code == ApiV2ErrorCodes.rateLimited;

  bool get isServerError => code == ApiV2ErrorCodes.serverError;

  /// First message for [field], or null when the field has no error.
  String? fieldError(String field) {
    final messages = fields[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }

  /// All messages flattened, useful for a snackbar or form summary.
  List<String> get allFieldMessages =>
      fields.values.expand((messages) => messages).toList(growable: false);

  static Map<String, List<String>> _parseFields(dynamic raw) {
    if (raw is! Map) return const {};

    final parsed = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value == null) return;

      if (value is List) {
        final messages = value
            .where((message) => message != null)
            .map((message) => message.toString())
            .toList(growable: false);
        if (messages.isNotEmpty) parsed[key.toString()] = messages;
        return;
      }

      if (value is Map) {
        final nested = _parseFields(value);
        if (nested.isNotEmpty) {
          parsed[key.toString()] =
              nested.values.expand((messages) => messages).toList();
        }
        return;
      }

      parsed[key.toString()] = [value.toString()];
    });

    return parsed;
  }
}

/// Typed exception for every v2 request failure.
///
/// Deliberately separate from the legacy `ApiException` in
/// `core/network/error_handler.dart`; V1 services keep using that class.
class ApiV2Exception implements Exception {
  final ApiV2Error error;

  const ApiV2Exception(this.error);

  factory ApiV2Exception.network([String? message]) => ApiV2Exception(
        ApiV2Error(
          code: ApiV2ErrorCodes.networkError,
          message: message ?? 'No internet connection',
        ),
      );

  factory ApiV2Exception.timeout([String? message]) => ApiV2Exception(
        ApiV2Error(
          code: ApiV2ErrorCodes.timeout,
          message: message ?? 'The request timed out',
        ),
      );

  factory ApiV2Exception.cancelled() => const ApiV2Exception(
        ApiV2Error(
          code: ApiV2ErrorCodes.cancelled,
          message: 'Request cancelled',
        ),
      );

  factory ApiV2Exception.unexpected(
    String message, {
    int? statusCode,
  }) =>
      ApiV2Exception(
        ApiV2Error(
          code: ApiV2ErrorCodes.unexpectedResponse,
          message: message,
          statusCode: statusCode,
        ),
      );

  String get code => error.code;
  String get message => error.message;
  int? get statusCode => error.statusCode;
  Map<String, List<String>> get fields => error.fields;
  Duration? get retryAfter => error.retryAfter;

  bool get isUnauthenticated => error.isUnauthenticated;
  bool get isForbidden => error.isForbidden;
  bool get requiresSubscription => error.requiresSubscription;
  bool get requiresKyc => error.requiresKyc;
  bool get isValidation => error.isValidation;
  bool get isRateLimited => error.isRateLimited;

  @override
  String toString() => 'ApiV2Exception($code, $statusCode): $message';
}
