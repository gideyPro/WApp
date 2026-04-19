import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';

/// Service for KYC (Know Your Customer) verification
class KycService {
  final ApiClient _apiClient;

  KycService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get KYC status
  Future<KycStatusResponse> getKycStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.kycStatus);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final verification = data['verification'] ?? {};

        return KycStatusResponse(
          success: true,
          status: verification['verified'] != true
              ? (verification['status'] ?? 'none')
              : 'approved',
          isVerified: verification['verified'] ?? false,
          documentType: verification['document_type'] ?? data['document_type'],
          rejectionReason:
              verification['rejection_reason'] ?? data['rejection_reason'],
          submittedAt: verification['submitted_at'] ?? data['submitted_at'],
          verifiedAt: verification['verified_at'] ?? data['verified_at'],
        );
      }

      return const KycStatusResponse(
        success: false,
        status: 'none',
        isVerified: false,
      );
    } catch (e) {
      return const KycStatusResponse(
        success: false,
        status: 'none',
        isVerified: false,
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
          message: response.data['message'] ?? 'KYC submitted successfully',
        );
      }

      return KycResponse(
        success: false,
        message: response.data['message'] ?? 'KYC submission failed',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return KycResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get KYC form data (document types, requirements)
  Future<KycFormDataResponse> getKycFormData() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.kycCreate);

      if (response.statusCode == 200) {
        return KycFormDataResponse(
          success: true,
          data: response.data['data'] ?? response.data,
        );
      }

      return KycFormDataResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch KYC form',
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

/// Response wrapper for KYC status
class KycStatusResponse {
  final bool success;
  final String status; // none, pending, approved, rejected
  final bool isVerified;
  final String? documentType;
  final String? rejectionReason;
  final String? submittedAt;
  final String? verifiedAt;

  const KycStatusResponse({
    required this.success,
    required this.status,
    required this.isVerified,
    this.documentType,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isNone => status == 'none' || status.isEmpty;
}

/// Response wrapper for KYC operations
class KycResponse {
  final bool success;
  final String message;

  const KycResponse({
    required this.success,
    this.message = '',
  });
}

/// Response wrapper for KYC form data
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
