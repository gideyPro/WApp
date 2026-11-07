import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/v2/buyer_order.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../widgets/status_helpers.dart';

class PublicOrderCard extends StatelessWidget {
  final BuyerOrder order;
  final VoidCallback onTap;

  const PublicOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  String _formatRecency(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.listingToday;
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return l10n.listingToday;
    if (days == 1) return l10n.listingYesterday;
    if (days < 7) return l10n.listingDaysAgo(days);
    if (days < 30) return l10n.listingWeeksAgo((days / 7).floor());
    return l10n.listingMonthsAgo((days / 30).floor());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.theme.isDark;
    final isCar = order.isCar;
    final isRental = order.isRental;

    final categoryLabel = orderTypeLabel(order.type, l10n);
    final intentLabel = isRental ? l10n.listingRent : l10n.listingSale;
    final recencyStr = _formatRecency(order.createdAt, l10n);
    final headline = orderHeadline(order, l10n);
    final areaLabel = orderAreaLabel(order.area, l10n);
    final vehicleYear = vehicleYearLabel(order, l10n);

    return Semantics(
      button: true,
      label: '$headline, $intentLabel',
      child: WaveCard(
        onTap: onTap,
        margin: EdgeInsets.zero,
        borderRadius: AppSpacing.borderRadiusLg,
        padding: const EdgeInsets.all(14),
        useLiquidGlass: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Pill + Intent Badge + Recency
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.35)
                          : const Color(0xFFBFDBFE),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCar ? Icons.directions_car_rounded : Icons.home_work_rounded,
                        size: 11.5,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$categoryLabel · $intentLabel'.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: context.theme.textMuted,
                ),
                const SizedBox(width: 3.5),
                Text(
                  recencyStr,
                  style: AppTextStyles.caption.copyWith(
                    color: context.theme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Line 2: Order Title
            Text(
              headline,
              style: AppTextStyles.titleSmall.copyWith(
                color: context.theme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Line 3: Budget Range
            Text(
              orderBudgetLabel(order.budget, l10n, compact: true),
              style: TextStyle(
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),

            // Line 4: Specification chips (Location, Area/Year)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (order.address?.displayAddressFor(
                      l10n.localeName,
                      broadOnly: true,
                    ).isNotEmpty ==
                    true)
                  _specChip(
                    context,
                    Icons.location_on_outlined,
                    order.address!.displayAddressFor(
                      l10n.localeName,
                      broadOnly: true,
                    ),
                    isDark,
                  ),
                if (!isCar && areaLabel.isNotEmpty)
                  _specChip(
                    context,
                    Icons.square_foot_rounded,
                    areaLabel,
                    isDark,
                  ),
                if (isCar) ...[
                  if (vehicleYear.isNotEmpty)
                    _specChip(
                      context,
                      Icons.calendar_today_rounded,
                      vehicleYear,
                      isDark,
                    ),
                ],
              ],
            ),

            // Bottom VIP Status indicator only
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: order.canViewVip
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_open_rounded,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.ordersContactBuyer,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.4)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFD97706).withValues(alpha: 0.4)
                              : const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 10,
                            color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            l10n.ordersVipRequiredBadge.toUpperCase(),
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(
      BuildContext context, IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: context.theme.textMuted),
          const SizedBox(width: 3.5),
          Text(
            text,
            style: TextStyle(
              color: context.theme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
