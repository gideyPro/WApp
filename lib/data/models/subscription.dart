import 'dart:convert';
import '../../l10n/app_localizations.dart';

enum DetailsAccess {
  discovery,
  withoutVideoAndContact,
  withoutContact,
  moderatedContact,
  full
}

class PriceInfo {
  final double original;
  final double discounted;
  final String? type; // 'upgrade' or 'overall'
  final double? discountPercentage;

  const PriceInfo({
    required this.original,
    required this.discounted,
    this.type,
    this.discountPercentage,
  });

  bool get hasDiscount => type != null && discounted < original;
  bool get isUpgrade => type == 'upgrade';
}

/// Billing Cycle option for a Subscription Plan (e.g., 1, 3, 6 months)
class PlanBillingCycle {
  final int months;
  final double price;
  final double priceUsd;
  final int listingDurationDays;
  final int discountPercent;
  final String? badge;

  /// Price after upgrade/promo rules, when the API provides it.
  final double? effectivePrice;
  final double? effectivePriceUsd;

  /// Stored list price before upgrade/promo rules.
  final double? originalPrice;
  final double? originalPriceUsd;

  /// Extra discount applied on top of the cycle price (0 when none).
  final int appliedDiscountPercent;
  final String? appliedDiscountType; // 'upgrade' or 'overall'

  const PlanBillingCycle({
    required this.months,
    required this.price,
    this.priceUsd = 0.0,
    required this.listingDurationDays,
    this.discountPercent = 0,
    this.badge,
    this.effectivePrice,
    this.effectivePriceUsd,
    this.originalPrice,
    this.originalPriceUsd,
    this.appliedDiscountPercent = 0,
    this.appliedDiscountType,
  });

  bool get hasAppliedDiscount => appliedDiscountPercent > 0;
  bool get isUpgradeDiscount => appliedDiscountType == 'upgrade';

  factory PlanBillingCycle.fromJson(Map<String, dynamic> json) {
    double? optionalDouble(String key) =>
        json[key] == null ? null : SubscriptionPlan._parseDouble(json[key]);

    return PlanBillingCycle(
      months: json['months'] is int
          ? json['months'] as int
          : int.tryParse(json['months']?.toString() ?? '1') ?? 1,
      price: SubscriptionPlan._parseDouble(json['price']),
      priceUsd: SubscriptionPlan._parseDouble(json['price_usd']),
      listingDurationDays: json['listing_duration_days'] is int
          ? json['listing_duration_days'] as int
          : int.tryParse(json['listing_duration_days']?.toString() ?? '30') ?? 30,
      discountPercent: json['discount_percent'] is int
          ? json['discount_percent'] as int
          : int.tryParse(json['discount_percent']?.toString() ?? '0') ?? 0,
      badge: json['badge']?.toString(),
      effectivePrice: optionalDouble('effective_price'),
      effectivePriceUsd: optionalDouble('effective_price_usd'),
      originalPrice: optionalDouble('original_price'),
      originalPriceUsd: optionalDouble('original_price_usd'),
      appliedDiscountPercent: json['applied_discount_percent'] is int
          ? json['applied_discount_percent'] as int
          : int.tryParse(json['applied_discount_percent']?.toString() ?? '0') ??
              0,
      appliedDiscountType: json['applied_discount_type']?.toString(),
    );
  }

  double effectivePriceFor(String currency) => currency == 'USD'
      ? (effectivePriceUsd ?? priceUsd)
      : (effectivePrice ?? price);

  double originalPriceFor(String currency) => currency == 'USD'
      ? (originalPriceUsd ?? priceUsd)
      : (originalPrice ?? price);

  String getDisplayPrice(String currency) {
    final value = effectivePriceFor(currency);
    if (currency == 'USD') return '\$${value.toStringAsFixed(2)}';
    return '${value.toStringAsFixed(0)} ETB';
  }

  String getOriginalDisplayPrice(String currency) {
    final value = originalPriceFor(currency);
    if (currency == 'USD') return '\$${value.toStringAsFixed(2)}';
    return '${value.toStringAsFixed(0)} ETB';
  }

  Map<String, dynamic> toJson() => {
    'months': months,
    'price': price,
    'price_usd': priceUsd,
    'listing_duration_days': listingDurationDays,
    'discount_percent': discountPercent,
    'badge': badge,
    'effective_price': effectivePrice,
    'effective_price_usd': effectivePriceUsd,
    'original_price': originalPrice,
    'original_price_usd': originalPriceUsd,
    'applied_discount_percent': appliedDiscountPercent,
    'applied_discount_type': appliedDiscountType,
  };
}

/// Subscription Plan Model
class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double priceUsd;
  final int durationMonths;
  final int listingDurationDays;
  final List<PlanBillingCycle> billingCycles;
  final int maxListings;
  final int maxRentalListings;
  final int maxVehicles;
  final int maxRentalVehicles;
  final int maxJobs;
  final int maxFeaturedListings;
  final bool viewVip;
  final int maxOrders;
  final int maxContacts;
  final int maxRentalContacts;
  final int maxRentalContactsCar;
  final DetailsAccess detailsAccess;
  final List<String>? features;
  final bool isActive;
  final int? sortOrder;
  final PriceInfo? priceInfo;
  final int? trialDays;
  final bool canStartTrial;
  final int? billingCycleDays;
  final String planType;
  final Map<String, dynamic>? planFeatures;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.priceUsd = 0.0,
    this.durationMonths = 1,
    this.listingDurationDays = 30,
    this.billingCycles = const [],
    this.maxListings = 1,
    this.maxRentalListings = 0,
    this.maxVehicles = 0,
    this.maxRentalVehicles = 0,
    this.maxJobs = 0,
    this.maxFeaturedListings = 0,
    this.viewVip = false,
    this.maxOrders = 0,
    this.maxContacts = 0,
    this.maxRentalContacts = 0,
    this.maxRentalContactsCar = 0,
    this.detailsAccess = DetailsAccess.discovery,
    this.features,
    this.isActive = true,
    this.sortOrder,
    this.priceInfo,
    this.trialDays,
    this.canStartTrial = false,
    this.billingCycleDays,
    this.planType = 'marketplace',
    this.planFeatures,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final planFeatures = _parsePlanFeatures(json['plan_features']);
    final durationMonths = json['duration_months'] is int
        ? json['duration_months'] as int
        : int.tryParse(json['duration_months']?.toString() ?? '1') ?? 1;
    final listingDurationDays = json['listing_duration_days'] is int
        ? json['listing_duration_days'] as int
        : int.tryParse(json['listing_duration_days']?.toString() ?? '30') ?? 30;

    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: _parseDouble(json['price']),
      priceUsd: _parseDouble(json['price_usd']),
      durationMonths: durationMonths,
      listingDurationDays: listingDurationDays,
      billingCycles: _parseBillingCycles(
        json['billing_cycles'],
        json['price'],
        json['price_usd'],
        listingDurationDays,
        durationMonths,
      ),
      maxListings: json['max_listings'] ?? 1,
      maxRentalListings: json['max_rental_listings'] ?? 0,
      maxVehicles: json['max_vehicles'] ?? 0,
      maxRentalVehicles: json['max_rental_vehicles'] ?? 0,
      maxJobs: json['max_jobs'] ?? 0,
      maxFeaturedListings: json['max_featured_listings'] ?? 0,
      viewVip: json['view_vip'] ?? false,
      maxOrders: json['max_orders'] ?? 0,
      maxContacts: json['max_contacts'] ?? 0,
      maxRentalContacts: json['max_rental_contacts'] ?? json['max_contacts'] ?? 0,
      maxRentalContactsCar: json['max_rental_contacts_car'] ??
          _parseIntOrNull(planFeatures?['max_rental_contacts_car']) ??
          0,
      detailsAccess: _parseDetailsAccess(json['details_access']),
      features: _parseFeatures(json['features']),
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'],
      priceInfo: _parsePriceInfo(json['price_info']),
      trialDays: json['trial_days'],
      canStartTrial: json['can_start_trial'] == true,
      billingCycleDays: json['billing_cycle_days'],
      planType: json['plan_type']?.toString() ?? 'marketplace',
      planFeatures: planFeatures,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static PriceInfo? _parsePriceInfo(dynamic value) {
    if (value == null || value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final original = _parseDouble(map['original']);
    final discounted = _parseDouble(map['discounted']);
    if (original == 0 && discounted == 0) return null;
    return PriceInfo(
      original: original,
      discounted: discounted,
      type: map['type']?.toString(),
      discountPercentage: map['rule'] != null && map['rule'] is Map
          ? _parseDouble((map['rule'] as Map)['discount_percentage'])
          : null,
    );
  }

  static DetailsAccess _parseDetailsAccess(dynamic value) {
    if (value == null) return DetailsAccess.discovery;
    final str = value.toString();
    switch (str) {
      case 'without_video_and_contact':
        return DetailsAccess.withoutVideoAndContact;
      case 'without_contact':
        return DetailsAccess.withoutContact;
      case 'moderated_contact':
        return DetailsAccess.moderatedContact;
      case 'full':
        return DetailsAccess.full;
      default:
        return DetailsAccess.discovery;
    }
  }

  static List<String>? _parseFeatures(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.whereType<String>().toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.whereType<String>().toList();
        }
      } catch (_) {}
    }
    return null;
  }

  /// Normalize `plan_features` into a flat `{feature_key: value}` map.
  ///
  /// The API serializes this key in two shapes:
  ///  - `/api/subscriptions` `plans[]`: a flat map (built by `planFeatureMap`)
  ///  - `current_subscription.plan`: the raw `planFeatures` relation, i.e. a
  ///    list of pivot rows (`feature_key`, `value_type`, `int_value`, ...)
  ///
  /// Indexing the list shape with a string key throws
  /// "type 'String' is not a subtype of type 'int' of 'index'".
  static Map<String, dynamic>? _parsePlanFeatures(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List) {
      final map = <String, dynamic>{};
      for (final row in value) {
        if (row is! Map) continue;
        final key = row['feature_key']?.toString();
        if (key == null || key.isEmpty) continue;
        map[key] = switch (row['value_type']) {
          'integer' => row['int_value'],
          'boolean' => row['bool_value'],
          'string' => row['string_value'],
          _ => row['string_value'] ?? row['int_value'] ?? row['bool_value'],
        };
      }
      return map.isEmpty ? null : map;
    }
    return null;
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse double from various types (String, num, double)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<PlanBillingCycle> _parseBillingCycles(
    dynamic value,
    dynamic defaultPrice,
    dynamic defaultPriceUsd,
    dynamic defaultDuration,
    int durationMonths,
  ) {
    if (value is List && value.isNotEmpty) {
      return value
          .whereType<Map>()
          .map((item) => PlanBillingCycle.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    final p = _parseDouble(defaultPrice);
    final pUsd = _parseDouble(defaultPriceUsd);
    final duration = defaultDuration is int
        ? defaultDuration
        : int.tryParse(defaultDuration?.toString() ?? '30') ?? 30;
    if (p == 0 && pUsd == 0) {
      return [
        PlanBillingCycle(
          months: durationMonths > 0 ? durationMonths : 12,
          price: 0,
          priceUsd: 0,
          listingDurationDays: duration > 0 ? duration : 30,
        ),
      ];
    }
    if (durationMonths > 1) {
      return [
        PlanBillingCycle(
          months: durationMonths,
          price: p,
          priceUsd: pUsd,
          listingDurationDays: duration > 0 ? duration : (30 * durationMonths),
        ),
      ];
    }
    return [
      PlanBillingCycle(months: 1, price: p, priceUsd: pUsd, listingDurationDays: duration),
      PlanBillingCycle(months: 3, price: (p * 3 * 0.9).roundToDouble(), priceUsd: (pUsd * 3 * 0.9), listingDurationDays: duration * 3, discountPercent: 10, badge: 'Popular'),
      PlanBillingCycle(months: 6, price: (p * 6 * 0.8).roundToDouble(), priceUsd: (pUsd * 6 * 0.8), listingDurationDays: duration * 6, discountPercent: 20, badge: 'Best Value'),
    ];
  }

  PlanBillingCycle? getBillingCycle(int months) {
    if (billingCycles.isEmpty) return null;
    for (final cycle in billingCycles) {
      if (cycle.months == months) return cycle;
    }
    return billingCycles.first;
  }

  int getListingDurationForMonths(int months) {
    final cycle = getBillingCycle(months);
    if (cycle != null) return cycle.listingDurationDays;
    return listingDurationDays * (months > 0 ? months : 1);
  }

  String get displayPrice => '${price.toStringAsFixed(0)} ETB';
  String get displayPriceUsd => '\$${priceUsd.toStringAsFixed(2)}';

  String getDisplayPrice(String currency) {
    if (currency == 'USD') return displayPriceUsd;
    return displayPrice;
  }

  String get durationLabel {
    if (billingCycleDays != null && billingCycleDays! > 0) {
      return '$billingCycleDays Days';
    }
    if (durationMonths == 1) return '1 Month';
    if (durationMonths == 3) return '3 Months';
    if (durationMonths == 6) return '6 Months';
    if (durationMonths == 12) return '1 Year';
    return '$durationMonths Months';
  }

  bool get isFree => price == 0;
  bool get hasTrial => (trialDays ?? 0) > 0;

  int getQuota(String key) {
    if (planFeatures != null && planFeatures!.containsKey(key)) {
      final val = planFeatures![key];
      if (val is int) return val;
      if (val is num) return val.toInt();
    }
    switch (key) {
      case 'max_listings':
        return maxListings;
      case 'max_rental_listings':
        return maxRentalListings;
      case 'max_vehicles':
        return maxVehicles;
      case 'max_rental_vehicles':
        return maxRentalVehicles;
      case 'max_jobs':
        return maxJobs;
      case 'max_featured_listings':
        return maxFeaturedListings;
      case 'max_orders':
        return maxOrders;
      case 'max_contacts':
        return maxContacts;
      default:
        return 0;
    }
  }

  bool hasFeature(String key) {
    if (planFeatures != null && planFeatures!.containsKey(key)) {
      final val = planFeatures![key];
      if (val is bool) return val;
    }
    switch (key) {
      case 'view_vip':
        return viewVip;
      default:
        return false;
    }
  }

  /// Resolve information depth for a specific model (e.g. 'car', 'job', 'listing').
  /// Checks dynamic planFeatures['details_access_<model>'] before falling back to plan's detailsAccess.
  DetailsAccess detailsAccessFor(String model) {
    final normalized = model.toLowerCase();
    final specificKey = 'details_access_$normalized';
    if (planFeatures != null && planFeatures!.containsKey(specificKey)) {
      final val = planFeatures![specificKey];
      if (val != null && val.toString().isNotEmpty && val.toString() != 'default') {
        return _parseDetailsAccess(val);
      }
    }
    return detailsAccess;
  }

  /// Whether the plan allows watching video for a specific model.
  bool canSeeVideoFor(String model) {
    final access = detailsAccessFor(model);
    return access == DetailsAccess.withoutContact ||
        access == DetailsAccess.moderatedContact ||
        access == DetailsAccess.full;
  }

  /// Whether the plan allows viewing seller contact for a specific model.
  bool canSeeContactFor(String model) {
    return detailsAccessFor(model) == DetailsAccess.full;
  }

  /// Resolve max contact views for a specific model (e.g. 'car', 'job', 'listing') and listing type.
  /// Checks dynamic planFeatures / explicit quotas before falling back hierarchy.
  int maxContactsFor(String model, {String? listingType}) {
    final normalized = model.toLowerCase();
    final isRental = listingType?.toLowerCase() == 'rental';
    final specificKey = (normalized == 'car' || normalized == 'vehicle')
        ? (isRental ? 'max_rental_contacts_car' : 'max_contacts_car')
        : ((normalized == 'job' || normalized == 'jobposting')
            ? 'max_contacts_job'
            : (isRental ? 'max_rental_contacts' : 'max_contacts'));

    if (planFeatures != null && planFeatures!.containsKey(specificKey)) {
      final val = planFeatures![specificKey];
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val != null) {
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }

    if (isRental) {
      if (normalized == 'car' || normalized == 'vehicle') {
        if (maxRentalContactsCar > 0) return maxRentalContactsCar;
        return maxContactsFor(model, listingType: 'sale');
      }
      if (maxRentalContacts > 0) return maxRentalContacts;
      return maxContacts;
    }

    if (normalized == 'car' || normalized == 'vehicle') {
      final carMax = planFeatures?['max_contacts_car'];
      if (carMax != null) {
        final parsed = int.tryParse(carMax.toString());
        if (parsed != null) return parsed;
      }
      return maxContacts;
    }

    return maxContacts;
  }
}

/// User Subscription Model
class Subscription {
  final int id;
  final int userId;
  final int planId;
  final String status;
  final DateTime startsAt;
  final DateTime? endsAt;
  final DateTime? cancelledAt;
  final DateTime? expiredAt;
  final DateTime? trialEndsAt;
  final String? billingLabel;
  final int billingCycleMonths;
  final int? listingDurationDays;
  final int listingsUsed;
  final int rentalListingsUsed;
  final int vehiclesUsed;
  final int rentalVehiclesUsed;
  final int jobsUsed;
  final int featuredListingsUsed;
  final int ordersUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionPlan? plan;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    this.status = 'active',
    required this.startsAt,
    this.endsAt,
    this.cancelledAt,
    this.expiredAt,
    this.trialEndsAt,
    this.billingLabel,
    this.billingCycleMonths = 1,
    this.listingDurationDays,
    this.listingsUsed = 0,
    this.rentalListingsUsed = 0,
    this.vehiclesUsed = 0,
    this.rentalVehiclesUsed = 0,
    this.jobsUsed = 0,
    this.featuredListingsUsed = 0,
    this.ordersUsed = 0,
    this.createdAt,
    this.updatedAt,
    this.plan,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      status: json['status'] ?? 'active',
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'])
          : DateTime.now(),
      endsAt: json['ends_at'] != null ? DateTime.parse(json['ends_at']) : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'])
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'])
          : null,
      billingLabel: json['billing_label']?.toString(),
      billingCycleMonths: json['billing_cycle_months'] is int
          ? json['billing_cycle_months'] as int
          : int.tryParse(json['billing_cycle_months']?.toString() ?? '1') ?? 1,
      listingDurationDays: json['listing_duration_days'] is int
          ? json['listing_duration_days'] as int
          : int.tryParse(json['listing_duration_days']?.toString() ?? ''),
      listingsUsed: json['listings_used'] ?? 0,
      rentalListingsUsed: json['rental_listings_used'] ?? 0,
      vehiclesUsed: json['vehicles_used'] ?? 0,
      rentalVehiclesUsed: json['rental_vehicles_used'] ?? 0,
      jobsUsed: json['jobs_used'] ?? 0,
      featuredListingsUsed: json['featured_listings_used'] ?? 0,
      ordersUsed: json['orders_used'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      plan:
          json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
    );
  }

  bool get isActive =>
      status == 'active' &&
      (cancelledAt == null || cancelledAt!.isAfter(DateTime.now())) &&
      (endsAt == null || endsAt!.isAfter(DateTime.now()));

  bool get isOnTrial =>
      trialEndsAt != null &&
      isActive &&
      trialEndsAt!.isAfter(DateTime.now());

  int get effectiveListingDurationDays =>
      listingDurationDays ?? plan?.getListingDurationForMonths(billingCycleMonths) ?? 30;

  bool get isExpired => status == 'expired' || (endsAt != null && endsAt!.isBefore(DateTime.now()));

  bool get isCancelled => status == 'cancelled' || cancelledAt != null;

  int get daysRemaining {
    if (endsAt == null) return 999;
    final now = DateTime.now();
    if (endsAt!.isBefore(now)) return 0;
    return endsAt!.difference(now).inDays;
  }

  String getStatusLabel(AppLocalizations l10n) {
    if (isCancelled) return l10n.statusCancelled;
    if (isExpired) return l10n.statusExpired;
    return l10n.statusActive;
  }
}
