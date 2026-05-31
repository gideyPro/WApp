import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../screens/subscriptions/subscription_plans_screen.dart';

class UpgradeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onButtonTap;

  const UpgradeCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.buttonLabel = '',
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = buttonLabel.isNotEmpty
        ? buttonLabel
        : AppLocalizations.of(context).listingViewPlans;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.primary800, AppColors.primary900]
              : [iconColor.withValues(alpha: 0.08), AppColors.primary50],
        ),
        border: Border.all(
          color: isDark
              ? iconColor.withValues(alpha: 0.2)
              : iconColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: context.theme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: onButtonTap ?? _defaultAction,
                icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _defaultAction() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SubscriptionPlansScreen(),
        ),
      );
    }
  }
}

/// Full-page upgrade/verify view matching ListingDetailScreen's `_buildErrorView`.
/// Used by create_listing_screen and create_order_screen to replace the entire body.
class WaveFullPageUpgrade extends StatelessWidget {
  final Widget? appBar;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onButtonTap;

  const WaveFullPageUpgrade({
    super.key,
    this.appBar,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.buttonLabel = '',
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = buttonLabel.isNotEmpty ? buttonLabel : l10n.listingViewPlans;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: appBar as PreferredSizeWidget?,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.theme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonTap ?? _defaultAction,
                icon: const Icon(Icons.star, size: 18),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _defaultAction() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SubscriptionPlansScreen(),
        ),
      );
    }
  }
}
