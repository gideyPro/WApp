import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/v2/buyer_order.dart';
import '../../data/models/v2/listing_summary.dart';
import '../../l10n/app_localizations.dart';

String statusLabel(String status, AppLocalizations l10n) {
  switch (status) {
    case 'active':
      return l10n.ordersStatusActive;
    case 'fulfilled':
      return l10n.ordersStatusFulfilled;
    case 'cancelled':
      return l10n.ordersStatusCancelled;
    default:
      return status;
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'active':
      return AppColors.accent500;
    case 'fulfilled':
      return AppColors.success;
    case 'cancelled':
      return AppColors.stone400;
    default:
      return AppColors.primary400;
  }
}

String typeLabel(String type, AppLocalizations l10n) {
  switch (type) {
    case 'house':
      return l10n.ordersTypeHouse;
    case 'land':
      return l10n.ordersTypeLand;
    case 'car':
      return l10n.listingCar;
    default:
      return type;
  }
}

String orderTypeLabel(ListingKind type, AppLocalizations l10n) {
  switch (type) {
    case ListingKind.house:
      return l10n.listingHouse;
    case ListingKind.land:
      return l10n.listingLand;
    case ListingKind.car:
      return l10n.listingCar;
    default:
      return l10n.ordersTitle;
  }
}

Color typeColor(String type) {
  switch (type) {
    case 'house':
      return AppColors.primary800;
    case 'land':
      return AppColors.emerald500;
    case 'car':
      return AppColors.primary600;
    default:
      return AppColors.primary400;
  }
}

/// Title composed on the client because public browse payloads no longer
/// include a server-side title.
String orderHeadline(BuyerOrder order, AppLocalizations l10n) {
  final intent = order.isRental ? l10n.listingRent : l10n.listingSale;

  if (order.isCar) {
    final name = order.vehicleName;
    return name == null
        ? '${l10n.listingCar} · $intent'
        : '$name · $intent';
  }

  return '${orderTypeLabel(order.type, l10n)} · $intent';
}

String formatPrice(double? value) {
  if (value == null) return '0';
  final formatter = NumberFormat('#,###', 'en_US');
  return formatter.format(value);
}

String formatRange(double? min, double? max, String unit, AppLocalizations l10n) {
  if (min != null && max != null) {
    return '${formatPrice(min)} - ${formatPrice(max)} $unit';
  }
  if (min != null) return '${formatPrice(min)}+ $unit';
  if (max != null) return l10n.orderUpTo(formatPrice(max), unit);
  return '';
}

String orderBudgetLabel(
  OrderRange budget,
  AppLocalizations l10n, {
  bool compact = false,
}) {
  if (budget.isEmpty) return l10n.ordersBudgetOnAgreement;

  String amount(double value) =>
      compact ? _compactAmount(value) : formatPrice(value);

  if (budget.min != null && budget.max != null) {
    return 'ETB ${amount(budget.min!)} - ${amount(budget.max!)}';
  }
  if (budget.min != null) {
    return 'ETB ${amount(budget.min!)}+';
  }
  return l10n.ordersUpToBudget('ETB ${amount(budget.max!)}');
}

String orderAreaLabel(OrderRange area, AppLocalizations l10n) {
  if (area.isEmpty) return '';
  if (area.min != null && area.max != null) {
    return '${formatPrice(area.min)} - ${formatPrice(area.max)} m²';
  }
  if (area.min != null) return '${formatPrice(area.min)}+ m²';
  return '≤ ${formatPrice(area.max)} m²';
}

String vehicleYearLabel(BuyerOrder order, AppLocalizations l10n) {
  final min = order.vehicleYearMin;
  final max = order.vehicleYearMax;
  if (min == null && max == null) return '';
  if (min != null && max != null) {
    return min == max ? '$min' : '$min - $max';
  }
  if (min != null) return '$min+';
  return '≤ $max';
}

String holdingTypeLabel(String value, AppLocalizations l10n) {
  switch (value) {
    case 'Free Hold':
      return l10n.listingFreeHold;
    case 'Lease Hold':
      return l10n.listingLeaseHold;
    case 'Cooperative':
      return l10n.listingCooperative;
    default:
      return value;
  }
}

String facingDirectionLabel(String value, AppLocalizations l10n) {
  switch (value) {
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
      return value;
  }
}

String transmissionLabel(String value, AppLocalizations l10n) {
  switch (value.trim().toLowerCase()) {
    case 'automatic':
    case 'auto':
      return l10n.ordersTransmissionAutomatic;
    case 'manual':
      return l10n.ordersTransmissionManual;
    default:
      return value;
  }
}

String fuelTypeLabel(String value, AppLocalizations l10n) {
  switch (value.trim().toLowerCase()) {
    case 'petrol':
    case 'benzine':
    case 'gasoline':
      return l10n.ordersFuelPetrol;
    case 'diesel':
      return l10n.ordersFuelDiesel;
    case 'hybrid':
      return l10n.bodyTypeHybrid;
    case 'electric':
      return l10n.bodyTypeElectric;
    default:
      return value;
  }
}

String _compactAmount(double n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    return v.truncateToDouble() == v
        ? '${v.toInt()}M'
        : '${v.toStringAsFixed(1)}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return v.truncateToDouble() == v
        ? '${v.toInt()}K'
        : '${v.toStringAsFixed(1)}K';
  }
  return n.toInt().toString();
}
