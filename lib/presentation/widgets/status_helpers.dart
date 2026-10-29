import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
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
  return type == 'house' ? l10n.ordersTypeHouse : l10n.ordersTypeLand;
}

Color typeColor(String type) {
  return type == 'house' ? AppColors.primary800 : AppColors.emerald500;
}

String formatPrice(double? value) {
  if (value == null) return '0';
  final formatter = NumberFormat('#,###', 'en_US');
  return formatter.format(value);
}

String formatRange(
    double? min, double? max, String unit, AppLocalizations l10n) {
  if (min != null && max != null) {
    return '${formatPrice(min)} - ${formatPrice(max)} $unit';
  }
  if (min != null) return '${formatPrice(min)}+ $unit';
  if (max != null) return l10n.orderUpTo(formatPrice(max), unit);
  return '';
}

/// Localizes the raw `facing_direction` wire value used by v2 payloads.
String facingDirectionLabel(String? direction, AppLocalizations l10n) {
  if (direction == null || direction.isEmpty) return '';

  switch (direction.toLowerCase()) {
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
      return direction;
  }
}
