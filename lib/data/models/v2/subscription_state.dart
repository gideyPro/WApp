import '../../../core/utils/type_utils.dart';
import '../../../l10n/app_localizations.dart';

/// Minimal plan reference embedded in subscriptions and payments.
///
/// The full [Plan] lives on the plans endpoint; overview and payment payloads
/// only need enough to label the current/purchased plan.
class SubscriptionPlanRef {
  final int id;
  final String slug;
  final String name;

  const SubscriptionPlanRef({
    required this.id,
    required this.slug,
    required this.name,
  });

  int get maxListings => -1;
  int get maxRentalListings => -1;
  int get maxVehicles => -1;
  int get maxRentalVehicles => -1;
  int get maxJobs => -1;
  bool get viewVip => true;
  List<String>? get features => null;

  factory SubscriptionPlanRef.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return SubscriptionPlanRef(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      slug: map['slug']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}

/// Per-resource counters for the current subscription period.
class SubscriptionUsage {
  final int listings;
  final int rentalListings;
  final int vehicles;
  final int rentalVehicles;
  final int jobs;
  final int featuredListings;
  final int orders;

  const SubscriptionUsage({
    this.listings = 0,
    this.rentalListings = 0,
    this.vehicles = 0,
    this.rentalVehicles = 0,
    this.jobs = 0,
    this.featuredListings = 0,
    this.orders = 0,
  });

  factory SubscriptionUsage.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return SubscriptionUsage(
      listings: TypeUtils.safeInt(map['listings']) ?? 0,
      rentalListings: TypeUtils.safeInt(map['rental_listings']) ?? 0,
      vehicles: TypeUtils.safeInt(map['vehicles']) ?? 0,
      rentalVehicles: TypeUtils.safeInt(map['rental_vehicles']) ?? 0,
      jobs: TypeUtils.safeInt(map['jobs']) ?? 0,
      featuredListings: TypeUtils.safeInt(map['featured_listings']) ?? 0,
      orders: TypeUtils.safeInt(map['orders']) ?? 0,
    );
  }
}

/// The signed-in user's active subscription.
class SubscriptionState {
  final int id;
  final String status;
  final SubscriptionPlanRef? plan;
  final int billingCycleMonths;
  final int listingDurationDays;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? trialEndsAt;
  final DateTime? cancelledAt;
  final bool isActive;
  final bool isTrial;
  final int daysRemaining;
  final SubscriptionUsage usage;

  int? get planId => plan?.id;
  int? get daysUntilExpiry => daysRemaining;

  int get listingsUsed => usage.listings;
  int get rentalListingsUsed => usage.rentalListings;
  int get vehiclesUsed => usage.vehicles;
  int get rentalVehiclesUsed => usage.rentalVehicles;
  int get jobsUsed => usage.jobs;
  bool get isCancelled => cancelledAt != null;

  String getStatusLabel(AppLocalizations l10n) {
    if (isActive) return l10n.statusActive;
    if (isCancelled) return l10n.statusCancelled;
    if (status == 'expired') return l10n.statusExpired;
    return status;
  }

  const SubscriptionState({
    required this.id,
    this.status = '',
    this.plan,
    this.billingCycleMonths = 1,
    this.listingDurationDays = 30,
    this.startsAt,
    this.endsAt,
    this.trialEndsAt,
    this.cancelledAt,
    this.isActive = false,
    this.isTrial = false,
    this.daysRemaining = 0,
    this.usage = const SubscriptionUsage(),
  });

  bool get isOnTrial => isTrial;

  bool get expiresSoon => isActive && daysRemaining <= 7;

  factory SubscriptionState.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return SubscriptionState(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      status: map['status']?.toString() ?? '',
      plan:
          map['plan'] is Map ? SubscriptionPlanRef.fromJson(map['plan']) : null,
      billingCycleMonths: TypeUtils.safeInt(map['billing_cycle_months']) ?? 1,
      listingDurationDays:
          TypeUtils.safeInt(map['listing_duration_days']) ?? 30,
      startsAt: _date(map['starts_at']),
      endsAt: _date(map['ends_at']),
      trialEndsAt: _date(map['trial_ends_at']),
      cancelledAt: _date(map['cancelled_at']),
      isActive: TypeUtils.safeBool(map['is_active']),
      isTrial: TypeUtils.safeBool(map['is_trial']),
      daysRemaining: TypeUtils.safeInt(map['days_remaining']) ?? 0,
      usage: SubscriptionUsage.fromJson(map['usage']),
    );
  }
}

/// A resolved feature capability.
///
/// The API uses three shapes under one key space: quota counters
/// (`allowed/used/max`), boolean gates (`allowed`) and detail tiers
/// (`value`). They are folded into one class so callers can read any key
/// without casting maps.
class Capability {
  final bool allowed;
  final int? used;
  final int? max;
  final String? value;

  const Capability({
    this.allowed = false,
    this.used,
    this.max,
    this.value,
  });

  bool get isQuota => max != null;

  int get remaining {
    if (max == null) return 0;
    final left = max! - (used ?? 0);
    return left < 0 ? 0 : left;
  }

  bool get hasCapacity => allowed && (max == null || remaining > 0);

  factory Capability.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return Capability(
      allowed: TypeUtils.safeBool(map['allowed']),
      used: TypeUtils.safeInt(map['used']),
      max: TypeUtils.safeInt(map['max']),
      value: _text(map['value']),
    );
  }
}

/// Feature-key to capability map returned by `GET /subscription`.
class PlanCapabilities {
  final Map<String, Capability> entries;

  const PlanCapabilities({this.entries = const {}});

  Capability? operator [](String key) => entries[key];

  Capability? get maxListings => entries['max_listings'];
  Capability? get maxVehicles => entries['max_vehicles'];
  Capability? get maxJobs => entries['max_jobs'];
  Capability? get maxFeaturedListings => entries['max_featured_listings'];
  Capability? get maxOrders => entries['max_orders'];
  Capability? get maxContacts => entries['max_contacts'];

  bool get canViewVip => entries['view_vip']?.allowed ?? false;
  bool get canViewVideo => entries['access_video']?.allowed ?? false;
  bool get canAccessContact => entries['access_contact']?.allowed ?? false;

  String get detailsAccess => entries['details_access']?.value ?? 'discovery';
  String get detailsAccessCar =>
      entries['details_access_car']?.value ?? 'discovery';
  String get detailsAccessJob =>
      entries['details_access_job']?.value ?? 'discovery';

  /// Quota max for a feature, or null when the API does not report one.
  int? quota(String key) => entries[key]?.max;

  factory PlanCapabilities.fromJson(dynamic json) {
    if (json is! Map) return const PlanCapabilities();

    final entries = <String, Capability>{};
    json.forEach((key, value) {
      if (value is Map) {
        entries[key.toString()] = Capability.fromJson(value);
      }
    });

    return PlanCapabilities(entries: Map.unmodifiable(entries));
  }
}

/// `GET /subscription` payload.
class SubscriptionOverview {
  final bool enabled;
  final SubscriptionState? subscription;
  final PlanCapabilities capabilities;

  const SubscriptionOverview({
    this.enabled = true,
    this.subscription,
    this.capabilities = const PlanCapabilities(),
  });

  bool get hasActiveSubscription => subscription?.isActive ?? false;

  factory SubscriptionOverview.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return SubscriptionOverview(
      enabled: TypeUtils.safeBool(map['enabled'], defaultValue: true),
      subscription: map['subscription'] is Map
          ? SubscriptionState.fromJson(map['subscription'])
          : null,
      capabilities: PlanCapabilities.fromJson(map['capabilities']),
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
