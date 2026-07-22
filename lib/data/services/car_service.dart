import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';
import '../models/car_form_data.dart';
import 'listing_service.dart';

class CarService {
  final ApiClient _apiClient;

  CarService({ApiClient? apiClient})
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
        '${ApiConstants.apiBase}/cars',
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
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch car listings'),
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
        '${ApiConstants.apiBase}/cars/my-listings',
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
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch your car listings'),
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
        '${ApiConstants.apiBase}/cars/featured',
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
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch featured cars'),
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
        '${ApiConstants.apiBase}/cars/$listingId',
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
        message: ApiEnvelope.extractMessage(response.data, 'Failed to load car details'),
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
        '${ApiConstants.apiBase}/cars/$listingId/similar',
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
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch similar cars'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<FormData> _buildFormData(CarFormData formData, {bool isUpdate = false}) async {
    final dioFormData = FormData();
    dioFormData.fields.addAll([
      const MapEntry('type', 'car'),
      MapEntry('vehicle_category', formData.vehicleCategory),
      MapEntry('make', formData.make),
      MapEntry('model', formData.model),
      MapEntry('year', formData.year),
      if (formData.mileageKm.isNotEmpty) MapEntry('mileage_km', formData.mileageKm),
      if (formData.bodyType.isNotEmpty) MapEntry('body_type', formData.bodyType),
      if (formData.color.isNotEmpty) MapEntry('color', formData.color),
      if (formData.condition.isNotEmpty) MapEntry('condition', formData.condition),
      if (formData.vin.isNotEmpty) MapEntry('vin', formData.vin),
      if (formData.features.isNotEmpty) MapEntry('features', jsonEncode(formData.features)),
      if (formData.customFeatures.isNotEmpty) MapEntry('custom_features', formData.customFeatures),
      MapEntry('listing_type', formData.isForRent ? 'rental' : 'sale'),
      if (formData.isForRent && formData.rentalPeriodUnit.isNotEmpty) MapEntry('rental_period_unit', formData.rentalPeriodUnit),
      if (!formData.isForRent && formData.priceFixed.isNotEmpty) MapEntry('price_fixed', formData.priceFixed),
      if (formData.addressId != null) MapEntry('address_id', formData.addressId.toString()),
      if (formData.specificLocation.isNotEmpty) MapEntry('specific_location', formData.specificLocation),
      if (formData.description.isNotEmpty) MapEntry('description', formData.description),
    ]);
    if (formData.isVip) {
      dioFormData.fields.add(const MapEntry('is_vip', '1'));
    }
    for (int i = 0; i < formData.images.length; i++) {
      final file = formData.images[i];
      dioFormData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(file.path, filename: 'image_$i.jpg'),
      ));
    }
    if (isUpdate) {
      dioFormData.fields.add(const MapEntry('_method', 'PUT'));
      for (final id in formData.removedImageIds) {
        dioFormData.fields.add(MapEntry('delete_images[]', id.toString()));
      }
    }
    return dioFormData;
  }

  Future<ListingResponse> createListing({
    required CarFormData formData,
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
        '${ApiConstants.apiBase}/cars',
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
          message: ApiEnvelope.extractMessage(response.data, 'Car listing submitted for review'),
          listings: listing != null ? [listing] : [],
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to create car listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> updateListing({
    required int listingId,
    required CarFormData formData,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dioFormData = await _buildFormData(formData, isUpdate: true);
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId',
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
          message: ApiEnvelope.extractMessage(response.data, 'Car listing updated'),
        );
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to update car listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> deleteListing(int listingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.apiBase}/cars/$listingId',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Car listing deleted');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to delete car listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> featureListing(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId/feature',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Car listing featured');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to feature car listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> unfeatureListing(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId/unfeature',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Car listing unfeatured');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to unfeature car listing'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> vipListing(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId/vip',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'Car listing marked as VIP');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to mark car listing as VIP'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ListingResponse> unvipListing(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId/unvip',
      );
      if (response.statusCode == 200) {
        return const ListingResponse(success: true, message: 'VIP status removed');
      }
      return ListingResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to remove VIP status'),
      );
    } catch (e) {
      return ListingResponse(
        success: false,
        message: ApiErrorHandler.handle(e).toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<ContactRevealResponse> revealContact(int listingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.apiBase}/cars/$listingId/reveal-contact',
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

  Future<int?> checkSubmissionKey(String submissionKey) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.apiBase}/cars/check-key/$submissionKey',
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
