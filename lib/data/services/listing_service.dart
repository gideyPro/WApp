import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/listing.dart';
import '../models/listing_form_data.dart';

/// Service for managing property listings
class ListingService {
  final ApiClient _apiClient;

  ListingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all active listings with optional filters
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
        ApiConstants.listings,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> dataList = [];
        Map<String, dynamic> meta = {};

        if (raw is Map) {
          final dataField = raw['data'];
          if (dataField is Map && raw['success'] != null) {
            meta = Map<String, dynamic>.from(dataField);
            final listRaw = dataField['data'] ?? dataField['listings'] ?? dataField['items'];
            if (listRaw is List) dataList = listRaw;
          } else if (dataField is List) {
            dataList = dataField;
            meta = Map<String, dynamic>.from(raw);
          } else if (dataField is Map) {
            meta = Map<String, dynamic>.from(dataField);
            final listRaw = dataField['data'] ?? dataField['listings'] ?? dataField['items'];
            if (listRaw is List) dataList = listRaw;
          } else if (raw['current_page'] != null) {
            meta = Map<String, dynamic>.from(raw);
            final listRaw = raw['data'] ?? raw['listings'] ?? raw['items'];
            if (listRaw is List) dataList = listRaw;
          }
        } else if (raw is List) {
          dataList = raw;
        }

        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();

        int currentPage = _safeInt(meta['current_page']) ?? page;
        int totalPages = _safeInt(meta['last_page']) ?? 1;
        int total = _safeInt(meta['total']) ?? 0;

        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Get user's own listings
  Future<ListingResponse> getMyListings({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.listings}/my-listings',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> dataList = [];
        int currentPage = page;
        int totalPages = 1;
        int total = 0;

        if (raw is Map && raw['success'] == true) {
          final dataField = raw['data'];
          if (dataField is Map) {
            final listRaw = dataField['data'];
            if (listRaw is List) dataList = listRaw;
            currentPage = _safeInt(dataField['current_page']) ?? page;
            totalPages = _safeInt(dataField['last_page']) ?? 1;
            total = _safeInt(dataField['total']) ?? 0;
          } else if (dataField is List) {
            dataList = dataField;
          }
        }

        final listings = dataList
            .whereType<Map>()
            .map((json) => Listing.fromJson(json as Map<String, dynamic>))
            .toList();

        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch your listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get featured listings only
  Future<ListingResponse> getFeaturedListings({
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.featuredListings,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final listings = (data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();

        return ListingResponse(
          success: true,
          listings: listings,
          currentPage: data['current_page'] ?? page,
          totalPages: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch featured listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get single listing details
  Future<ListingDetailResponse> getListingDetail(int listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.listingDetail}/$listingId',
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'] ?? response.data;
        final listing = Listing.fromJson(data);
        return ListingDetailResponse(success: true, listing: listing);
      }

      if (response.statusCode == 401) {
        return ListingDetailResponse(
          success: false,
          message: 'Please log in to view property details.',
        );
      }

      final message = response.data is Map
          ? (response.data['message'] ?? 'Listing not found')
          : 'Server returned an unexpected response.';
      return ListingDetailResponse(
        success: false,
        message: message,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingDetailResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get similar listings
  Future<ListingResponse> getSimilarListings(int listingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.similarListings}/$listingId/similar',
      );

      if (response.statusCode == 200) {
        final listings = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();

        return ListingResponse(success: true, listings: listings);
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch similar listings',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Build FormData from ListingFormData
  Future<FormData> _buildFormData(ListingFormData formData, {bool isUpdate = false}) async {
    final dioFormData = FormData();

    // Add text fields
    dioFormData.fields.addAll([
      MapEntry('type', formData.type),
      MapEntry('holding_type', formData.holdingType),
      MapEntry('listing_type', formData.listingType),
      MapEntry('use_type', formData.useType),
      if (formData.specificLocation != null) MapEntry('specific_location', formData.specificLocation!),
      if (formData.priceFixed != null) MapEntry('price_fixed', formData.priceFixed.toString()),
      if (formData.rentalPeriodUnit != null && formData.rentalPeriodUnit != 'week') 
        MapEntry('rental_period_unit', formData.rentalPeriodUnit!),
      if (formData.facingDirection != null) MapEntry('facing_direction', formData.facingDirection!),
      if (formData.description != null) MapEntry('description', formData.description!),
      if (formData.serviceType != null) MapEntry('service_type', formData.serviceType!),
      if (formData.addressId != null) MapEntry('address_id', formData.addressId.toString()),
      MapEntry('has_debt_or_encumbrance', formData.hasDebtOrEncumbrance ? '1' : '0'),
      if (formData.debtAmount != null) MapEntry('debt_amount', formData.debtAmount.toString()),
      if (formData.debtHolder != null) MapEntry('debt_holder', formData.debtHolder!),
      MapEntry('electricity', formData.electricity ? '1' : '0'),
      MapEntry('water', formData.water ? '1' : '0'),
      MapEntry('parking_available', formData.parkingAvailable ? '1' : '0'),
      if (formData.totalSquareMeters != null) ...[
        MapEntry('total_square_meters', formData.totalSquareMeters.toString()),
        MapEntry('area', formData.totalSquareMeters.toString()),
      ],
      if (formData.frontAreaSqm != null) MapEntry('front_area_sqm', formData.frontAreaSqm.toString()),
      if (formData.sideAreaSqm != null) MapEntry('side_area_sqm', formData.sideAreaSqm.toString()),
    ]);

    // House-specific fields
    if (formData.type == 'house') {
      if (formData.totalRooms != null) dioFormData.fields.add(MapEntry('total_rooms', formData.totalRooms.toString()));
      if (formData.bedrooms != null) dioFormData.fields.add(MapEntry('bedrooms', formData.bedrooms.toString()));
      if (formData.bathrooms != null) dioFormData.fields.add(MapEntry('bathrooms', formData.bathrooms.toString()));
      if (formData.kitchens != null) dioFormData.fields.add(MapEntry('kitchens', formData.kitchens.toString()));
      if (formData.salons != null) dioFormData.fields.add(MapEntry('salons', formData.salons.toString()));
      if (formData.floors != null) dioFormData.fields.add(MapEntry('floors', formData.floors.toString()));
      if (formData.houseType != null) dioFormData.fields.add(MapEntry('house_type', formData.houseType!));
      if (formData.yearBuilt != null) dioFormData.fields.add(MapEntry('year_built', formData.yearBuilt.toString()));
    }

    // Holding-specific fields
    if (formData.holdingType == 'Free Hold') {
      if (formData.taxPaidUntilYear != null) dioFormData.fields.add(MapEntry('tax_paid_until_year', formData.taxPaidUntilYear.toString()));
      if (formData.acquisitionClarification != null) dioFormData.fields.add(MapEntry('acquisition_clarification', formData.acquisitionClarification!));
    } else if (formData.holdingType == 'Lease Hold') {
      if (formData.leasedYear != null) dioFormData.fields.add(MapEntry('leased_year', formData.leasedYear.toString()));
      if (formData.leaseExpiryYear != null) dioFormData.fields.add(MapEntry('lease_expiry_year', formData.leaseExpiryYear.toString()));
      if (formData.leasePricePerSqm != null) dioFormData.fields.add(MapEntry('price_per_sqm', formData.leasePricePerSqm.toString()));
      if (formData.buildType != null) dioFormData.fields.add(MapEntry('build_type', formData.buildType!));
      if (formData.annualPayment != null) dioFormData.fields.add(MapEntry('annual_payment', formData.annualPayment.toString()));
    } else if (formData.holdingType == 'Cooperative') {
      if (formData.cooperativeName != null) dioFormData.fields.add(MapEntry('cooperative_name', formData.cooperativeName!));
      if (formData.cooperativeCode != null) dioFormData.fields.add(MapEntry('cooperative_code', formData.cooperativeCode!));
      if (formData.buildingStatus != null) dioFormData.fields.add(MapEntry('building_status', formData.buildingStatus!));
    }

    // Add new images
    for (int i = 0; i < formData.images.length; i++) {
      final file = formData.images[i];
      dioFormData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(file.path, filename: 'image_${i}.jpg'),
      ));
    }

    // Add site plan
    if (formData.sitePlan != null) {
      if (isUpdate) {
        // Backend update expects 'site_plan_image' for a single replacement
        dioFormData.files.add(MapEntry(
          'site_plan_image',
          await MultipartFile.fromFile(formData.sitePlan!.path,
              filename: 'site_plan_update.jpg'),
        ));
      } else {
        // Backend store expects 'site_plans[]' array
        dioFormData.files.add(MapEntry(
          'site_plans[]',
          await MultipartFile.fromFile(formData.sitePlan!.path,
              filename: 'site_plan.jpg'),
        ));
      }
    }

    // Add conditional files
    if (formData.ownershipProof != null) {
      final fieldName = (isUpdate && formData.holdingType == 'Cooperative') 
          ? 'certification_image' // API update expects this for cooperative
          : 'ownership_proof[]';
      
      dioFormData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(formData.ownershipProof!.path, filename: 'ownership_proof.jpg'),
      ));
    }
    
    if (formData.leaseContract != null) {
      final fieldName = (isUpdate && formData.holdingType == 'Lease Hold')
          ? 'lease_contract_image' // API update expects this for lease hold
          : 'lease_contract[]';

      dioFormData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(formData.leaseContract!.path, filename: 'lease_contract.jpg'),
      ));
    }

    if (formData.debtDocument != null) {
      dioFormData.files.add(MapEntry(
        'debt_encumbrance_file',
        await MultipartFile.fromFile(formData.debtDocument!.path, filename: 'debt_document.jpg'),
      ));
    }
    if (formData.videoFile != null) {
      dioFormData.files.add(MapEntry(
        'video_file',
        await MultipartFile.fromFile(formData.videoFile!.path, filename: 'video.mp4'),
      ));
    }

    // Update-specific fields
    if (isUpdate) {
      dioFormData.fields.add(MapEntry('_method', 'PUT'));
      
      // Sync with backend parameter names: delete_images instead of removed_image_ids
      for (final id in formData.removedImageIds) {
        dioFormData.fields.add(MapEntry('delete_images[]', id.toString()));
      }
      
      if (formData.removeExistingSitePlan) {
        dioFormData.fields.add(MapEntry('delete_site_plans[]', '0'));
        // I use '0' as a marker to delete the main site_plan_image_link too in backend.
      }
      
      if (formData.deleteVideo) {
        dioFormData.fields.add(MapEntry('delete_video', '1'));
      }
      if (formData.deleteDebtFile) {
        dioFormData.fields.add(MapEntry('delete_debt_file', '1'));
      }
    }

    return dioFormData;
  }

  /// Calculate total size of files to be uploaded
  Future<int> _calculateTotalSize(ListingFormData formData) async {
    int totalSize = 0;
    
    for (final file in formData.images) {
      totalSize += await File(file.path).length();
    }
    if (formData.sitePlan != null) {
      totalSize += await File(formData.sitePlan!.path).length();
    }
    if (formData.ownershipProof != null) {
      totalSize += await File(formData.ownershipProof!.path).length();
    }
    if (formData.certificationImage != null) {
      totalSize += await File(formData.certificationImage!.path).length();
    }
    if (formData.memberListImage != null) {
      totalSize += await File(formData.memberListImage!.path).length();
    }
    if (formData.leaseContract != null) {
      totalSize += await File(formData.leaseContract!.path).length();
    }
    if (formData.debtDocument != null) {
      totalSize += await File(formData.debtDocument!.path).length();
    }
    if (formData.videoFile != null) {
      totalSize += await File(formData.videoFile!.path).length();
    }
    
    return totalSize;
  }

  /// Create a new listing
  Future<ListingResponse> createListing({required ListingFormData formData}) async {
    try {
      // Validate total upload size (150MB limit)
      final totalSize = await _calculateTotalSize(formData);
      if (totalSize > 150 * 1024 * 1024) {
        return ListingResponse(
          success: false, 
          message: 'Total upload size exceeds 150MB limit. Please reduce file sizes.'
        );
      }

      final dioFormData = await _buildFormData(formData);
      final response = await _apiClient.dio.post(
        ApiConstants.createListing,
        data: dioFormData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ListingResponse(
          success: true,
          message: response.data['message'] ?? 'Listing created successfully',
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to create listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Update an existing listing
  Future<ListingResponse> updateListing({
    required int listingId,
    Map<String, dynamic>? listingData,
    ListingFormData? formData,
  }) async {
    try {
      dynamic data = listingData;
      String method = 'PUT';
      String url = '${ApiConstants.updateListing}/$listingId';

      if (formData != null) {
        // Validate total upload size (150MB limit)
        final totalSize = await _calculateTotalSize(formData);
        if (totalSize > 150 * 1024 * 1024) {
          return ListingResponse(
            success: false, 
            message: 'Total upload size exceeds 150MB limit. Please reduce file sizes.'
          );
        }

        // If we have files, we must use POST with _method=PUT
        data = await _buildFormData(formData, isUpdate: true);
        method = 'POST';
      }

      final response = await _apiClient.dio.request(
        url,
        data: data,
        options: Options(method: method),
      );

      if (response.statusCode == 200) {
        return ListingResponse(
          success: true,
          message: response.data['message'] ?? 'Listing updated successfully',
        );
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to update listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete a listing
  Future<ListingResponse> deleteListing(int listingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteListing}/$listingId',
      );

      if (response.statusCode == 200) {
        return ListingResponse(success: true, message: 'Listing deleted successfully');
      }

      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to delete listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Make listing featured
  Future<ListingResponse> featureListing(int listingId) async {
    try {
      final response = await _apiClient.dio.post('${ApiConstants.featureListing}/$listingId/feature');
      if (response.statusCode == 200) {
        return ListingResponse(success: true, message: 'Listing featured successfully');
      }
      return ListingResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to feature listing',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ListingResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for listing operations
class ListingResponse {
  final bool success;
  final String message;
  final List<Listing> listings;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const ListingResponse({
    required this.success,
    this.message = '',
    this.listings = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });

  @override
  String toString() => 'ListingResponse(success: $success, listings: ${listings.length})';
}

/// Response wrapper for single listing detail
class ListingDetailResponse {
  final bool success;
  final String message;
  final Listing? listing;

  const ListingDetailResponse({
    required this.success,
    this.message = '',
    this.listing,
  });
}
