import '../../../core/utils/type_utils.dart';

/// The concrete resource behind a listing row.
///
/// `unknown` is kept for forward compatibility: a newer backend may add a
/// catalog type before the app knows how to render it.
enum ListingKind {
  house,
  land,
  car,
  job,
  unknown;

  static ListingKind parse(dynamic value) {
    switch (value?.toString()) {
      case 'house':
        return ListingKind.house;
      case 'land':
        return ListingKind.land;
      case 'car':
        return ListingKind.car;
      case 'job':
        return ListingKind.job;
      default:
        return ListingKind.unknown;
    }
  }
}

/// Price block shared by catalog cards and detail screens.
class ListingPrice {
  final double? amount;
  final String currency;
  final String? period;
  final bool negotiable;

  const ListingPrice({
    this.amount,
    this.currency = 'ETB',
    this.period,
    this.negotiable = false,
  });

  bool get hasAmount => amount != null;

  /// True for rentals, where [period] is `day`, `week`, `month` or `year`.
  bool get isRecurring => period != null;

  factory ListingPrice.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingPrice(
      amount: TypeUtils.safeDouble(map['amount']),
      currency: map['currency']?.toString() ?? 'ETB',
      period: _nonEmpty(map['period']),
      negotiable: TypeUtils.safeBool(map['negotiable']),
    );
  }
}

/// Address block. Discovery-tier viewers receive a masked payload.
class ListingLocation {
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? specificLocation;
  final String? fullAddress;
  final bool isMasked;
  final String? regionLocalized;
  final String? zoneLocalized;
  final String? woredaLocalized;
  final String? kebeleLocalized;

  const ListingLocation({
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.specificLocation,
    this.fullAddress,
    this.isMasked = false,
    this.regionLocalized,
    this.zoneLocalized,
    this.woredaLocalized,
    this.kebeleLocalized,
  });

  String get displayRegion => _nonEmpty(regionLocalized) ?? _nonEmpty(region) ?? '';

  String get displayZone => _nonEmpty(zoneLocalized) ?? _nonEmpty(zone) ?? '';

  /// Compact label for cards: "Addis Ababa, Bole".
  String get shortLabel =>
      [displayRegion, displayZone].where((part) => part.isNotEmpty).join(', ');

  factory ListingLocation.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingLocation(
      region: _nonEmpty(map['region']),
      zone: _nonEmpty(map['zone']),
      woreda: _nonEmpty(map['woreda']),
      kebele: _nonEmpty(map['kebele']),
      specificLocation: _nonEmpty(map['specific_location']),
      fullAddress: _nonEmpty(map['full_address']),
      isMasked: TypeUtils.safeBool(map['is_masked']),
      regionLocalized: _nonEmpty(map['region_localized']),
      zoneLocalized: _nonEmpty(map['zone_localized']),
      woredaLocalized: _nonEmpty(map['woreda_localized']),
      kebeleLocalized: _nonEmpty(map['kebele_localized']),
    );
  }
}

/// A single gallery/cover image.
class ListingImage {
  final int? id;
  final String? url;
  final bool isPrimary;

  const ListingImage({
    this.id,
    this.url,
    this.isPrimary = false,
  });

  bool get hasUrl => url != null && url!.isNotEmpty;

  factory ListingImage.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ListingImage(
      id: TypeUtils.safeInt(map['id']),
      url: _nonEmpty(map['url']),
      isPrimary: TypeUtils.safeBool(map['is_primary']),
    );
  }
}

/// Card-level listing projection returned by lists, home and `similar`.
class SummaryDetails {
  final int? bedrooms;
  final int? bathrooms;
  final double? areaSqm;
  final int? salons;
  final int? totalRooms;
  final int? carYear;
  final double? carMileageKm;
  final String? companyName;
  final String? jobType;

  const SummaryDetails({
    this.bedrooms,
    this.bathrooms,
    this.areaSqm,
    this.salons,
    this.totalRooms,
    this.carYear,
    this.carMileageKm,
    this.companyName,
    this.jobType,
  });

  factory SummaryDetails.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return SummaryDetails(
      bedrooms: TypeUtils.safeInt(map['bedrooms']),
      bathrooms: TypeUtils.safeInt(map['bathrooms']),
      areaSqm: TypeUtils.safeDouble(map['area_sqm']),
      salons: TypeUtils.safeInt(map['salons']),
      totalRooms: TypeUtils.safeInt(map['total_rooms']),
      carYear: TypeUtils.safeInt(map['year']),
      carMileageKm: TypeUtils.safeDouble(map['mileage_km']),
      companyName: _nonEmpty(map['company_name']),
      jobType: _nonEmpty(map['job_type']),
    );
  }
}

class ListingSummary {
  final int id;
  final ListingKind kind;
  final String listingType;
  final String title;
  final String? description;
  final ListingPrice price;
  final ListingLocation location;
  final ListingImage? coverImage;
  final int imagesCount;
  final SummaryDetails summaryDetails;
  final bool isFeatured;
  final bool isVip;
  final bool isFavorite;
  final DateTime? createdAt;

  const ListingSummary({
    required this.id,
    required this.kind,
    required this.listingType,
    required this.title,
    this.description,
    required this.price,
    required this.location,
    this.coverImage,
    this.imagesCount = 0,
    this.summaryDetails = const SummaryDetails(),
    this.isFeatured = false,
    this.isVip = false,
    this.isFavorite = false,
    this.createdAt,
  });

  bool get isRental => listingType == 'rental';

  bool get hasCoverImage => coverImage?.hasUrl == true;

  factory ListingSummary.fromJson(Map<String, dynamic> json) {
    final rawCover = json['cover_image'];
    return ListingSummary(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      kind: ListingKind.parse(json['type']),
      listingType: json['listing_type']?.toString() ?? 'sale',
      title: json['title']?.toString() ?? '',
      description: _nonEmpty(json['description']),
      price: ListingPrice.fromJson(json['price']),
      location: ListingLocation.fromJson(json['location']),
      coverImage:
          rawCover is Map ? ListingImage.fromJson(rawCover) : null,
      imagesCount: TypeUtils.safeInt(json['images_count']) ?? 0,
      summaryDetails: SummaryDetails.fromJson(json['details']),
      isFeatured: TypeUtils.safeBool(json['is_featured']),
      isVip: TypeUtils.safeBool(json['is_vip']),
      isFavorite: TypeUtils.safeBool(json['is_favorite']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  ListingSummary copyWith({
    bool? isFavorite,
    String? description,
    SummaryDetails? summaryDetails,
  }) {
    return ListingSummary(
      id: id,
      kind: kind,
      listingType: listingType,
      title: title,
      description: description ?? this.description,
      price: price,
      location: location,
      coverImage: coverImage,
      imagesCount: imagesCount,
      summaryDetails: summaryDetails ?? this.summaryDetails,
      isFeatured: isFeatured,
      isVip: isVip,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}

String? _nonEmpty(dynamic value) {
  final text = value?.toString();
  return (text == null || text.isEmpty) ? null : text;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
