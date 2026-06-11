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

String formatRange(double? min, double? max, String unit, AppLocalizations l10n) {
  if (min != null && max != null) {
    return '${formatPrice(min)} - ${formatPrice(max)} $unit';
  }
  if (min != null) return '${formatPrice(min)}+ $unit';
  if (max != null) return l10n.orderUpTo(formatPrice(max), unit);
  return '';
}
