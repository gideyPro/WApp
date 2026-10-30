import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/ethiopian_date_helper.dart';
import 'app_date_picker.dart';

/// A Material 3 Date Form Field supporting both Ethiopian and Gregorian calendars.
///
/// Features:
/// - Displays dual date format: e.g. "ጥቅምት 19, 2017 ዓ/ም (2024-10-29)".
/// - Tapping opens [AppDatePicker.show] with the dual-calendar switcher.
/// - Clear button to reset date.
/// - WCAG 2.1 AA accessible with 48dp minimum hit area.
class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final CalendarType initialCalendarType;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final bool enabled;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.initialCalendarType = CalendarType.ethiopian,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.enabled = true,
  });

  Future<void> _handleTap(BuildContext context) async {
    if (!enabled) return;
    final locale = Localizations.localeOf(context).languageCode;
    final picked = await AppDatePicker.show(
      context: context,
      initialDate: value,
      firstDate: firstDate,
      lastDate: lastDate,
      initialCalendarType: initialCalendarType,
      locale: locale,
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    String? displayValue;
    if (value != null) {
      final eth = EthiopianDate.fromGregorian(value!);
      final ethStr = eth.format(locale);
      final gregStr =
          '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';
      displayValue = '$ethStr ($gregStr)';
    }

    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError
        ? AppColors.error
        : (isDark ? Colors.white12 : AppColors.stone300);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: theme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Date Field Box
        Semantics(
          button: true,
          label: '$label: ${displayValue ?? hintText ?? 'Select date'}',
          child: Material(
            color: isDark ? AppColors.cardNavyDark : AppColors.stone100,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _handleTap(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: hasError ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: isDark ? AppColors.accent400 : AppColors.primary900,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayValue ?? hintText ?? 'Select date',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: displayValue != null
                              ? theme.textPrimary
                              : (isDark ? Colors.white38 : AppColors.stone400),
                          fontWeight: displayValue != null ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (value != null && enabled) ...[
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: theme.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Clear date',
                        onPressed: () => onChanged(null),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error, fontSize: 11),
          ),
        ],
      ],
    );
  }
}
