import '../../../core/utils/type_utils.dart';

/// One purchasable duration of a subscription plan.
///
/// Cycles are authoritative in v2; there is no plan-level price or duration.
class BillingCycle {
  final int months;
  final double price;
  final double priceUsd;
  final double originalPrice;
  final double originalPriceUsd;
  final int discountPercent;
  final int? listingDays;
  final String? badge;

  const BillingCycle({
    required this.months,
    required this.price,
    this.priceUsd = 0,
    this.originalPrice = 0,
    this.originalPriceUsd = 0,
    this.discountPercent = 0,
    this.listingDays,
    this.badge,
  });

  bool get isFree => price <= 0;

  bool get hasDiscount =>
      discountPercent > 0 || originalPrice > price;

  double get monthlyPrice => months <= 0 ? price : price / months;

  factory BillingCycle.fromJson(Map<String, dynamic> json) {
    final months = TypeUtils.safeInt(json['months']) ?? 1;
    return BillingCycle(
      months: months < 1 ? 1 : months,
      price: TypeUtils.safeDouble(json['price']) ?? 0,
      priceUsd: TypeUtils.safeDouble(json['price_usd']) ?? 0,
      originalPrice:
          TypeUtils.safeDouble(json['original_price']) ?? 0,
      originalPriceUsd:
          TypeUtils.safeDouble(json['original_price_usd']) ?? 0,
      discountPercent: TypeUtils.safeInt(json['discount_percent']) ?? 0,
      listingDays: TypeUtils.safeInt(json['listing_days']),
      badge: _text(json['badge']),
    );
  }
}

/// Per-plan quotas. Zero means the plan does not allow that resource.
class PlanLimits {
  final int listings;
  final int rentalListings;
  final int vehicles;
  final int rentalVehicles;
  final int jobs;
  final int featuredListings;
  final int orders;
  final int contacts;

  const PlanLimits({
    this.listings = 0,
    this.rentalListings = 0,
    this.vehicles = 0,
    this.rentalVehicles = 0,
    this.jobs = 0,
    this.featuredListings = 0,
    this.orders = 0,
    this.contacts = 0,
  });

  bool get canCreateListings => listings > 0;
  bool get canCreateJobs => jobs > 0;
  bool get canRevealContacts => contacts > 0;

  factory PlanLimits.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return PlanLimits(
      listings: TypeUtils.safeInt(map['listings']) ?? 0,
      rentalListings: TypeUtils.safeInt(map['rental_listings']) ?? 0,
      vehicles: TypeUtils.safeInt(map['vehicles']) ?? 0,
      rentalVehicles: TypeUtils.safeInt(map['rental_vehicles']) ?? 0,
      jobs: TypeUtils.safeInt(map['jobs']) ?? 0,
      featuredListings: TypeUtils.safeInt(map['featured_listings']) ?? 0,
      orders: TypeUtils.safeInt(map['orders']) ?? 0,
      contacts: TypeUtils.safeInt(map['contacts']) ?? 0,
    );
  }
}

/// Subscription plan as exposed by `/v2/plans`.
class Plan {
  final int id;
  final String slug;
  final String name;
  final String? description;
  final bool isFree;
  final String currency;
  final List<BillingCycle> cycles;
  final PlanLimits limits;
  final List<String> features;
  final int trialDays;
  final bool canStartTrial;
  final int sortOrder;

  const Plan({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.isFree = false,
    this.currency = 'ETB',
    this.cycles = const [],
    this.limits = const PlanLimits(),
    this.features = const [],
    this.trialDays = 0,
    this.canStartTrial = false,
    this.sortOrder = 0,
  });

  /// The cycle the plan screen should select initially: the shortest paid
  /// duration, or the first cycle for free plans.
  BillingCycle? get defaultCycle {
    if (cycles.isEmpty) return null;
    if (isFree) return cycles.first;
    return cycles.reduce((a, b) => a.months <= b.months ? a : b);
  }

  BillingCycle? cycleForMonths(int months) {
    for (final cycle in cycles) {
      if (cycle.months == months) return cycle;
    }
    return null;
  }

  factory Plan.fromJson(Map<String, dynamic> json) {
    final rawCycles = json['cycles'];
    final rawFeatures = json['features'];

    return Plan(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: _text(json['description']),
      isFree: TypeUtils.safeBool(json['is_free']),
      currency: json['currency']?.toString() ?? 'ETB',
      cycles: rawCycles is List
          ? rawCycles
              .whereType<Map>()
              .map((cycle) =>
                  BillingCycle.fromJson(Map<String, dynamic>.from(cycle)))
              .toList(growable: false)
          : const [],
      limits: PlanLimits.fromJson(json['limits']),
      features: rawFeatures is List
          ? rawFeatures.map((feature) => feature.toString()).toList(growable: false)
          : const [],
      trialDays: TypeUtils.safeInt(json['trial_days']) ?? 0,
      canStartTrial: TypeUtils.safeBool(json['can_start_trial']),
      sortOrder: TypeUtils.safeInt(json['sort_order']) ?? 0,
    );
  }
}

String? _text(dynamic value) {
  final text = value?.toString();
  return (text == null || text.isEmpty) ? null : text;
}
