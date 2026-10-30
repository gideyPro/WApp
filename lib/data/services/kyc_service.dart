import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import 'v2/kyc_service.dart';

/// Service for KYC (Know Your Customer) verification backed by V2 API.
class KycService {
  final KycServiceV2 _v2;

  KycService({ApiClient? apiClient, KycServiceV2? v2Service})
      : _v2 = v2Service ?? KycServiceV2();

  Future<KycStatusResponse> getKycStatus() async {
    try {
      final overview = await _v2.fetchStatus();
      final v = overview.verification;

      return KycStatusResponse(
        success: true,
        status: overview.status.wireValue,
        isVerified: overview.verified,
        documentType: v?.documentType,
        rejectionReason: v?.rejectionReason,
        submittedAt: v?.submittedAt?.toIso8601String(),
        verifiedAt: v?.verifiedAt?.toIso8601String(),
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

  Future<KycResponse> submitKyc({
    required String documentType,
    required File frontImage,
    File? backImage,
    File? selfieImage,
    String? phoneNumber,
    String? countryCode,
  }) async {
    try {
      final selfie = selfieImage ?? frontImage;
      await _v2.submit(
        documentType: documentType,
        frontImage: frontImage,
        backImage: backImage,
        selfieImage: selfie,
      );

      return const KycResponse(
        success: true,
        message: 'KYC submitted successfully',
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
    return const KycFormDataResponse(
      success: true,
      data: {},
    );
  }

  Future<KycOtpResponse> sendOtp({
    required String phoneNumber,
    String? countryCode,
  }) async {
    try {
      final fullPhone = '${countryCode ?? ''}$phoneNumber'.trim();
      final dispatch = await _v2.sendPhoneOtp(fullPhone);

      return KycOtpResponse(
        success: true,
        message: 'OTP sent',
        destination: dispatch.destination,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return KycOtpResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<KycOtpResponse> verifyOtp({
    required String phoneNumber,
    String? countryCode,
    required String otpCode,
  }) async {
    try {
      final fullPhone = '${countryCode ?? ''}$phoneNumber'.trim();
      await _v2.verifyPhoneOtp(
        phoneNumber: fullPhone,
        otpCode: otpCode,
      );

      return const KycOtpResponse(
        success: true,
        message: 'Phone verified',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return KycOtpResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

class KycStatusResponse {
  final bool success;
  final String status;
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
  bool get isApproved => isVerified || status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isNone => status == 'none' || status == 'draft';
}

class KycResponse {
  final bool success;
  final String message;

  const KycResponse({
    required this.success,
    required this.message,
  });
}

class KycFormDataResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  const KycFormDataResponse({
    required this.success,
    this.message = '',
    this.data = const {},
  });
}

class KycOtpResponse {
  final bool success;
  final String message;
  final String? destination;

  const KycOtpResponse({
    required this.success,
    required this.message,
    this.destination,
  });
}
