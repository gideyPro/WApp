import '../../../core/utils/type_utils.dart';
import 'listing_summary.dart';

/// Lifecycle of a buyer request ("order").
enum BuyerOrderStatus {
  active('active'),
  fulfilled('fulfilled'),
  cancelled('cancelled'),
  unknown('unknown');

  final String wireValue;

  const BuyerOrderStatus(this.wireValue);

  static BuyerOrderStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'active':
        return BuyerOrderStatus.active;
      case 'fulfilled':
        return BuyerOrderStatus.fulfilled;
      case 'cancelled':
        return BuyerOrderStatus.cancelled;
      default:
        return BuyerOrderStatus.unknown;
    }
  }

  bool get isActive => this == BuyerOrderStatus.active;

  bool get isCancelled => this == BuyerOrderStatus.cancelled;
}

/// State of an admin-curated listing suggestion.
enum OrderSuggestionStatus {
  pending('pending'),
  accepted('accepted'),
  declined('declined'),
  unknown('unknown');

  final String wireValue;

  const OrderSuggestionStatus(this.wireValue);

  static OrderSuggestionStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'pending':
        return OrderSuggestionStatus.pending;
      case 'accepted':
        return OrderSuggestionStatus.accepted;
      case 'declined':
        return OrderSuggestionStatus.declined;
      default:
        return OrderSuggestionStatus.unknown;
    }
  }

  bool get isPending => this == OrderSuggestionStatus.pending;
}

/// Nullable `{ min, max }` range used for budget and area.
class OrderRange {
  final double? min;
  final double? max;

  const OrderRange({this.min, this.max});

  const OrderRange.empty()
      : min = null,
        max = null;

  bool get isEmpty => min == null && max == null;

  bool get hasMin => min != null;

  bool get hasMax => max != null;

  factory OrderRange.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return OrderRange(
      min: TypeUtils.safeDouble(map['min']),
      max: TypeUtils.safeDouble(map['max']),
    );
  }
}

/// Address attached to a buyer request.
///
/// The public browse feed only carries region/zone; the VIP detail payload adds
/// woreda, kebele and the full address. Localized siblings are injected by the
/// API and used whenever the app locale is not English.
class OrderAddress {
  final int? id;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? fullAddress;
  final String? regionLocalized;
  final String? zoneLocalized;
  final String? woredaLocalized;
  final String? kebeleLocalized;

  const OrderAddress({
    this.id,
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.fullAddress,
    this.regionLocalized,
    this.zoneLocalized,
    this.woredaLocalized,
    this.kebeleLocalized,
  });

  /// Human readable address for the current locale.
  ///
  /// [broadOnly] mirrors the public teaser: only region and zone are exposed
  /// before the VIP gate, so callers must not append woreda/kebele there.
  String displayAddressFor(String locale, {bool broadOnly = false}) {
    final useLocalized = locale != 'en';

    String? pick(String? base, String? localized) =>
        useLocalized ? (_text(localized) ?? _text(base)) : _text(base);

    if (!broadOnly) {
      final explicit = _text(fullAddress);
      if (explicit != null) return explicit;
    }

    final parts = [
      pick(region, regionLocalized),
      pick(zone, zoneLocalized),
      if (!broadOnly) pick(woreda, woredaLocalized),
      if (!broadOnly) pick(kebele, kebeleLocalized),
    ].whereType<String>().toList(growable: false);

    return parts.isEmpty ? '' : parts.join(', ');
  }

  /// English/current-locale address including every exposed part.
  String get displayAddress => displayAddressFor('en');

  bool get hasBroadArea =>
      _text(region) != null ||
      _text(zone) != null ||
      _text(regionLocalized) != null ||
      _text(zoneLocalized) != null;

  factory OrderAddress.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return OrderAddress(
      id: TypeUtils.safeInt(map['id']),
      region: _text(map['region']),
      zone: _text(map['zone']),
      woreda: _text(map['woreda']),
      kebele: _text(map['kebele']),
      fullAddress: _text(map['full_address']),
      regionLocalized: _text(map['region_localized']),
      zoneLocalized: _text(map['zone_localized']),
      woredaLocalized: _text(map['woreda_localized']),
      kebeleLocalized: _text(map['kebele_localized']),
    );
  }
}

/// Public buyer details attached to an order in browse feeds.
///
/// The public browse payload intentionally omits the buyer's id so clients
/// cannot bypass the VIP contact gate; only the VIP detail includes it.
class OrderBuyer {
  final int? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatar;
  final bool isKycVerified;

  const OrderBuyer({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatar,
    this.isKycVerified = false,
  });

  /// Best available display name, or null when the API sent none.
  String? get name {
    final full = _text(fullName);
    if (full != null) return full;

    final first = _text(firstName);
    final last = _text(lastName);
    if (first == null) return last;
    return last == null ? first : '$first $last';
  }

  bool get hasName => name != null;

  String get displayName => name ?? (id == null ? 'Buyer' : 'Buyer #$id');

  factory OrderBuyer.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return OrderBuyer(
      id: TypeUtils.safeInt(map['id']),
      fullName: _text(map['full_name']),
      firstName: _text(map['first_name']),
      lastName: _text(map['last_name']),
      phoneNumber: _text(map['phone_number']),
      avatar: _text(map['google_avatar']),
      isKycVerified: TypeUtils.safeBool(map['is_kyc_verified']),
    );
  }
}

/// A buyer request from `/v2/orders`.
///
/// Named [BuyerOrder] so it can coexist with the legacy v1 `Order` model while
/// the screens migrate.
class BuyerOrder {
  final int id;
  final ListingKind type;
  final String listingType;
  final BuyerOrderStatus status;
  final String? title;
  final String description;
  final OrderRange budget;
  final OrderRange area;
  final String? holdingType;
  final String? facingDirection;
  final Map<String, dynamic>? vehicleDetails;
  final OrderAddress? address;
  final OrderBuyer? buyer;
  final bool canViewVip;
  final int suggestionsCount;
  final int unreadSuggestionsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BuyerOrder({
    required this.id,
    required this.type,
    required this.listingType,
    required this.status,
    this.title,
    required this.description,
    this.budget = const OrderRange.empty(),
    this.area = const OrderRange.empty(),
    this.holdingType,
    this.facingDirection,
    this.vehicleDetails,
    this.address,
    this.buyer,
    this.canViewVip = false,
    this.suggestionsCount = 0,
    this.unreadSuggestionsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isRental => listingType == 'rental';

  bool get isCar => type == ListingKind.car;

  bool get isProperty => type == ListingKind.house || type == ListingKind.land;

  bool get hasAddress => address != null;

  bool get hasSuggestions => suggestionsCount > 0;

  bool get hasUnreadSuggestions => unreadSuggestionsCount > 0;

  bool get canCancel => status.isActive;

  String? get vehicleMake => _text(vehicleDetails?['make']);

  String? get vehicleModel => _text(vehicleDetails?['model']);

  int? get vehicleYearMin => TypeUtils.safeInt(vehicleDetails?['year_min']);

  int? get vehicleYearMax => TypeUtils.safeInt(vehicleDetails?['year_max']);

  String? get vehicleTransmission => _text(vehicleDetails?['transmission']);

  String? get vehicleFuelType => _text(vehicleDetails?['fuel_type']);

  String? get vehicleBodyType => _text(vehicleDetails?['body_type']);

  /// Human readable vehicle summary, e.g. "Toyota Corolla".
  String? get vehicleName {
    final make = vehicleMake;
    final model = vehicleModel;
    if (make == null && model == null) return null;
    return [make, model].whereType<String>().join(' ');
  }

  factory BuyerOrder.fromJson(Map<String, dynamic> json) {
    // Older browse payloads used `location`; the current contract uses
    // `address`. Accept both so cached/fixture data keeps working.
    final rawAddress = json['address'] ?? json['location'];

    return BuyerOrder(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      type: ListingKind.parse(json['type']),
      listingType: json['listing_type']?.toString() ?? 'sale',
      status: BuyerOrderStatus.parse(json['status']),
      title: _text(json['title']),
      description: json['description']?.toString() ?? '',
      budget: OrderRange.fromJson(json['budget']),
      area: OrderRange.fromJson(json['area']),
      holdingType: _text(json['holding_type']),
      facingDirection: _text(json['facing_direction']),
      vehicleDetails: json['vehicle_details'] is Map
          ? Map<String, dynamic>.from(json['vehicle_details'] as Map)
          : null,
      address: rawAddress is Map
          ? OrderAddress.fromJson(Map<String, dynamic>.from(rawAddress))
          : null,
      buyer: json['buyer'] is Map ? OrderBuyer.fromJson(json['buyer']) : null,
      canViewVip: json['viewer'] is Map
          ? TypeUtils.safeBool(json['viewer']['can_view_vip'])
          : false,
      suggestionsCount: TypeUtils.safeInt(json['suggestions_count']) ?? 0,
      unreadSuggestionsCount:
          TypeUtils.safeInt(json['unread_suggestions_count']) ?? 0,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }
}

/// One listing curated by the admin team for a buyer request.
class OrderSuggestion {
  final int id;
  final int orderId;
  final ListingSummary? listing;
  final OrderSuggestionStatus status;
  final String stage;
  final String? adminNotes;
  final bool isRead;
  final DateTime? readAt;
  final bool canAccept;
  final bool canDecline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderSuggestion({
    required this.id,
    required this.orderId,
    this.listing,
    this.status = OrderSuggestionStatus.unknown,
    this.stage = '',
    this.adminNotes,
    this.isRead = false,
    this.readAt,
    this.canAccept = false,
    this.canDecline = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasListing => listing != null;

  bool get hasNotes => adminNotes != null && adminNotes!.isNotEmpty;

  factory OrderSuggestion.fromJson(Map<String, dynamic> json) {
    final rawListing = json['listing'];

    return OrderSuggestion(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      orderId: TypeUtils.safeInt(json['order_id']) ?? 0,
      listing: rawListing is Map
          ? ListingSummary.fromJson(Map<String, dynamic>.from(rawListing))
          : null,
      status: OrderSuggestionStatus.parse(json['status']),
      stage: json['stage']?.toString() ?? '',
      adminNotes: _text(json['admin_notes']),
      isRead: TypeUtils.safeBool(json['is_read']),
      readAt: _date(json['read_at']),
      canAccept: TypeUtils.safeBool(json['can_accept']),
      canDecline: TypeUtils.safeBool(json['can_decline']),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
