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

/// Exact address attached to a buyer request.
///
/// Unlike catalog locations this is never masked: the buyer chose it.
class OrderAddress {
  final int? id;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? fullAddress;

  const OrderAddress({
    this.id,
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.fullAddress,
  });

  String get displayAddress {
    final explicit = _text(fullAddress);
    if (explicit != null) return explicit;

    final parts = [region, zone, woreda, kebele]
        .map(_text)
        .whereType<String>()
        .toList(growable: false);

    return parts.isEmpty ? '' : parts.join(', ');
  }

  factory OrderAddress.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return OrderAddress(
      id: TypeUtils.safeInt(map['id']),
      region: _text(map['region']),
      zone: _text(map['zone']),
      woreda: _text(map['woreda']),
      kebele: _text(map['kebele']),
      fullAddress: _text(map['full_address']),
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
  final String description;
  final OrderRange budget;
  final OrderRange area;
  final String? holdingType;
  final String? facingDirection;
  final OrderAddress? address;
  final int suggestionsCount;
  final int unreadSuggestionsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BuyerOrder({
    required this.id,
    required this.type,
    required this.listingType,
    required this.status,
    required this.description,
    this.budget = const OrderRange.empty(),
    this.area = const OrderRange.empty(),
    this.holdingType,
    this.facingDirection,
    this.address,
    this.suggestionsCount = 0,
    this.unreadSuggestionsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get isRental => listingType == 'rental';

  bool get hasAddress => address != null;

  bool get hasSuggestions => suggestionsCount > 0;

  bool get hasUnreadSuggestions => unreadSuggestionsCount > 0;

  bool get canCancel => status.isActive;

  factory BuyerOrder.fromJson(Map<String, dynamic> json) {
    final rawAddress = json['address'];

    return BuyerOrder(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      type: ListingKind.parse(json['type']),
      listingType: json['listing_type']?.toString() ?? 'sale',
      status: BuyerOrderStatus.parse(json['status']),
      description: json['description']?.toString() ?? '',
      budget: OrderRange.fromJson(json['budget']),
      area: OrderRange.fromJson(json['area']),
      holdingType: _text(json['holding_type']),
      facingDirection: _text(json['facing_direction']),
      address: rawAddress is Map
          ? OrderAddress.fromJson(Map<String, dynamic>.from(rawAddress))
          : null,
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
