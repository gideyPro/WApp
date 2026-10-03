import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';
import '../models/job_form_data.dart';
import 'listing_service.dart';
import 'package:image_picker/image_picker.dart';

class JobService {
  final ApiClient _apiClient;

  JobService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ListingResponse> getListings({
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
        '${ApiConstants.apiBase}/jobs',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final dataList = ApiEnvelope.extractList(
          raw,
          itemKeys: const ['listings', 'items', 'data'],
        );
        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();
        final pagination = ApiEnvelope.extractPagination(raw, fallbackPage: page);
        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch job listings'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> getMyListings({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/jobs/my-listings',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final dataList = ApiEnvelope.extractList(
          raw,
          itemKeys: const ['listings', 'items', 'data'],
        );
        final pagination = ApiEnvelope.extractPagination(raw, fallbackPage: page);
        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();
        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch your job listings'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> getFeaturedListings({
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/jobs/featured',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final dataList = ApiEnvelope.extractList(
          raw,
          itemKeys: const ['listings', 'items', 'data'],
        );
        final pagination = ApiEnvelope.extractPagination(raw, fallbackPage: page);
        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();
        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch featured jobs'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingDetailResponse> getListingDetail(int listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/jobs/$listingId',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is Map ? (raw['data'] ?? raw['listing'] ?? raw) : raw;
        final listing = data is Map ? Listing.fromJson(data as Map<String, dynamic>) : null;
        return ListingDetailResponse(
          success: true,
          listing: listing,
        );
      }
      final gate = ApiEnvelope.extractSubscriptionGate(response.data);
      return ListingDetailResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to load job details'),
        subscriptionGate: gate.required ? gate : null,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingDetailResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> getSimilarListings(int listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/jobs/$listingId/similar',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final dataList = ApiEnvelope.extractList(
          raw,
          itemKeys: const ['listings', 'items', 'data'],
        );
        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();
        return ListingResponse(success: true, listings: listings);
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch similar jobs'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<FormData> _buildFormData(JobFormData formData, {bool isUpdate = false}) async {
    final dioFormData = FormData();
    dioFormData.fields.addAll([
      const MapEntry('type', 'job'),
      if (formData.companyName != null && formData.companyName!.isNotEmpty) MapEntry('company_name', formData.companyName!),
      MapEntry('job_type', formData.jobType),
      if (formData.jobCategory.isNotEmpty) MapEntry('job_category', formData.jobCategory),
      MapEntry('positions_count', formData.positionsCount.toString()),
      MapEntry('salary_type', formData.salaryType),
      if (formData.salaryMin != null) MapEntry('salary_min', formData.salaryMin!.toString()),
      if (formData.salaryMax != null) MapEntry('salary_max', formData.salaryMax!.toString()),
      MapEntry('salary_currency', formData.salaryCurrency),
      if (formData.reqEducation != null && formData.reqEducation!.isNotEmpty) MapEntry('req_education', formData.reqEducation!),
      if (formData.reqExperience != null && formData.reqExperience!.isNotEmpty) MapEntry('req_experience', formData.reqExperience!),
      MapEntry('req_gender', formData.reqGender),
      if (formData.deadline != null) MapEntry('deadline', formData.deadline!.toIso8601String()),
      if (formData.addressId != null) MapEntry('address_id', formData.addressId.toString()),
      if (formData.specificLocation != null && formData.specificLocation!.isNotEmpty) MapEntry('specific_location', formData.specificLocation!),
      if (formData.description != null && formData.description!.isNotEmpty) MapEntry('description', formData.description!),
      const MapEntry('terms_accepted', '1'),
    ]);

    if (formData.postedByAgent && formData.agentId != null) {
      dioFormData.fields.add(MapEntry('agent_id', formData.agentId!.toString()));
    }
    
    for (int i = 0; i < formData.images.length; i++) {
      final file = formData.images[i];
      if (file is XFile) {
        dioFormData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(file.path, filename: 'image_$i.jpg'),
        ));
      }
    }
    if (isUpdate) {
      dioFormData.fields.add(const MapEntry('_method', 'PUT'));
      // Handle deleted images if you add it later to the form data model
    }
    return dioFormData;
  }

  Future<ListingResponse> createListing({
    required JobFormData formData,
    String? submissionKey,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dioFormData = await _buildFormData(formData);
      final headers = <String, dynamic>{};
      if (submissionKey != null) {
        headers['X-Submission-Key'] = submissionKey;
      }
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/jobs',
        data: dioFormData,
        options: Options(
          sendTimeout: const Duration(seconds: 300),
          headers: headers.isNotEmpty ? headers : null,
        ),
        onSendProgress: onProgress != null
            ? (sent, total) {
                if (total > 0) onProgress(sent / total);
              }
            : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        final data = raw is Map ? (raw['data'] ?? raw['listing'] ?? raw) : raw;
        final listing = data is Map ? Listing.fromJson(data as Map<String, dynamic>) : null;
        return ListingResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Job listing submitted for review'),
          listings: listing != null ? [listing] : [],
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to create job listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> updateListing({
    required int id,
    required JobFormData formData,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dioFormData = await _buildFormData(formData, isUpdate: true);
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/jobs/$id',
        data: dioFormData,
        options: Options(sendTimeout: const Duration(seconds: 300)),
        onSendProgress: onProgress != null
            ? (sent, total) {
                if (total > 0) onProgress(sent / total);
              }
            : null,
      );
      if (response.statusCode == 200) {
        return ListingResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Job listing updated'),
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to update job listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> deleteListing(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.apiBase}/jobs/$id',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Job listing deleted');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to delete job listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> featureListing(int id) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/jobs/$id/feature',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Job listing featured');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to feature job listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> unfeatureListing(int id) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/jobs/$id/unfeature',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Job listing unfeatured');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to unfeature job listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ContactRevealResponse> revealContact(int id) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/jobs/$id/reveal-contact',
      );
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data as Map<String, dynamic> : {};
        return ContactRevealResponse(
          success: true,
          contact: data['contact'] ?? '',
          name: data['name'] ?? '',
          alreadyRevealed: data['already_revealed'] ?? false,
        );
      }
      return ContactRevealResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to reveal contact'),
      );
    } catch (e) {
      return ContactRevealResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString(),
      );
    }
  }

  Future<int?> checkSubmissionKey(String key) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/jobs/check-key/$key',
      );
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data as Map<String, dynamic> : {};
        final listingData = data['listing'] ?? data['data'];
        if (listingData is Map) {
          final listing = Listing.fromJson(listingData as Map<String, dynamic>);
          return listing.id;
        }
        return data['id'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
