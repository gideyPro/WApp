import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

Future<bool?> showCreateListingSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context);

  final route = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.theme.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.listingsCreate,
                  style: AppTextStyles.title.copyWith(
                    color: ctx.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: ctx.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context: ctx,
              icon: Icons.home_work_rounded,
              title: l10n.listingSummaryProperty,
              iconBgColor: AppColors.accent500.withValues(alpha: 0.12),
              iconColor: AppColors.accent600,
              onTap: () => Navigator.pop(ctx, '/listings/create'),
            ),
            const SizedBox(height: 10),
            _buildOptionTile(
              context: ctx,
              icon: Icons.directions_car_rounded,
              title: l10n.listingCar,
              iconBgColor: AppColors.primary500.withValues(alpha: 0.12),
              iconColor: AppColors.primary600,
              onTap: () => Navigator.pop(ctx, '/cars/create'),
            ),
            const SizedBox(height: 10),
            _buildOptionTile(
              context: ctx,
              icon: Icons.work_rounded,
              title: l10n.jobJob,
              iconBgColor: AppColors.cta500.withValues(alpha: 0.12),
              iconColor: AppColors.cta600,
              onTap: () => Navigator.pop(ctx, '/jobs/create'),
            ),
          ],
        ),
      ),
    ),
  );

  if (route == null || !context.mounted) return null;
  return context.push<bool>(route);
}

Widget _buildOptionTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Color iconBgColor,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return Material(
    color: context.theme.inputBg,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.theme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.theme.textTertiary,
            ),
          ],
        ),
      ),
    ),
  );
}

