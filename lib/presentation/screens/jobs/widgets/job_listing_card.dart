import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/job_data.dart';
import '../../../../data/models/listing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/common/wave_card.dart';

class JobListingCard extends ConsumerWidget {
  final Listing job;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool? isFavorite;
  final bool isTogglingFavorite;
  final bool hideFavoriteButton;
  final List<Widget>? footerActions;
  final bool showOwnerBadges;

  const JobListingCard({
    super.key,
    required this.job,
    this.onTap,
    this.onFavorite,
    this.isFavorite,
    this.isTogglingFavorite = false,
    this.hideFavoriteButton = false,
    this.footerActions,
    this.showOwnerBadges = false,
  });

  Widget _buildStatusBadge(String text, Color color) {
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
    if (job.jobTitle != null && job.jobTitle!.trim().isNotEmpty) {
      return job.jobTitle!.trim();
    }
    final category = job.jobCategory;
    if (category != null && category.isNotEmpty) {
      return jobCategoryLabel(category, l10n);
    }
    final company = job.jobCompanyName?.trim();
    if (company != null && company.isNotEmpty) return company;
    return l10n.jobJob;
  }

  bool get _isCompanyPosting {
    final company = job.jobCompanyName?.trim();
    return company != null && company.isNotEmpty;
  }

  String _companyInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'WM';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      final combined = '$first$second'.trim();
      if (combined.isNotEmpty) return combined.toUpperCase();
    }
    final clean = name.trim();
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  List<Widget> _ownerBadges(AppLocalizations l10n) {
    if (!showOwnerBadges) return const [];
    return [
      if (job.status == ListingStatus.frozen)
        _buildStatusBadge(l10n.statusFrozen, AppColors.error),
      if (job.isNew) _buildStatusBadge(l10n.listingNew, AppColors.primary600),
      if (job.isFeatured)
        _buildStatusBadge(l10n.listingFeatured, AppColors.accent600),
      if (job.isVip) _buildStatusBadge(l10n.vipBadge, AppColors.vip),
    ];
  }

  Widget _buildCompanyAvatar(BuildContext context) {
    const double size = 46.0;
    final initials = _companyInitials(job.jobCompanyName);
    final logoUrl = job.mainThumbnailUrl.isNotEmpty
        ? job.mainThumbnailUrl
        : (job.mainImageUrl.isNotEmpty ? job.mainImageUrl : null);

    Widget avatarContent;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _buildMonogram(context, initials, size),
        ),
      );
    } else {
      avatarContent = _buildMonogram(context, initials, size);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        if (_isCompanyPosting)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.accent500,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.theme.surface,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 9,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonogram(BuildContext context, String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.theme.isDark
              ? const [AppColors.primary800, AppColors.primary900]
              : const [AppColors.primary900, AppColors.primary950],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required String text,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor, width: 0.8) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSalary(BuildContext context, AppLocalizations l10n) {
    final currency = job.jobSalaryCurrency ?? 'ETB';
    final isDark = context.theme.isDark;
    final primaryColor = isDark ? AppColors.accent400 : AppColors.primary900;

    if (job.jobSalaryType == 'fixed' && job.jobSalaryMin != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              '$currency ${smartDecimal(job.jobSalaryMin!)}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '/ mo',
            style: TextStyle(
              color: context.theme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (job.jobSalaryType == 'range' &&
        job.jobSalaryMin != null &&
        job.jobSalaryMax != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              '$currency ${smartDecimal(job.jobSalaryMin!)} – ${smartDecimal(job.jobSalaryMax!)}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '/ mo',
            style: TextStyle(
              color: context.theme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      l10n.jobSalaryPerAgreement,
      style: TextStyle(
        color: isDark ? AppColors.accent400 : AppColors.accent700,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildUrgencyBadge(BuildContext context, AppLocalizations l10n) {
    if (job.jobDeadline != null) {
      final now = DateTime.now();
      final isExpired = job.jobDeadline!.isBefore(now);
      final daysLeft = job.jobDeadline!.difference(now).inDays;

      if (isExpired) {
        return _buildBadgePill(
          icon: Icons.timer_off_outlined,
          text: 'Expired',
          bgColor: AppColors.error.withValues(alpha: 0.1),
          textColor: AppColors.error,
        );
      }

      if (daysLeft <= 0) {
        return _buildBadgePill(
          icon: Icons.bolt_rounded,
          text: 'Closes today',
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
        );
      }

      if (daysLeft <= 7) {
        return _buildBadgePill(
          icon: Icons.bolt_rounded,
          text: '$daysLeft days left',
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
        );
      }

      return _buildBadgePill(
        icon: Icons.calendar_today_outlined,
        text: DateFormat('MMM d').format(job.jobDeadline!),
        bgColor: context.theme.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.stone100,
        textColor: context.theme.textSecondary,
      );
    }

    if (job.isNew) {
      return _buildBadgePill(
        icon: Icons.fiber_new_rounded,
        text: l10n.listingNew,
        bgColor: AppColors.accent500.withValues(alpha: 0.12),
        textColor: AppColors.accent600,
      );
    }

    if (job.isFeatured) {
      return _buildBadgePill(
        icon: Icons.star_rounded,
        text: l10n.listingFeatured,
        bgColor: AppColors.accent500.withValues(alpha: 0.12),
        textColor: AppColors.accent600,
      );
    }

    return null;
  }

  Widget _buildBadgePill({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    final subState = ref.watch(subscriptionProvider);
    final isRestricted = !subState.canSeeFullAddress;

    final category = job.jobCategory;
    final categoryLabel = (category == null || category.isEmpty)
        ? null
        : jobCategoryLabel(category, l10n);
    final positions = job.jobPositionsCount;
    final location =
        job.address?.getLocalizedAddress(context, cache, isRestricted) ??
            job.address?.region ??
            '';

    final favoritesState = ref.watch(favoritesProvider);
    final isFav = isFavorite ?? favoritesState.favorites.any((f) => f.id == job.id);
    final showFavoriteButton = !hideFavoriteButton && !showOwnerBadges;

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
      borderRadius: AppSpacing.borderRadiusLg,
      padding: const EdgeInsets.all(14),
      useLiquidGlass: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_ownerBadges(l10n).isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _ownerBadges(l10n),
            ),
            const SizedBox(height: 8),
          ],
          // Top Row: Company Avatar + Title / Company / Location + Bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyAvatar(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jobTitle(l10n),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: context.theme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _isCompanyPosting
                                ? job.jobCompanyName!.trim()
                                : l10n.jobIndividualPoster,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.theme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: context.theme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: context.theme.iconSecondary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              location,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: context.theme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRestricted) ...[
                            const SizedBox(width: 3),
                            Icon(
                              Icons.lock_outline,
                              size: 10,
                              color: context.theme.textMuted,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (showFavoriteButton) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isTogglingFavorite
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          if (onFavorite != null) {
                            onFavorite!();
                          } else {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(job.id);
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isFav
                          ? Colors.red.withValues(alpha: 0.95)
                          : Colors.black.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isTogglingFavorite
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ],
          ),

          // Metadata Chips Row
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (job.jobType != null && job.jobType!.isNotEmpty)
                _buildPill(
                  text: jobTypeLabel(job.jobType!, l10n),
                  bgColor: context.theme.isDark
                      ? AppColors.cta900.withValues(alpha: 0.35)
                      : AppColors.cta50,
                  textColor: context.theme.isDark
                      ? AppColors.cta300
                      : AppColors.cta700,
                  borderColor: AppColors.cta400.withValues(alpha: 0.25),
                ),
              if (categoryLabel != null)
                _buildPill(
                  text: categoryLabel,
                  bgColor: context.theme.isDark
                      ? AppColors.accent900.withValues(alpha: 0.35)
                      : AppColors.accent50,
                  textColor: context.theme.isDark
                      ? AppColors.accent300
                      : AppColors.accent700,
                  borderColor: AppColors.accent500.withValues(alpha: 0.25),
                ),
              if (positions != null && positions > 0)
                _buildPill(
                  text: '$positions ${l10n.jobPositions}',
                  bgColor: context.theme.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.stone100,
                  textColor: context.theme.textSecondary,
                  borderColor: context.theme.border.withValues(alpha: 0.3),
                ),
              if (job.jobReqExperience != null &&
                  job.jobReqExperience!.trim().isNotEmpty)
                _buildPill(
                  text: job.jobReqExperience!.trim(),
                  bgColor: context.theme.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.stone100,
                  textColor: context.theme.textSecondary,
                  borderColor: context.theme.border.withValues(alpha: 0.3),
                ),
            ],
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              thickness: 0.6,
              color: context.theme.divider.withValues(alpha: 0.5),
            ),
          ),

          // Footer Row: Salary on Left + Urgency/Deadline on Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: _buildSalary(context, l10n),
              ),
              if (_buildUrgencyBadge(context, l10n) != null) ...[
                const SizedBox(width: 8),
                _buildUrgencyBadge(context, l10n)!,
              ],
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
