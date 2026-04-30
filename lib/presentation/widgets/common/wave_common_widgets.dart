import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import 'wave_button.dart';

/// WaveMart Bottom Navigation Bar
class WaveBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WaveBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.bottomNav,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy950.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Search',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.add_circle_outline,
                activeIcon: Icons.add_circle,
                label: 'List',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Saved',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.wave50.withOpacity(0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? AppColors.wave600 : AppColors.navy400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: isSelected
                ? AppTextStyles.navActive
                : AppTextStyles.navInactive,
          ),
        ],
      ),
    );
  }
}

/// WaveMart Loading Indicator
class WaveLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const WaveLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.wave500,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// WaveMart Empty State
class WaveEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const WaveEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.navy50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.navy400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: WaveButton(
                  text: actionLabel!,
                  onPressed: onAction,
                  isFullWidth: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error Banner Widget - Shows error message with retry button
class WaveErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? actionLabel;

  const WaveErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: AppTextStyles.title.copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.zinc600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          WaveButton(
            text: actionLabel ?? 'Retry',
            icon: Icons.refresh,
            onPressed: onRetry,
            variant: ButtonVariant.danger,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// WaveMart Toast/Snackbar
class WaveToast {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.emerald600,
      Icons.check_circle,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.error,
      Icons.error_outline,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.navy900,
      Icons.info_outline,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color bgColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// WaveMart Divider with Text
class WaveDivider extends StatelessWidget {
  final String? text;
  final Color? color;
  final double thickness;

  const WaveDivider({
    super.key,
    this.text,
    this.color,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Divider(
        color: color ?? AppColors.zinc200,
        thickness: thickness,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color ?? AppColors.zinc200,
            thickness: thickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text!,
            style: AppTextStyles.caption,
          ),
        ),
        Expanded(
          child: Divider(
            color: color ?? AppColors.zinc200,
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}

/// WaveMart Section Header - Modern design with subtle gradient accent
class WaveSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const WaveSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.wave500, AppColors.wave600],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.navy400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.wave50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.wave200),
              ),
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.wave700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
