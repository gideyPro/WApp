import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'address.dart';
import 'image.dart';

// Helper to safely parse doubles from strings or numbers
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Helper to safely parse ints from strings or numbers
int? _safeInt(dynamic value, {int? defaultValue}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  if (value is bool) return value ? 1 : 0;
  return defaultValue;
}

// Helper to safely parse bools
bool _safeBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}

// Parse property type from backend (handles 'App\Models\House' or 'house')
PropertyType _parsePropertyType(dynamic value) {
  if (value == null) return PropertyType.house;
  final str = value.toString();
  // Extract class name from full namespace like 'App\Models\House'
  final className = str.contains('\\')
      ? str.split('\\').last.toLowerCase()
      : str.toLowerCase();
  if (className == 'house') return PropertyType.house;
  if (className == 'land') return PropertyType.land;
  return PropertyType.house;
}

// Parse listing type from backend (handles 'sale', 'rental', etc.)
ListingType _parseListingType(dynamic value) {
  if (value == null) return ListingType.sale;
  final str = value.toString().toLowerCase();
  if (str == 'sale') return ListingType.sale;
  if (str == 'rental' || str == 'rent') return ListingType.rental;
  return ListingType.sale;
}

/// Property types
enum PropertyType { house, land }

/// Listing types
enum ListingType { sale, rental }

/// Listing status
enum ListingStatus { pending, active, rejected, sold, rented, frozen }

/// Rental period units
enum RentalPeriod { day, month, year }

/// Video processing status
enum VideoProcessingStatus { none, pending, processing, ready, failed }

/// Video processing info returned by backend's video_processing appended attribute
class VideoProcessing {
  final VideoProcessingStatus status;
  final String? processedUrl;
  final String? thumbnailUrl;
  final String? errorMessage;

  const VideoProcessing({
    required this.status,
    this.processedUrl,
    this.thumbnailUrl,
    this.errorMessage,
  });

  factory VideoProcessing.fromJson(Map<String, dynamic> json) {
    return VideoProcessing(
      status: VideoProcessingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VideoProcessingStatus.pending,
      ),
      processedUrl: json['processed_url'],
      thumbnailUrl: json['thumbnail_url'],
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'processed_url': processedUrl,
      'thumbnail_url': thumbnailUrl,
      'error_message': errorMessage,
    };
  }
}

/// Listing Model
class Listing extends ChangeNotifier {
  final int id;
  final int? userId;
  final int? propertyId;
  final PropertyType propertyType;
  final ListingType listingType;
  final double? priceFixed;
  final double? priceMin;
  final double? priceMax;
  final RentalPeriod? rentalPeriodUnit;
  final ListingStatus status;
  final bool isFeatured;
  final bool isVip;
  final DateTime? featuredUntil;
  final int? addressId;
  final String? specificLocation;
  final String? useType;
  final String? facingDirection;
  final double? totalSquareMeters;
  final double? frontAreaSqm;
  final double? sideAreaSqm;
  final bool hasDebtOrEncumbrance;
  final double? debtAmount;
  final String? debtEncumbranceFileLink;
  final bool priceRevisionPossible;
  final String? videoLink;
  final VideoProcessing? videoProcessing;
  final bool userContactHidden;
  final bool videoBlocked;
  final bool interestBlocked;

  /// Returns the full video URL by prepending base URL if needed
  String? get videoUrl => _formatUrl(videoLink);

  /// Returns the full processed video URL by prepending base URL if needed
  String? get processedVideoUrl => videoProcessing?.processedUrl != null
      ? _formatUrl(videoProcessing!.processedUrl!)
      : null;

  /// Whether the backend returned video_processing info
  bool get hasVideoProcessing => videoProcessing != null;

  /// Whether the video is currently being processed (pending or processing)
  bool get isVideoBeingProcessed => videoProcessing != null &&
      (videoProcessing!.status == VideoProcessingStatus.pending ||
       videoProcessing!.status == VideoProcessingStatus.processing);

  /// Returns full URL for site plan
  String? get sitePlanUrl => _formatUrl(sitePlanImageLink);

  /// Returns full URL for ownership proof
  String? get ownershipProofUrl => _formatUrl(ownershipProofLink);

  /// Returns full URL for lease contract
  String? get leaseContractUrl => _formatUrl(leaseContractLink);

  /// Returns full URL for debt document
  String? get debtDocumentUrl => _formatUrl(debtEncumbranceFileLink);

  String? _formatUrl(String? link) {
    if (link == null || link.isEmpty) return null;
    if (link.startsWith('http')) return link;
    // Remove leading slash if present
    final cleanLink = link.startsWith('/') ? link.substring(1) : link;
    return 'https://wavemart.et/storage/$cleanLink';
  }

  final String? sitePlanImageLink;
  final String? ownershipProofLink;
  final String? leaseContractLink;
  final String? holdingType;

  // Free Hold details
  final int? taxPaidUntilYear;
  final String? acquisitionType;

  // Lease Hold details
  final String? leaseHolderName;
  final String? leaseOrganization;
  final DateTime? leaseExpiryDate;

  // Cooperative details
  final String? cooperativeName;
  final String? cooperativeCode;

  // Additional property details
  final int? yearBuilt;
  final String? houseType;
  final bool electricity;
  final bool water;
  final bool parkingAvailable;
  final String? buildingStatus;
  final int? leasedYear;
  final double? leasePricePerSqm;
  final String? buildType;
  final double? annualPayment;

  final String? description;
  final int? bedrooms;
  final int? bathrooms;
  final int? salons;
  final int? kitchens;
  final int? imageCount;
  final List<ImageModel> images;
  final Address? address;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? userInterestStatus;
  final int? userInterestId;
  final int viewCount;

  /// Calculate total rooms
  int get totalRooms =>
      (bedrooms ?? 0) + (bathrooms ?? 0) + (salons ?? 0) + (kitchens ?? 0);

  Listing({
    required this.id,
    this.userId,
    this.propertyId,
    required this.propertyType,
    required this.listingType,
    this.priceFixed,
    this.priceMin,
    this.priceMax,
    this.rentalPeriodUnit,
    this.status = ListingStatus.pending,
    this.isFeatured = false,
    this.isVip = false,
    this.featuredUntil,
    this.addressId,
    this.specificLocation,
    this.useType,
    this.facingDirection,
    this.totalSquareMeters,
    this.frontAreaSqm,
    this.sideAreaSqm,
    this.hasDebtOrEncumbrance = false,
    this.debtAmount,
    this.debtEncumbranceFileLink,
    this.priceRevisionPossible = false,
    this.videoLink,
    this.videoProcessing,
    this.userContactHidden = false,
    this.videoBlocked = false,
    this.interestBlocked = false,
    this.sitePlanImageLink,
    this.ownershipProofLink,
    this.leaseContractLink,
    this.holdingType,
    this.taxPaidUntilYear,
    this.acquisitionType,
    this.leaseHolderName,
    this.leaseOrganization,
    this.leaseExpiryDate,
    this.cooperativeName,
    this.cooperativeCode,
    this.yearBuilt,
    this.houseType,
    this.electricity = false,
    this.water = false,
    this.parkingAvailable = false,
    this.buildingStatus,
    this.leasedYear,
    this.leasePricePerSqm,
    this.buildType,
    this.annualPayment,
    this.description,
    this.bedrooms,
    this.bathrooms,
    this.salons,
    this.kitchens,
    this.imageCount,
    this.images = const [],
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.userInterestStatus,
    this.userInterestId,
    this.viewCount = 0,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Images may be directly on listing or nested under property
    List<ImageModel> images = [];

    if (json['images'] is List) {
      images =
          (json['images'] as List).map((e) => ImageModel.fromJson(e)).toList();
    }

    final property = json['property'];
    if (property is Map) {
      if (property['images'] is List) {
        images = (property['images'] as List)
            .map((e) => ImageModel.fromJson(e))
            .toList();
      }
    }

    return Listing(
      id: _safeInt(json['id'], defaultValue: 0)!,
      userId: _safeInt(json['user_id']),
      propertyId: _safeInt(json['property_id']),
      propertyType: _parsePropertyType(json['property_type']),
      listingType: _parseListingType(json['listing_type']),
      priceFixed: _parseDouble(json['price_fixed']),
      priceMin: _parseDouble(json['price_min']),
      priceMax: _parseDouble(json['price_max']),
      rentalPeriodUnit: json['rental_period_unit'] != null
          ? RentalPeriod.values.firstWhere(
              (e) => e.toString().split('.').last == json['rental_period_unit'],
            )
          : null,
      status: ListingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => ListingStatus.pending,
      ),
      isFeatured: json['is_featured'] ?? false,
      isVip: json['is_vip'] ?? false,
      featuredUntil: json['featured_until'] != null
          ? DateTime.parse(json['featured_until'])
          : null,
      addressId: _safeInt(json['address_id']),
      specificLocation: json['specific_location'] ?? (property is Map ? property['specific_location'] : null),
      useType: json['use_type'] ?? (property is Map ? property['use_type'] : null),
      facingDirection: json['facing_direction'] ?? (property is Map ? property['facing_direction'] : null),
      totalSquareMeters: _parseDouble(json['total_square_meters'] ?? json['area']) ??
          (property is Map ? _parseDouble(property['total_square_meters'] ?? property['area']) : null),
      frontAreaSqm: _parseDouble(json['front_area_sqm']) ?? (property is Map ? _parseDouble(property['front_area_sqm']) : null),
      sideAreaSqm: _parseDouble(json['side_area_sqm']) ?? (property is Map ? _parseDouble(property['side_area_sqm']) : null),
      hasDebtOrEncumbrance: _safeBool(json['has_debt_or_encumbrance']),
      debtAmount: _parseDouble(json['debt_amount']),
      debtEncumbranceFileLink: json['debt_encumbrance_file_link'] ?? (property is Map ? property['debt_encumbrance_file_link'] : null),
      priceRevisionPossible: json['price_revision_possible'] ?? false,
      videoLink: json['video_link'] ?? (property is Map ? property['video_link'] : null),
      videoProcessing: json['video_processing'] != null ? VideoProcessing.fromJson(json['video_processing']) : null,
      userContactHidden: json['user_contact_hidden'] ?? false,
      videoBlocked: json['video_blocked'] ?? false,
      interestBlocked: json['interest_blocked'] ?? false,
      sitePlanImageLink: json['site_plan_image_link'] ?? 
          (property is Map ? property['site_plan_image_link'] : null),
      ownershipProofLink: json['ownership_proof_link'] ?? 
          (property is Map ? property['ownership_proof_link'] : null) ??
          (json['cooperative_holding_detail'] is Map ? json['cooperative_holding_detail']['ownership_proof_link'] : null),
      leaseContractLink: json['lease_contract_link'] ?? 
          json['lease_contract_image_link'] ??
          (property is Map ? (property['lease_contract_link'] ?? property['lease_contract_image_link']) : null) ??
          (json['lease_holding_detail'] is Map ? (json['lease_holding_detail']['lease_contract_link'] ?? json['lease_holding_detail']['lease_contract_image_link']) : null),
      holdingType: json['holding_type'] ?? (property is Map ? property['holding_type'] : null),

      // Holding Details from nested objects (API show method with relation)
      taxPaidUntilYear: _safeInt(json['tax_paid_until_year'] ??
          (json['private_holding_detail'] is Map
              ? json['private_holding_detail']['tax_paid_until_year']
              : null)),
      acquisitionType: json['acquisition_clarification'] ??
          (json['private_holding_detail'] is Map
              ? json['private_holding_detail']['acquisition_clarification']
              : null),

      // Lease Hold details
      leaseHolderName: json['leaseholder_name'],
      leaseOrganization: json['lease_organization'],
      leaseExpiryDate: json['lease_expiry_date'] != null
          ? DateTime.tryParse(json['lease_expiry_date'])
          : (json['lease_holding_detail'] is Map &&
                  json['lease_holding_detail']['lease_expiry_date'] != null
              ? DateTime.tryParse(
                  json['lease_holding_detail']['lease_expiry_date'])
              : null),
      leasedYear: _safeInt(property is Map ? property['leased_year'] : null) ??
          _safeInt(json['leased_year']) ??
          _safeInt(json['lease_holding_detail'] is Map
              ? json['lease_holding_detail']['leased_year']
              : null),
      leasePricePerSqm: _parseDouble(property is Map ? (property['lease_price_per_sqm'] ?? property['price_per_sqm']) : null) ??
          _parseDouble(json['lease_price_per_sqm'] ?? json['price_per_sqm']) ??
          _parseDouble(json['lease_holding_detail'] is Map
              ? (json['lease_holding_detail']['lease_price_per_sqm'] ?? json['lease_holding_detail']['price_per_sqm'])
              : null),
      buildType: (property is Map ? property['build_type'] : null) ??
          json['build_type'] ??
          (json['lease_holding_detail'] is Map
              ? json['lease_holding_detail']['build_type']
              : null),
      annualPayment: _parseDouble(property is Map ? property['annual_payment'] : null) ??
          _parseDouble(json['annual_payment']) ??
          _parseDouble(json['lease_holding_detail'] is Map
              ? json['lease_holding_detail']['annual_payment']
              : null),

      // Cooperative details
      cooperativeName: json['cooperative_name'] ??
          (property is Map ? property['cooperative_name'] : null) ??
          (json['cooperative_holding_detail'] is Map
              ? json['cooperative_holding_detail']['cooperative_name']
              : null),
      cooperativeCode: json['cooperative_code'] ??
          (property is Map ? property['cooperative_code'] : null) ??
          (json['cooperative_holding_detail'] is Map
              ? json['cooperative_holding_detail']['cooperative_code']
              : null),
      buildingStatus: (property is Map ? property['building_status'] : null) ??
          json['building_status'] ??
          (json['cooperative_holding_detail'] is Map
              ? json['cooperative_holding_detail']['building_status']
              : null),

      // Additional property details
      yearBuilt: _safeInt(property is Map ? property['year_built'] : json['year_built']),
      houseType: property is Map ? property['house_type'] : json['house_type'],
      electricity: _safeBool(property is Map ? property['electricity'] : json['electricity']),
      water: _safeBool(property is Map ? property['water'] : json['water']),
      parkingAvailable: _safeBool(property is Map ? property['parking_available'] : json['parking_available']),

      description: json['description'] ??
          (property is Map ? property['description'] : null),
      bedrooms:
          _safeInt(property is Map ? property['bedrooms'] : json['bedrooms'], defaultValue: 0),
      bathrooms:
          _safeInt(property is Map ? property['bathrooms'] : json['bathrooms'], defaultValue: 0),
      salons: _safeInt(property is Map ? property['salons'] : json['salons'], defaultValue: 0),
      kitchens:
          _safeInt(property is Map ? property['kitchens'] : json['kitchens'], defaultValue: 0),
      imageCount: _safeInt(json['image_count']),
      images: images,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      userInterestStatus: json['user_interest_status'],
      userInterestId: _safeInt(json['user_interest_id']),
      viewCount: _safeInt(json['view_count'], defaultValue: 0)!,
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'property_type': propertyType.toString().split('.').last,
      'listing_type': listingType.toString().split('.').last,
      'price_fixed': priceFixed,
      'price_min': priceMin,
      'price_max': priceMax,
      'rental_period_unit': rentalPeriodUnit?.toString().split('.').last,
      'status': status.toString().split('.').last,
      'is_featured': isFeatured,
      'is_vip': isVip,
      'featured_until': featuredUntil?.toIso8601String(),
      'address_id': addressId,
      'specific_location': specificLocation,
      'use_type': useType,
      'facing_direction': facingDirection,
      'total_square_meters': totalSquareMeters,
      'front_area_sqm': frontAreaSqm,
      'side_area_sqm': sideAreaSqm,
      'has_debt_or_encumbrance': hasDebtOrEncumbrance,
      'debt_amount': debtAmount,
      'debt_encumbrance_file_link': debtEncumbranceFileLink,
      'price_revision_possible': priceRevisionPossible,
      'video_link': videoLink,
      'video_processing': videoProcessing?.toJson(),
      'site_plan_image_link': sitePlanImageLink,
      'ownership_proof_link': ownershipProofLink,
      'lease_contract_link': leaseContractLink,
      'holding_type': holdingType,
      'description': description,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'salons': salons,
      'image_count': imageCount,
      'images': images.map((e) => e.toJson()).toList(),
      'address': address?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'view_count': viewCount,
    };
  }

  String getLocalizedHoldingType(BuildContext context) {
    if (holdingType == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (holdingType) {
      case 'Free Hold':
        return l10n.listingFreeHold;
      case 'Lease Hold':
        return l10n.listingLeaseHold;
      case 'Cooperative':
        return l10n.listingCooperative;
      default:
        return holdingType!;
    }
  }

  String getLocalizedUseType(BuildContext context) {
    if (useType == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (useType) {
      case 'Residential':
        return l10n.listingResidential;
      case 'Commercial':
        return l10n.listingCommercial;
      case 'Mixed Use':
        return l10n.listingMixed;
      case 'Industrial':
        return l10n.listingOther;
      case 'Agricultural':
        return l10n.listingOther;
      case 'Institutional':
        return l10n.listingOther;
      case 'Other':
        return l10n.listingOther;
      default:
        return useType!;
    }
  }

  String getLocalizedAcquisitionType(BuildContext context) {
    if (acquisitionType == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (acquisitionType) {
      case 'Purchase':
        return l10n.listingPurchased;
      case 'Inheritance':
        return l10n.listingInherited;
      case 'Gift':
        return l10n.listingGift;
      case 'Government Grant':
        return l10n.listingAssignment;
      default:
        return acquisitionType!;
    }
  }

  String getLocalizedFacingDirection(BuildContext context) {
    if (facingDirection == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (facingDirection) {
      case 'north':
        return l10n.listingNorth;
      case 'south':
        return l10n.listingSouth;
      case 'east':
        return l10n.listingEast;
      case 'west':
        return l10n.listingWest;
      case 'north_east':
        return l10n.listingNorthEast;
      case 'north_west':
        return l10n.listingNorthWest;
      case 'south_east':
        return l10n.listingSouthEast;
      case 'south_west':
        return l10n.listingSouthWest;
      case 'facing_3_directions':
        return l10n.listingFacing3Directions;
      case 'facing_all_directions':
        return l10n.listingFacingAllDirections;
      default:
        return facingDirection!;
    }
  }

  String getLocalizedTitle(BuildContext context, [Map<String, String>? cache]) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final type = propertyType == PropertyType.house
        ? l10n.listingHouse
        : l10n.listingLand;
    final action = listingType == ListingType.sale
        ? l10n.listingForSale
        : l10n.listingForRent;
    
    String location = l10n.listingUnknownLocation;
    if (address != null) {
      if (locale == 'en') {
        location = address!.region ?? l10n.listingUnknownLocation;
      } else {
        location = cache?[address!.region] ?? address!.regionLocalized ?? address!.region ?? l10n.listingUnknownLocation;
      }
    }

    return l10n.listingsTitleTemplate(action, location, type);
  }

  String getLocalizedPrice(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = NumberFormat("#,###");

    if (priceFixed != null) {
      return l10n.listingsPriceFixed(formatter.format(priceFixed!.toInt()));
    }

    if (priceMin != null && priceMax != null) {
      return l10n.listingsPriceRange(
        formatter.format(priceMin!.toInt()),
        formatter.format(priceMax!.toInt()),
      );
    }

    return l10n.listingPriceOnRequest;
  }

  String get mainImageUrl {
    if (images.isNotEmpty) {
      return images.first.imageUrl;
    }
    return '';
  }

  String get mainThumbnailUrl {
    if (images.isNotEmpty) {
      return images.first.thumbnailUrl;
    }
    return '';
  }

  bool get isNew {
    final daysOld = DateTime.now().difference(createdAt).inDays;
    return daysOld <= 7;
  }

  bool get isVipActive => isVip;

  bool get isFeaturedActive {
    return isFeatured &&
        (featuredUntil == null || featuredUntil!.isAfter(DateTime.now()));
  }

  @override
  String toString() => "Listing(id: $id)";
}
