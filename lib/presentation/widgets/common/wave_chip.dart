import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';

enum ChipVariant {
  defaultChip,
  featured,
  popular,
  current,
  sale,
  rent,
  success,
  warning,
  error,
  outlined,
}

enum ChipSize {
  small,
  medium,
  large,
}

class WaveChip extends StatelessWidget {
  final String label;
  final ChipVariant variant;
  final ChipSize size;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final IconData? icon;
  final bool selected;

  const WaveChip({
    super.key,
    required this.label,
    this.variant = ChipVariant.defaultChip,
    this.size = ChipSize.medium,
    this.onTap,
    this.onDelete,
    this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildChip(context, isDark);
  }

  Widget _buildChip(BuildContext context, bool isDark) {
    final padding = _getPadding();
    final fontStyle = _getFontStyle();
    final bgColor = _getBackgroundColor(isDark);
    final textColor = _getTextColor(isDark);
    final borderColor = variant == ChipVariant.outlined
        ? (isDark ? AppColors.stone600 : AppColors.stone300)
        : Colors.transparent;

    Widget chip = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: selected ? bgColor.withValues(alpha: 0.2) : bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(
          color: selected ? textColor : borderColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: _getIconSize(), color: textColor),
            const SizedBox(width: 4),
          ],
          Text(label, style: fontStyle.copyWith(color: textColor)),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: _getIconSize(),
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: chip,
      );
    }

    return chip;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case ChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  TextStyle _getFontStyle() {
    switch (size) {
      case ChipSize.small:
        return AppTextStyles.caption;
      case ChipSize.medium:
        return AppTextStyles.bodySmall;
      case ChipSize.large:
        return AppTextStyles.bodyMedium;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ChipSize.small:
        return 12;
      case ChipSize.medium:
        return 14;
      case ChipSize.large:
        return 18;
    }
  }

  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case ChipVariant.featured:
        return AppColors.accent500;
      case ChipVariant.popular:
        return AppColors.primary600;
      case ChipVariant.current:
        return AppColors.emerald500;
      case ChipVariant.sale:
        return isDark ? AppColors.emerald800 : AppColors.emerald100;
      case ChipVariant.rent:
        return isDark ? AppColors.accent800 : AppColors.accent100;
      case ChipVariant.success:
        return AppColors.emerald500;
      case ChipVariant.warning:
        return AppColors.warning;
      case ChipVariant.error:
        return AppColors.error;
      case ChipVariant.outlined:
      case ChipVariant.defaultChip:
        return isDark ? AppColors.stone800 : AppColors.stone100;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (variant) {
      case ChipVariant.featured:
      case ChipVariant.popular:
      case ChipVariant.current:
      case ChipVariant.success:
      case ChipVariant.warning:
      case ChipVariant.error:
        return Colors.white;
      case ChipVariant.sale:
        return isDark ? AppColors.emerald300 : AppColors.emerald700;
      case ChipVariant.rent:
        return isDark ? AppColors.accent300 : AppColors.accent700;
      case ChipVariant.outlined:
        return isDark ? AppColors.stone300 : AppColors.stone700;
      case ChipVariant.defaultChip:
        return isDark ? AppColors.stone300 : AppColors.stone700;
    }
  }
}