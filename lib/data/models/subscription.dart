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

/// Subscription Plan Model
class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double priceUsd;
  final int durationMonths;
  final int maxListings;
  final int maxVehicles;
  final int maxJobs;
  final int maxFeaturedListings;
  final bool viewVip;
  final int maxOrders;
  final int maxContacts;
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
    this.maxListings = 1,
    this.maxVehicles = 0,
    this.maxJobs = 0,
    this.maxFeaturedListings = 0,
    this.viewVip = false,
    this.maxOrders = 0,
    this.maxContacts = 0,
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
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: _parseDouble(json['price']),
      priceUsd: _parseDouble(json['price_usd']),
      durationMonths: json['duration_months'] ?? 1,
      maxListings: json['max_listings'] ?? 1,
      maxVehicles: json['max_vehicles'] ?? 0,
      maxJobs: json['max_jobs'] ?? 0,
      maxFeaturedListings: json['max_featured_listings'] ?? 0,
      viewVip: json['view_vip'] ?? false,
      maxOrders: json['max_orders'] ?? 0,
      maxContacts: json['max_contacts'] ?? 0,
      detailsAccess: _parseDetailsAccess(json['details_access']),
      features: _parseFeatures(json['features']),
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'],
      priceInfo: _parsePriceInfo(json['price_info']),
      trialDays: json['trial_days'],
      canStartTrial: json['can_start_trial'] == true,
      billingCycleDays: json['billing_cycle_days'],
      planType: json['plan_type']?.toString() ?? 'marketplace',
      planFeatures: json['plan_features'] is Map ? Map<String, dynamic>.from(json['plan_features']) : null,
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

  /// Parse double from various types (String, num, double)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      case 'max_vehicles':
        return maxVehicles;
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

  /// Resolve max contact views for a specific model (e.g. 'car', 'job', 'listing').
  /// Checks dynamic planFeatures['max_contacts_<model>'] before falling back to plan's maxContacts.
  int maxContactsFor(String model) {
    final normalized = model.toLowerCase();
    final specificKey = (normalized == 'car' || normalized == 'vehicle')
        ? 'max_contacts_car'
        : ((normalized == 'job' || normalized == 'jobposting')
            ? 'max_contacts_job'
            : 'max_contacts');
    if (planFeatures != null && planFeatures!.containsKey(specificKey)) {
      final val = planFeatures![specificKey];
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val != null) {
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
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
  final int listingsUsed;
  final int vehiclesUsed;
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
    this.listingsUsed = 0,
    this.vehiclesUsed = 0,
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
      listingsUsed: json['listings_used'] ?? 0,
      vehiclesUsed: json['vehicles_used'] ?? 0,
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
