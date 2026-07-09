import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'wave_button.dart';

/// Wavemart AppBar — tight leading defaults to fix font-metric spacing with Cinzel
class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const WaveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.leadingWidth = 32,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final effectiveLeading = leading ??
        (automaticallyImplyLeading && Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
              )
            : null);

    return AppBar(
      backgroundColor: backgroundColor ?? context.cardBg,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      centerTitle: centerTitle,
      leadingWidth: effectiveLeading != null ? (leadingWidth ?? 32) : null,
      leading: effectiveLeading,
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }
}


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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color: isDark ? AppColors.primary700 : AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: isDark ? AppColors.primary300 : AppColors.primary400,
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
  const _MessageStyle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

final _typeStyles = {
  WaveMessageType.error: const _MessageStyle(
    icon: Icons.error_outline_rounded,
    iconBg: AppColors.errorLight,
    iconColor: AppColors.error,
  ),
  WaveMessageType.warning: const _MessageStyle(
    icon: Icons.warning_amber_rounded,
    iconBg: AppColors.warningLight,
    iconColor: AppColors.warning,
  ),
  WaveMessageType.success: const _MessageStyle(
    icon: Icons.check_circle_outline_rounded,
    iconBg: AppColors.successLight,
    iconColor: AppColors.success,
  ),
  WaveMessageType.info: const _MessageStyle(
    icon: Icons.info_outline_rounded,
    iconBg: AppColors.infoLight,
    iconColor: AppColors.info,
  ),
  WaveMessageType.networkError: const _MessageStyle(
    icon: Icons.wifi_off_rounded,
    iconBg: AppColors.stone200,
    iconColor: AppColors.stone600,
  ),
  WaveMessageType.empty: const _MessageStyle(
    icon: Icons.inbox_outlined,
    iconBg: AppColors.stone100,
    iconColor: AppColors.stone400,
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
    final l10n = AppLocalizations.of(context);

    final style = type == WaveMessageType.custom
        ? _MessageStyle(
            icon: customIcon ?? Icons.help_outline,
            iconBg: (customIconColor ?? AppColors.primary500).withValues(alpha: 0.12),
            iconColor: customIconColor ?? AppColors.primary500,
          )
        : _typeStyles[type]!;

    String? defaultTitle;
    String? defaultSubtitle;

    switch (type) {
      case WaveMessageType.error:
        defaultTitle = l10n.messageErrorTitle;
        defaultSubtitle = l10n.messageErrorSubtitle;
        break;
      case WaveMessageType.warning:
        defaultTitle = l10n.messageWarningTitle;
        defaultSubtitle = l10n.messageWarningSubtitle;
        break;
      case WaveMessageType.success:
        defaultTitle = l10n.messageSuccessTitle;
        defaultSubtitle = l10n.messageSuccessSubtitle;
        break;
      case WaveMessageType.info:
        defaultTitle = l10n.messageInfoTitle;
        defaultSubtitle = l10n.messageInfoSubtitle;
        break;
      case WaveMessageType.networkError:
        defaultTitle = l10n.messageNetworkTitle;
        defaultSubtitle = l10n.messageNetworkSubtitle;
        break;
      case WaveMessageType.empty:
        defaultTitle = l10n.messageEmptyTitle;
        defaultSubtitle = l10n.messageEmptySubtitle;
        break;
      default:
        break;
    }

    final effectiveTitle = title ?? defaultTitle ?? '';
    final effectiveSubtitle = subtitle ?? defaultSubtitle ?? '';

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
      backgroundColor: isDark ? AppColors.primary900 : AppColors.stone50,
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
    final cardBg = isDark ? AppColors.primary800 : Colors.white;
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
        borderRadius: BorderRadius.circular(isEmbedded ? 4 : 4),
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
    final l10n = AppLocalizations.of(context);
    final hasRetry = onRetry != null;
    final hasAction = onAction != null;

    if (!hasRetry && !hasAction) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Text(
          l10n.messageDismiss,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.accent600,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.accent600.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final callback = hasRetry ? onRetry! : onAction!;
    final label = actionLabel ?? (hasRetry ? l10n.messageRetry : l10n.commonContinue);

    return WaveButton(
      text: label,
      onPressed: callback,
      icon: hasRetry ? Icons.refresh_rounded : null,
      variant: ButtonVariant.primary,
      isFullWidth: true,
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
          borderRadius: BorderRadius.circular(4),
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
