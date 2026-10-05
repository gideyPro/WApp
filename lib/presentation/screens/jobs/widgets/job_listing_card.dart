import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/job_data.dart';
import '../../../../data/models/listing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/common/wave_card.dart';

class JobListingCard extends ConsumerWidget {
  final Listing job;
  final VoidCallback? onTap;
  final List<Widget>? footerActions;
  final bool showOwnerBadges;

  const JobListingCard({
    super.key,
    required this.job,
    this.onTap,
    this.footerActions,
    this.showOwnerBadges = false,
  });

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(color: Colors.white),
      ),
    );
  }

  String _jobTitle(AppLocalizations l10n) {
    final firstLine = job.description?.split('\n').first.trim();
    if (firstLine != null && firstLine.isNotEmpty) return firstLine;
    final company = job.jobCompanyName?.trim();
    if (company != null && company.isNotEmpty) return company;
    return l10n.jobJob;
  }

  bool get _isCompanyPosting {
    final company = job.jobCompanyName?.trim();
    return company != null && company.isNotEmpty;
  }

  List<Widget> _ownerBadges(AppLocalizations l10n) {
    if (!showOwnerBadges) return const [];
    return [
      if (job.status == ListingStatus.frozen)
        _buildBadge(l10n.statusFrozen, AppColors.error),
      if (job.isNew) _buildBadge(l10n.listingNew, AppColors.primary600),
      if (job.isFeatured)
        _buildBadge(l10n.listingFeatured, AppColors.accent600),
      if (job.isVip) _buildBadge(l10n.vipBadge, AppColors.vip),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    final subState = ref.watch(subscriptionProvider);
    final isRestricted = !subState.canSeeFullAddress;

    final category = job.jobCategory;
    final categoryLabel =
        (category == null || category.isEmpty) ? null : jobCategoryLabel(category, l10n);
    final positions = job.jobPositionsCount;
    final location = job.address?.getLocalizedAddress(context, cache, isRestricted) ??
        job.address?.region ??
        '';

    return WaveCard(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          context.push('/jobs/${job.id}');
        }
      },
      margin: EdgeInsets.zero,
      borderRadius: AppSpacing.borderRadiusSm,
      padding: const EdgeInsets.all(12),
      useLiquidGlass: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientAccent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.borderRadiusSm),
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_ownerBadges(l10n).isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _ownerBadges(l10n),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      _jobTitle(l10n),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: context.theme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _isCompanyPosting
                              ? Icons.business_rounded
                              : Icons.person_outline_rounded,
                          size: 13,
                          color: context.theme.iconSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _isCompanyPosting
                                ? job.jobCompanyName!.trim()
                                : l10n.jobIndividualPoster,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: context.theme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (categoryLabel != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent500.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadiusSm),
                          border: Border.all(
                            color: AppColors.accent500.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          categoryLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent600,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (positions != null)
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 13,
                            color: context.theme.iconSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$positions ${l10n.jobPositions}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: context.theme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: context.theme.iconSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: context.theme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRestricted) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lock_outline,
                              size: 10,
                              color: context.theme.textMuted,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (footerActions != null && footerActions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: footerActions!,
            ),
          ],
        ],
      ),
    );
  }
}
