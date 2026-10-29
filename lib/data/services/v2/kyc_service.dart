import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/kyc_state.dart';

/// Identity verification and the verified phone-change flow.
///
/// The document upload is multipart; [submit] never sends a phone number
/// because v2 keeps phone changes in the dedicated OTP flow below.
class KycServiceV2 {
  final ApiV2Client _client;

  KycServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<KycOverview> fetchStatus() async {
    final data = await _client.getItem(ApiV2Constants.kyc);
    return KycOverview.fromJson(data);
  }

  /// Submit identity documents.
  ///
  /// [backImage] is required by the backend for `national_id` and ignored for
  /// `passport`. The backend rejects submissions while a review is pending and
  /// for already-verified users with `409 CONFLICT`.
  Future<KycOverview> submit({
    required String documentType,
    required File frontImage,
    File? backImage,
    required File selfieImage,
  }) async {
    final form = FormData.fromMap({
      'document_type': documentType,
      'front_image': await _multipart(frontImage),
      if (backImage != null) 'back_image': await _multipart(backImage),
      'selfie_image': await _multipart(selfieImage),
    });

    final data = await _client.sendFormItem(
      ApiV2Constants.kyc,
      formData: form,
    );

    return KycOverview.fromJson(data);
  }

  /// Send an OTP to a new phone number. The account phone changes only after
  /// [verifyPhoneOtp] succeeds.
  Future<KycPhoneDispatch> sendPhoneOtp(String phoneNumber) async {
    final data = await _client.sendItem(
      ApiV2Constants.kycPhoneSendOtp,
      method: 'POST',
      body: {'phone_number': phoneNumber},
    );

    return KycPhoneDispatch.fromJson(data);
  }

  Future<KycPhoneVerified> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final data = await _client.sendItem(
      ApiV2Constants.kycPhoneVerify,
      method: 'POST',
      body: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      },
    );

    return KycPhoneVerified.fromJson(data);
  }

  static Future<MultipartFile> _multipart(File file) {
    final segments = file.uri.pathSegments;
    final filename = segments.isEmpty ? 'upload' : segments.last;
    return MultipartFile.fromFile(file.path, filename: filename);
  }
}
