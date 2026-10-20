import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/job_seeker_profile.dart';

class JobSeekerProfileResponse {
  final bool success;
  final String? message;
  final JobSeekerProfile? profile;
  final List<JobSeekerProfile>? profiles;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const JobSeekerProfileResponse({
    required this.success,
    this.message,
    this.profile,
    this.profiles,
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

class JobSeekerService {
  final ApiClient _apiClient;

  JobSeekerService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<JobSeekerProfileResponse> getProfiles({
    int page = 1,
    int perPage = 15,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        if (filters != null) ...filters,
      };
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/job-seekers',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final dataList = ApiEnvelope.extractList(
          raw,
          itemKeys: const ['profiles', 'items', 'data'],
        );
        final profiles = dataList
            .whereType<Map>()
            .map((json) => JobSeekerProfile.fromJson(json as Map<String, dynamic>))
            .toList();
        final pagination = ApiEnvelope.extractPagination(raw, fallbackPage: page);
        return JobSeekerProfileResponse(
          success: true,
          profiles: profiles,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }
      return JobSeekerProfileResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch job seekers'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return JobSeekerProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<JobSeekerProfileResponse> getProfile(int id) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/job-seekers/$id',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is Map ? (raw['data'] ?? raw['profile'] ?? raw) : raw;
        final profile = data is Map ? JobSeekerProfile.fromJson(data as Map<String, dynamic>) : null;
        return JobSeekerProfileResponse(
          success: true,
          profile: profile,
        );
      }
      return JobSeekerProfileResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to load profile'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return JobSeekerProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<JobSeekerProfileResponse> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/job-seekers/me',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is Map ? (raw['data'] ?? raw['profile'] ?? raw) : raw;
        final profile = data is Map ? JobSeekerProfile.fromJson(data as Map<String, dynamic>) : null;
        return JobSeekerProfileResponse(
          success: true,
          profile: profile,
        );
      }
      return JobSeekerProfileResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to load profile'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return JobSeekerProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<JobSeekerProfileResponse> createOrUpdateProfile({
    required Map<String, dynamic> data,
    File? photo,
    File? cv,
    bool update = false,
  }) async {
    try {
      final mapCopy = Map<String, dynamic>.from(data);
      final educations = mapCopy.remove('educations');
      final experiences = mapCopy.remove('experiences');
      final formData = FormData.fromMap(mapCopy);

      if (educations is List) {
        for (int i = 0; i < educations.length; i++) {
          final edu = educations[i];
          if (edu is Map) {
            formData.fields.add(MapEntry('educations[$i][education_level]', edu['education_level']?.toString() ?? 'other'));
            if (edu['field_of_study'] != null && edu['field_of_study'].toString().isNotEmpty) {
              formData.fields.add(MapEntry('educations[$i][field_of_study]', edu['field_of_study'].toString()));
            }
          }
        }
      }

      if (experiences is List) {
        for (int i = 0; i < experiences.length; i++) {
          final exp = experiences[i];
          if (exp is Map) {
            if (exp['job_title'] != null && exp['job_title'].toString().isNotEmpty) {
              formData.fields.add(MapEntry('experiences[$i][job_title]', exp['job_title'].toString()));
            }
            if (exp['company'] != null && exp['company'].toString().isNotEmpty) {
              formData.fields.add(MapEntry('experiences[$i][company]', exp['company'].toString()));
            }
            if (exp['years'] != null) {
              formData.fields.add(MapEntry('experiences[$i][years]', exp['years'].toString()));
            }
          }
        }
      }
      if (photo != null) {
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(photo.path, filename: 'photo.jpg'),
        ));
      }
      if (cv != null) {
        formData.files.add(MapEntry(
          'cv',
          await MultipartFile.fromFile(cv.path, filename: 'cv.pdf'),
        ));
      }

      // PHP does not populate request data/files for multipart PUT requests,
      // so the update is sent as POST with Laravel method spoofing.
      if (update) {
        formData.fields.add(const MapEntry('_method', 'PUT'));
      }

      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/job-seekers/profile',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        final responseData = raw is Map ? (raw['data'] ?? raw['profile'] ?? raw) : raw;
        final profile = responseData is Map ? JobSeekerProfile.fromJson(responseData as Map<String, dynamic>) : null;
        return JobSeekerProfileResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Profile updated successfully'),
          profile: profile,
        );
      }
      return JobSeekerProfileResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to update profile'),
      );
    } catch (e) {
      return JobSeekerProfileResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<JobSeekerProfileResponse> deleteProfile() async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.apiBase}/job-seekers/profile',
      );
      if (response.statusCode == 200) {
        return const JobSeekerProfileResponse(success: true, message: 'Profile deleted');
      }
      return JobSeekerProfileResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to delete profile'),
      );
    } catch (e) {
      return JobSeekerProfileResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}
