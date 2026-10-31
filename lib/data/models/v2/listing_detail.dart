import '../../../core/utils/type_utils.dart';
import 'listing_summary.dart';

/// Listing-level attributes shared by every property type.
class ListingAttributes {
  final String? specificLocation;
  final String? useType;
  final String? facingDirection;
  final double? totalSquareMeters;
  final double? frontAreaSqm;
  final double? sideAreaSqm;
  final bool hasDebtOrEncumbrance;
  final double? debtAmount;
  final bool priceRevisionPossible;
  final String? holdingType;

  const ListingAttributes({
    this.specificLocation,
    this.useType,
    this.facingDirection,
    this.totalSquareMeters,
    this.frontAreaSqm,
    this.sideAreaSqm,
    this.hasDebtOrEncumbrance = false,
    this.debtAmount,
    this.priceRevisionPossible = false,
    this.holdingType,
  });

  factory ListingAttributes.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingAttributes(
      specificLocation: _text(map['specific_location']),
      useType: _text(map['use_type']),
      facingDirection: _text(map['facing_direction']),
      totalSquareMeters: TypeUtils.safeDouble(map['total_square_meters']),
      frontAreaSqm: TypeUtils.safeDouble(map['front_area_sqm']),
      sideAreaSqm: TypeUtils.safeDouble(map['side_area_sqm']),
      hasDebtOrEncumbrance: TypeUtils.safeBool(map['has_debt_or_encumbrance']),
      debtAmount: TypeUtils.safeDouble(map['debt_amount']),
      priceRevisionPossible: TypeUtils.safeBool(map['price_revision_possible']),
      holdingType: _text(map['holding_type']),
    );
  }
}

/// Type-specific fields. Only the keys for the listing's [ListingKind] are
/// populated, so every field is nullable.
///
/// [raw] keeps the original map so newer backend keys stay available to UI
/// code without a model release.
class ListingDetails {
  final Map<String, dynamic> raw;

  // House
  final int? bedrooms;
  final int? bathrooms;
  final int? kitchens;
  final double? areaSqm;
  final String? houseType;
  final int? yearBuilt;
  final bool parkingAvailable;
  final bool electricity;
  final bool water;

  // Land
  final String? landType;
  final String? direction;

  // Car
  final String? make;
  final String? model;
  final int? year;
  final double? mileageKm;
  final String? transmission;
  final String? fuelType;
  final String? bodyType;
  final String? vehicleCategory;
  final String? condition;
  final String? color;
  final bool negotiable;

  // Job
  final String? companyName;
  final String? jobType;
  final String? jobCategory;
  final int? positionsCount;
  final String? salaryType;
  final double? salaryMin;
  final double? salaryMax;
  final String? salaryCurrency;
  final String? education;
  final DateTime? deadline;

  const ListingDetails({
    this.raw = const {},
    this.bedrooms,
    this.bathrooms,
    this.kitchens,
    this.areaSqm,
    this.houseType,
    this.yearBuilt,
    this.parkingAvailable = false,
    this.electricity = false,
    this.water = false,
    this.landType,
    this.direction,
    this.make,
    this.model,
    this.year,
    this.mileageKm,
    this.transmission,
    this.fuelType,
    this.bodyType,
    this.vehicleCategory,
    this.condition,
    this.color,
    this.negotiable = false,
    this.companyName,
    this.jobType,
    this.jobCategory,
    this.positionsCount,
    this.salaryType,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.education,
    this.deadline,
  });

  bool get isEmpty => raw.isEmpty;

  bool get hasSalaryRange => salaryMin != null || salaryMax != null;

  factory ListingDetails.fromJson(dynamic json) {
    final map = json is Map
        ? Map<String, dynamic>.from(json)
        : const <String, dynamic>{};
    return ListingDetails(
      raw: map,
      bedrooms: TypeUtils.safeInt(map['bedrooms']),
      bathrooms: TypeUtils.safeInt(map['bathrooms']),
      kitchens: TypeUtils.safeInt(map['kitchens']),
      areaSqm: TypeUtils.safeDouble(map['area_sqm']),
      houseType: _text(map['house_type']),
      yearBuilt: TypeUtils.safeInt(map['year_built']),
      parkingAvailable: TypeUtils.safeBool(map['parking_available']),
      electricity: TypeUtils.safeBool(map['electricity']),
      water: TypeUtils.safeBool(map['water']),
      landType: _text(map['land_type']),
      direction: _text(map['direction']),
      make: _text(map['make']),
      model: _text(map['model']),
      year: TypeUtils.safeInt(map['year']),
      mileageKm: TypeUtils.safeDouble(map['mileage_km']),
      transmission: _text(map['transmission']),
      fuelType: _text(map['fuel_type']),
      bodyType: _text(map['body_type']),
      vehicleCategory: _text(map['vehicle_category']),
      condition: _text(map['condition']),
      color: _text(map['color']),
      negotiable: TypeUtils.safeBool(map['negotiable']),
      companyName: _text(map['company_name']),
      jobType: _text(map['job_type']),
      jobCategory: _text(map['job_category']),
      positionsCount: TypeUtils.safeInt(map['positions_count']),
      salaryType: _text(map['salary_type']),
      salaryMin: TypeUtils.safeDouble(map['salary_min']),
      salaryMax: TypeUtils.safeDouble(map['salary_max']),
      salaryCurrency: _text(map['salary_currency']),
      education: _text(map['education']),
      deadline: _date(map['deadline']),
    );
  }
}

/// Private (free-hold) holding metadata.
class PrivateHoldingDetails {
  final int? taxPaidUntilYear;
  final String? acquisitionClarification;

  const PrivateHoldingDetails({
    this.taxPaidUntilYear,
    this.acquisitionClarification,
  });

  factory PrivateHoldingDetails.fromJson(Map<String, dynamic> json) {
    return PrivateHoldingDetails(
      taxPaidUntilYear: TypeUtils.safeInt(json['tax_paid_until_year']),
      acquisitionClarification: _text(json['acquisition_clarification']),
    );
  }
}

/// Lease holding metadata.
class LeaseHoldingDetails {
  final int? leasedYear;
  final double? leasePricePerSqm;
  final double? annualPayment;
  final String? buildType;

  const LeaseHoldingDetails({
    this.leasedYear,
    this.leasePricePerSqm,
    this.annualPayment,
    this.buildType,
  });

  factory LeaseHoldingDetails.fromJson(Map<String, dynamic> json) {
    return LeaseHoldingDetails(
      leasedYear: TypeUtils.safeInt(json['leased_year']),
      leasePricePerSqm: TypeUtils.safeDouble(json['lease_price_per_sqm']),
      annualPayment: TypeUtils.safeDouble(json['annual_payment']),
      buildType: _text(json['build_type']),
    );
  }
}

/// Cooperative holding metadata.
class CooperativeHoldingDetails {
  final String? cooperativeName;
  final String? cooperativeCode;
  final String? buildingStatus;

  const CooperativeHoldingDetails({
    this.cooperativeName,
    this.cooperativeCode,
    this.buildingStatus,
  });

  factory CooperativeHoldingDetails.fromJson(Map<String, dynamic> json) {
    return CooperativeHoldingDetails(
      cooperativeName: _text(json['cooperative_name']),
      cooperativeCode: _text(json['cooperative_code']),
      buildingStatus: _text(json['building_status']),
    );
  }
}

/// Only the recorded holding type is loaded; the other two are null.
class HoldingDetails {
  final PrivateHoldingDetails? private;
  final LeaseHoldingDetails? lease;
  final CooperativeHoldingDetails? cooperative;

  const HoldingDetails({
    this.private,
    this.lease,
    this.cooperative,
  });

  bool get isEmpty => private == null && lease == null && cooperative == null;

  factory HoldingDetails.fromJson(dynamic json) {
    final map = json is Map ? json : const {};

    return HoldingDetails(
      private: map['private'] is Map
          ? PrivateHoldingDetails.fromJson(
              Map<String, dynamic>.from(map['private'] as Map))
          : null,
      lease: map['lease'] is Map
          ? LeaseHoldingDetails.fromJson(
              Map<String, dynamic>.from(map['lease'] as Map))
          : null,
      cooperative: map['cooperative'] is Map
          ? CooperativeHoldingDetails.fromJson(
              Map<String, dynamic>.from(map['cooperative'] as Map))
          : null,
    );
  }
}

/// Video URL is nulled by the backend when the viewer is not entitled.
class ListingVideo {
  final String? url;
  final String? thumbnailUrl;
  final bool blocked;

  const ListingVideo({this.url, this.thumbnailUrl, this.blocked = false});

  bool get hasUrl => url != null && url!.isNotEmpty;

  factory ListingVideo.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingVideo(
      url: _text(map['url']),
      thumbnailUrl: _text(map['thumbnail_url']),
      blocked: TypeUtils.safeBool(map['blocked']),
    );
  }
}

/// Contact info is null until the viewer is the owner or revealed contact.
class ListingSeller {
  final String? name;
  final String? phone;
  final bool hidden;

  const ListingSeller({
    this.name,
    this.phone,
    this.hidden = true,
  });

  factory ListingSeller.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingSeller(
      name: _text(map['name']),
      phone: _text(map['phone']),
      hidden: map['hidden'] == null
          ? true
          : TypeUtils.safeBool(map['hidden'], defaultValue: true),
    );
  }
}

/// Per-viewer entitlements and relationship state.
class ListingViewer {
  final bool isOwner;
  final bool isFavorite;
  final bool contactAllowed;
  final bool contactRevealed;
  final int contactsRemaining;
  final int contactsMax;
  final bool videoAllowed;
  final bool vipBlocked;
  final String? interestStatus;
  final int? interestId;

  const ListingViewer({
    this.isOwner = false,
    this.isFavorite = false,
    this.contactAllowed = false,
    this.contactRevealed = false,
    this.contactsRemaining = 0,
    this.contactsMax = 0,
    this.videoAllowed = false,
    this.vipBlocked = false,
    this.interestStatus,
    this.interestId,
  });

  bool get canRevealContact => contactAllowed && !contactRevealed;
  bool get canWatchVideo => videoAllowed;

  factory ListingViewer.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingViewer(
      isOwner: TypeUtils.safeBool(map['is_owner']),
      isFavorite: TypeUtils.safeBool(map['is_favorite']),
      contactAllowed: TypeUtils.safeBool(map['contact_allowed']),
      contactRevealed: TypeUtils.safeBool(map['contact_revealed']),
      contactsRemaining: TypeUtils.safeInt(map['contacts_remaining']) ?? 0,
      contactsMax: TypeUtils.safeInt(map['contacts_max']) ?? 0,
      videoAllowed: TypeUtils.safeBool(map['video_allowed']),
      vipBlocked: TypeUtils.safeBool(map['vip_blocked']),
      interestStatus: _text(map['interest_status']),
      interestId: TypeUtils.safeInt(map['interest_id']),
    );
  }
}

/// Full listing payload: summary projection plus detail-only blocks.
class ListingDetail extends ListingSummary {
  final List<ListingImage> images;
  final ListingAttributes attributes;
  final ListingDetails details;
  final HoldingDetails holdingDetails;
  final ListingVideo video;
  final ListingSeller seller;
  final ListingViewer viewer;
  final List<ListingSummary> similar;

  const ListingDetail({
    required super.id,
    required super.kind,
    required super.listingType,
    required super.title,
    required super.price,
    required super.location,
    super.coverImage,
    super.imagesCount,
    super.isFeatured,
    super.isVip,
    super.isFavorite,
    super.createdAt,
    super.description,
    this.images = const [],
    this.attributes = const ListingAttributes(),
    this.details = const ListingDetails(),
    this.holdingDetails = const HoldingDetails(),
    this.video = const ListingVideo(),
    this.seller = const ListingSeller(),
    this.viewer = const ListingViewer(),
    this.similar = const [],
  });

  factory ListingDetail.fromJson(Map<String, dynamic> json) {
    final summary = ListingSummary.fromJson(json);
    final rawImages = json['images'];
    final rawSimilar = json['similar'];

    return ListingDetail(
      id: summary.id,
      kind: summary.kind,
      listingType: summary.listingType,
      title: summary.title,
      price: summary.price,
      location: summary.location,
      coverImage: summary.coverImage,
      imagesCount: summary.imagesCount,
      isFeatured: summary.isFeatured,
      isVip: summary.isVip,
      isFavorite: summary.isFavorite,
      createdAt: summary.createdAt,
      description: _text(json['description']),
      images: rawImages is List
          ? rawImages
              .whereType<Map>()
              .map((image) =>
                  ListingImage.fromJson(Map<String, dynamic>.from(image)))
              .toList(growable: false)
          : const [],
      attributes: ListingAttributes.fromJson(json['attributes']),
      details: ListingDetails.fromJson(json['details']),
      holdingDetails: HoldingDetails.fromJson(json['holding_details']),
      video: ListingVideo.fromJson(json['video']),
      seller: ListingSeller.fromJson(json['seller']),
      viewer: ListingViewer.fromJson(json['viewer']),
      similar: rawSimilar is List
          ? rawSimilar
              .whereType<Map>()
              .map((item) =>
                  ListingSummary.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }

  @override
  ListingDetail copyWith({
    bool? isFavorite,
    String? description,
    bool? contactRevealed,
  }) {
    return ListingDetail(
      id: id,
      kind: kind,
      listingType: listingType,
      title: title,
      price: price,
      location: location,
      coverImage: coverImage,
      imagesCount: imagesCount,
      isFeatured: isFeatured,
      isVip: isVip,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      description: description ?? this.description,
      images: images,
      attributes: attributes,
      details: details,
      holdingDetails: holdingDetails,
      video: video,
      seller: seller,
      viewer: contactRevealed == null
          ? viewer
          : ListingViewer(
              isOwner: viewer.isOwner,
              isFavorite: isFavorite ?? viewer.isFavorite,
              contactAllowed: viewer.contactAllowed,
              contactRevealed: contactRevealed,
              contactsRemaining: viewer.contactsRemaining,
              contactsMax: viewer.contactsMax,
              videoAllowed: viewer.videoAllowed,
              vipBlocked: viewer.vipBlocked,
              interestStatus: viewer.interestStatus,
              interestId: viewer.interestId,
            ),
      similar: similar,
    );
  }
}

String? _text(dynamic value) {
  final text = value?.toString();
  return (text == null || text.isEmpty) ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
