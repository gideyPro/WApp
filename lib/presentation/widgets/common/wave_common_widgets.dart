import 'dart:async';
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

/// WaveMart Toast/Snackbar
class WaveToast {
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.emerald600,
      Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.error,
      Icons.error_outline_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.navy900,
      Icons.info_outline_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.warning,
      Icons.warning_amber_rounded,
    );
  }

  static void _showToast(
    BuildContext context,
    String message,
    Color bgColor,
    IconData icon,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        bgColor: bgColor,
        icon: icon,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color bgColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.bgColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 32,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.bgColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum WaveMessageType {
  error,
  warning,
  success,
  info,
  networkError,
  empty,
  custom,
}

class _MessageStyle {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? defaultTitle;
  final String? defaultSubtitle;
  const _MessageStyle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.defaultTitle,
    this.defaultSubtitle,
  });
}

final _typeStyles = {
  WaveMessageType.error: const _MessageStyle(
    icon: Icons.error_outline_rounded,
    iconBg: Color(0xFFfee2e2),
    iconColor: Color(0xFFef4444),
    defaultTitle: 'Something Went Wrong',
    defaultSubtitle: "We couldn't complete your request.",
  ),
  WaveMessageType.warning: const _MessageStyle(
    icon: Icons.warning_amber_rounded,
    iconBg: Color(0xFFfef3c7),
    iconColor: Color(0xFFf59e0b),
    defaultTitle: 'Warning',
    defaultSubtitle: 'Please review this important message.',
  ),
  WaveMessageType.success: const _MessageStyle(
    icon: Icons.check_circle_outline_rounded,
    iconBg: Color(0xFFd1fae5),
    iconColor: Color(0xFF10b981),
    defaultTitle: 'Success!',
    defaultSubtitle: 'Your action was completed successfully.',
  ),
  WaveMessageType.info: const _MessageStyle(
    icon: Icons.info_outline_rounded,
    iconBg: Color(0xFFdbeafe),
    iconColor: Color(0xFF3b82f6),
    defaultTitle: 'Info',
    defaultSubtitle: 'Here is some important information.',
  ),
  WaveMessageType.networkError: const _MessageStyle(
    icon: Icons.wifi_off_rounded,
    iconBg: Color(0xFFe7e5e4),
    iconColor: Color(0xFF78716c),
    defaultTitle: 'No Internet Connection',
    defaultSubtitle: 'Check your connection and try again.',
  ),
  WaveMessageType.empty: const _MessageStyle(
    icon: Icons.inbox_outlined,
    iconBg: Color(0xFFf5f5f4),
    iconColor: Color(0xFFa8a29e),
    defaultTitle: 'Nothing Here',
    defaultSubtitle: "There's nothing to show right now.",
  ),
};

class WaveMessageScreen extends StatelessWidget {
  final WaveMessageType type;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;
  final IconData? customIcon;
  final Color? customIconColor;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool isEmbedded;

  const WaveMessageScreen({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.onRetry,
    this.customIcon,
    this.customIconColor,
    this.showBackButton = false,
    this.onBack,
    this.isEmbedded = false,
  });

  factory WaveMessageScreen.error({
    String? title,
    String? subtitle,
    VoidCallback? onAction,
    VoidCallback? onRetry,
    bool isEmbedded = false,
  }) =>
      WaveMessageScreen(
        type: WaveMessageType.error,
        title: title,
        subtitle: subtitle,
        onAction: onRetry ?? onAction,
        onRetry: onRetry,
        isEmbedded: isEmbedded,
      );

  factory WaveMessageScreen.networkError({
    VoidCallback? onRetry,
    bool isEmbedded = false,
  }) =>
      WaveMessageScreen(
        type: WaveMessageType.networkError,
        onRetry: onRetry,
        isEmbedded: isEmbedded,
      );

  factory WaveMessageScreen.warning({
    String? title,
    String? subtitle,
    VoidCallback? onAction,
    bool isEmbedded = false,
  }) =>
      WaveMessageScreen(
        type: WaveMessageType.warning,
        title: title,
        subtitle: subtitle,
        onAction: onAction,
        isEmbedded: isEmbedded,
      );

  factory WaveMessageScreen.success({
    String? title,
    String? subtitle,
    VoidCallback? onAction,
    bool isEmbedded = false,
  }) =>
      WaveMessageScreen(
        type: WaveMessageType.success,
        title: title,
        subtitle: subtitle,
        onAction: onAction,
        isEmbedded: isEmbedded,
      );

  factory WaveMessageScreen.info({
    String? title,
    String? subtitle,
    VoidCallback? onAction,
    bool isEmbedded = false,
  }) =>
      WaveMessageScreen(
        type: WaveMessageType.info,
        title: title,
        subtitle: subtitle,
        onAction: onAction,
        isEmbedded: isEmbedded,
      );

  factory WaveMessageScreen.empty({
    String? title,
    String? subtitle,
    VoidCallback? onAction,
    bool isEmbedded = false,
  }) =>
      WaveMessageScreen(
        type: WaveMessageType.empty,
        title: title,
        subtitle: subtitle,
        onAction: onAction,
        isEmbedded: isEmbedded,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = type == WaveMessageType.custom
        ? _MessageStyle(
            icon: customIcon ?? Icons.help_outline,
            iconBg: (customIconColor ?? AppColors.navy500).withValues(alpha: 0.12),
            iconColor: customIconColor ?? AppColors.navy500,
          )
        : _typeStyles[type]!;

    final effectiveTitle = title ?? style.defaultTitle ?? '';
    final effectiveSubtitle = subtitle ?? style.defaultSubtitle ?? '';

    final card = _buildCard(style, effectiveTitle, effectiveSubtitle, context, isDark);

    if (isEmbedded) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Material(
            color: Colors.transparent,
            child: card,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.zinc50,
      body: Stack(
        children: [
          if (showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: _buildBackButton(context, isDark),
            ),
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    _MessageStyle style,
    String effectiveTitle,
    String effectiveSubtitle,
    BuildContext context,
    bool isDark,
  ) {
    final cardBg = isDark ? AppColors.navy900 : Colors.white;
    final shadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ]
        : AppColors.shadowLg;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: isEmbedded ? 400 : 340),
      padding: EdgeInsets.all(isEmbedded ? 24 : 32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(isEmbedded ? 20 : 24),
        boxShadow: shadow,
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isEmbedded ? 56 : 64,
            height: isEmbedded ? 56 : 64,
            decoration: BoxDecoration(
              color: style.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              style.icon,
              size: isEmbedded ? 28 : 32,
              color: style.iconColor,
            ),
          ),
          SizedBox(height: isEmbedded ? 20 : 24),
          Text(
            effectiveTitle,
            style: (isEmbedded ? AppTextStyles.title : AppTextStyles.headline4).copyWith(
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (effectiveSubtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              effectiveSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: isEmbedded ? 24 : 28),
          _buildAction(context),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    final hasRetry = onRetry != null;
    final hasAction = onAction != null;

    if (!hasRetry && !hasAction) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Text(
          'Dismiss',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.wave600,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.wave600.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final callback = hasRetry ? onRetry! : onAction!;
    final label = actionLabel ?? (hasRetry ? 'Try Again' : 'Continue');

    return GestureDetector(
      onTap: callback,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh_rounded,
            size: 18,
            color: AppColors.wave600,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.wave600,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.wave600.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: context.textPrimary,
        ),
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
