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

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.warning,
      Icons.warning_amber_rounded,
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

/// Message type for WaveMessageScreen
enum WaveMessageType {
  error,
  warning,
  success,
  info,
  networkError,
  empty,
  custom,
}

/// WaveMart Full-Screen Message - Reusable for all message types
class WaveMessageScreen extends StatelessWidget {
  final WaveMessageType type;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;
  final IconData? customIcon;
  final Color? customIconColor;
  final bool showBackButton;
  final VoidCallback? onBack;

  const WaveMessageScreen({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onRetry,
    this.customIcon,
    this.customIconColor,
    this.showBackButton = false,
    this.onBack,
  });

  factory WaveMessageScreen.error({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onRetry,
  }) {
    return WaveMessageScreen(
      type: WaveMessageType.error,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel ?? 'Retry',
      onAction: onRetry ?? onAction,
    );
  }

  factory WaveMessageScreen.networkError({
    VoidCallback? onRetry,
  }) {
    return WaveMessageScreen(
      type: WaveMessageType.networkError,
      title: 'No Internet Connection',
      subtitle: 'Please check your internet connection and try again.',
      actionLabel: 'Try Again',
      onRetry: onRetry,
    );
  }

  factory WaveMessageScreen.warning({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return WaveMessageScreen(
      type: WaveMessageType.warning,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory WaveMessageScreen.success({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return WaveMessageScreen(
      type: WaveMessageType.success,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory WaveMessageScreen.info({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return WaveMessageScreen(
      type: WaveMessageType.info,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory WaveMessageScreen.empty({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return WaveMessageScreen(
      type: WaveMessageType.empty,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, iconColor, bgColor, gradient) = _getTypeConfig();

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.zinc50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.navy800 : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                ),
              const Spacer(flex: 2),
              _buildIcon(icon, iconColor, bgColor, gradient, isDark),
              const SizedBox(height: 32),
              Text(
                title,
                style: AppTextStyles.headline4.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(flex: 2),
              if (onAction != null || onRetry != null)
                SizedBox(
                  width: double.infinity,
                  child: WaveButton(
                    text: actionLabel ?? (onRetry != null ? 'Try Again' : 'Continue'),
                    onPressed: onAction ?? onRetry,
                    isFullWidth: true,
                    height: 52,
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color iconColor, Color bgColor, LinearGradient? gradient, bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? bgColor : null,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        customIcon ?? icon,
        size: 56,
        color: iconColor,
      ),
    );
  }

  (IconData, Color, Color, LinearGradient?) _getTypeConfig() {
    switch (type) {
      case WaveMessageType.error:
        return (
          Icons.error_outline_rounded,
          Colors.white,
          AppColors.error,
          AppColors.gradientEmerald,
        );
      case WaveMessageType.warning:
        return (
          Icons.warning_amber_rounded,
          AppColors.warning,
          AppColors.warning.withOpacity(0.15),
          null,
        );
      case WaveMessageType.success:
        return (
          Icons.check_circle_outline_rounded,
          Colors.white,
          AppColors.emerald600,
          AppColors.gradientEmerald,
        );
      case WaveMessageType.info:
        return (
          Icons.info_outline_rounded,
          AppColors.wave600,
          AppColors.wave500.withOpacity(0.15),
          null,
        );
      case WaveMessageType.networkError:
        return (
          Icons.wifi_off_rounded,
          AppColors.zinc600,
          AppColors.zinc200,
          null,
        );
      case WaveMessageType.empty:
        return (
          Icons.inbox_outlined,
          AppColors.zinc400,
          AppColors.zinc200,
          null,
        );
      case WaveMessageType.custom:
        return (
          customIcon ?? Icons.help_outline,
          customIconColor ?? AppColors.navy600,
          AppColors.navy50,
          null,
        );
    }
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
