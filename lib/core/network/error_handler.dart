import 'package:dio/dio.dart';
import 'v2/api_v2_error.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => 'ApiException: $message';
}

/// Network exception
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Unauthorized exception (401)
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Session expired']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Server error exception (5xx)
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

/// Parse exceptions into custom exceptions
class ApiErrorHandler {
  static Exception handle(dynamic error) {
    if (error is ApiV2Exception) {
      if (error.isUnauthenticated) {
        return const UnauthorizedException();
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return const ServerException();
      }
      if (error.code == ApiV2ErrorCodes.networkError ||
          error.code == ApiV2ErrorCodes.timeout) {
        return NetworkException(error.message);
      }
      if (error.isValidation && error.error.allFieldMessages.isNotEmpty) {
        return ApiException(
          message: error.error.allFieldMessages.join('\n'),
          statusCode: error.statusCode,
          code: error.code,
        );
      }
      return ApiException(
        message: error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }

    if (error is ApiException) return error;
    if (error is NetworkException) return error;
    if (error is UnauthorizedException) return error;
    if (error is ServerException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException('Connection timeout');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _extractErrorMessage(error.response?.data);

          // Handle redirect responses (3xx) as connection errors
          if (statusCode != null && statusCode >= 300 && statusCode < 400) {
            return const NetworkException('Server redirect issue. Check API configuration.');
          }

          if (statusCode == 401) {
            return const UnauthorizedException();
          }

          if (statusCode != null && statusCode >= 500) {
            return const ServerException();
          }

          return ApiException(
            message: message ?? 'Request failed',
            statusCode: statusCode,
          );

        case DioExceptionType.cancel:
          return const ApiException(message: 'Request cancelled');

        case DioExceptionType.connectionError:
          return const NetworkException('No internet connection');

        default:
          return ApiException(message: error.message ?? 'Unknown error occurred');
      }
    }

    final raw = error.toString().replaceFirst(
          RegExp(r'^(Exception|Error|ApiV2Exception|ApiException):\s*'),
          '',
        );
    return ApiException(message: raw);
  }

  /// Get user-friendly error message from any exception or error
  static String getMessage(dynamic error) {
    if (error is ApiV2Exception) {
      if (error.isValidation && error.error.allFieldMessages.isNotEmpty) {
        return error.error.allFieldMessages.join('\n');
      }
      return error.message;
    }
    final exception = handle(error);
    if (exception is ApiException) return exception.message;
    if (exception is NetworkException) return exception.message;
    if (exception is UnauthorizedException) return exception.message;
    if (exception is ServerException) return exception.message;
    return exception.toString().replaceFirst(RegExp(r'^\w+:\s*'), '');
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message'] ??
          data['error'] ??
          data['errors']?.toString() ??
          data['detail']?.toString();
    }

    return data?.toString();
  }
}
