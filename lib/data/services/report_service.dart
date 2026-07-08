import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';

class ReportService {
  final ApiClient _apiClient;

  ReportService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ReportResponse> submitReport({
    required String reportableType,
    required int reportableId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.reports,
        data: {
          'reportable_type': reportableType,
          'reportable_id': reportableId,
          'reason': reason,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ReportResponse(
          success: true,
          message: 'Report submitted successfully.',
        );
      }

      return ReportResponse(
        success: false,
        message: ApiEnvelope.extractMessage(
          response.data,
          'Failed to submit report.',
        ),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ReportResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

class ReportResponse {
  final bool success;
  final String message;

  const ReportResponse({
    required this.success,
    this.message = '',
  });
}
