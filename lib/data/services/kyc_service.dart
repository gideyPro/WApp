import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';

/// Service for KYC (Know Your Customer) verification
class KycService {
  final ApiClient _apiClient;

  KycService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<KycStatusResponse> getKycStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.kycStatus);

      if (response.statusCode == 200 && response.data is Map) {
        final data = ApiEnvelope.extractData(response.data);
        final verification = data['verification'] is Map
            ? Map<String, dynamic>.from(data['verification'] as Map)
            : <String, dynamic>{};

        return KycStatusResponse(
          success: true,
          status: verification['verified'] != true
              ? (verification['status']?.toString() ?? 'none')
              : 'approved',
          isVerified: verification['verified'] == true,
          documentType: verification['document_type']?.toString() ?? data['document_type']?.toString(),
          rejectionReason:
              verification['rejection_reason']?.toString() ?? data['rejection_reason']?.toString(),
          submittedAt: verification['submitted_at']?.toString() ?? data['submitted_at']?.toString(),
          verifiedAt: verification['verified_at']?.toString() ?? data['verified_at']?.toString(),
        );
      }

      return const KycStatusResponse(
        success: false,
        status: 'none',
        isVerified: false,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return KycStatusResponse(
        success: false,
        status: 'error',
        isVerified: false,
        errorMessage: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Submit KYC documents
  ///
  /// [documentType]: national_id or passport
  /// [frontImage]: Front side of document
  /// [backImage]: Back side (optional for passport)
  /// [selfieImage]: Selfie with document
  Future<KycResponse> submitKyc({
    required String documentType,
    required File frontImage,
    File? backImage,
    File? selfieImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document_type': documentType,
        'front_image': await MultipartFile.fromFile(
          frontImage.path,
          filename: frontImage.path.split('/').last,
        ),
        if (backImage != null)
          'back_image': await MultipartFile.fromFile(
            backImage.path,
            filename: backImage.path.split('/').last,
          ),
        if (selfieImage != null)
          'selfie_image': await MultipartFile.fromFile(
            selfieImage.path,
            filename: selfieImage.path.split('/').last,
          ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.kycSubmit,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return KycResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'KYC submitted successfully'),
        );
      }

      return KycResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'KYC submission failed'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return KycResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<KycFormDataResponse> getKycFormData() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.kycCreate);

      if (response.statusCode == 200 && response.data is Map) {
        final data = ApiEnvelope.extractData(response.data);
        return KycFormDataResponse(
          success: true,
          data: data,
        );
      }

      return KycFormDataResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch KYC form'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return KycFormDataResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

class KycStatusResponse {
  final bool success;
  final String status; // none, pending, approved, rejected, error
  final bool isVerified;
  final String? documentType;
  final String? rejectionReason;
  final String? submittedAt;
  final String? verifiedAt;
  final String? errorMessage;

  const KycStatusResponse({
    required this.success,
    required this.status,
    required this.isVerified,
    this.documentType,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
    this.errorMessage,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isNone => status == 'none' || status.isEmpty;
}

class KycResponse {
  final bool success;
  final String message;

  const KycResponse({
    required this.success,
    this.message = '',
  });
}

class KycFormDataResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const KycFormDataResponse({
    required this.success,
    this.message = '',
    this.data,
  });
}
