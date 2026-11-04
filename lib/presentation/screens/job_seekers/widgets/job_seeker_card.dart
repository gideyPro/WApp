import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/job_data.dart';
import '../../../../data/models/job_seeker_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';

class JobSeekerCard extends StatefulWidget {
  final JobSeekerProfile profile;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool? isFavorite;
  final bool isTogglingFavorite;
  final bool hideFavoriteButton;

  const JobSeekerCard({
    super.key,
    required this.profile,
    this.onTap,
    this.onFavorite,
    this.isFavorite,
    this.isTogglingFavorite = false,
    this.hideFavoriteButton = false,
  });

  @override
  State<JobSeekerCard> createState() => _JobSeekerCardState();
}

class _JobSeekerCardState extends State<JobSeekerCard> {
  bool _localFavorite = false;

  JobSeekerProfile get profile => widget.profile;

  bool get _isFav => widget.isFavorite ?? _localFavorite;

  void _handleFavorite() {
    if (widget.onFavorite != null) {
      widget.onFavorite!();
    } else {
      setState(() => _localFavorite = !_localFavorite);
    }
  }

  String _candidateInitials(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'JS';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      final combined = '$first$second'.trim();
      if (combined.isNotEmpty) return combined.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  String? _seniorityLevel(AppLocalizations l10n) {
    final yrs = profile.totalExperienceYears;
    if (yrs >= 7) return l10n.seekerSeniorLevel;
    if (yrs >= 4) return l10n.seekerMidSeniorLevel;
    if (yrs >= 2) return l10n.seekerMidLevel;
    if (yrs > 0) return l10n.seekerJuniorLevel;
    return null;
  }

  String _activityText(AppLocalizations l10n) {
    final date = profile.updatedAt ?? profile.createdAt;
    if (date == null) return l10n.seekerActiveRecently;
    final daysOld = DateTime.now().difference(date).inDays;
    if (daysOld <= 7) return l10n.seekerActiveThisWeek;
    if (daysOld <= 30) return l10n.seekerActiveThisMonth;
    return l10n.seekerActiveRecently;
  }

  String? _experienceChipText(AppLocalizations l10n) {
    if (profile.totalExperienceYears > 0) {
      final yrs = profile.totalExperienceYears;
      final yrsStr = yrs.truncateToDouble() == yrs
          ? yrs.toInt().toString()
          : yrs.toStringAsFixed(1);
      return l10n.seekerYearsExp('$yrsStr+');
    }
    if (profile.experience != null && profile.experience!.trim().isNotEmpty) {
      final exp = profile.experience!.trim();
      if (exp.length <= 20) return exp;
      return '${exp.substring(0, 18)}...';
    }
    return null;
  }

  String? _educationChipText(AppLocalizations l10n) {
    if (profile.educationLevel.isEmpty ||
        profile.educationLevel.toLowerCase() == 'none') {
      return null;
    }
    final label = educationLevelLabel(profile.educationLevel, l10n);
    if (label.isEmpty || label.toLowerCase() == 'none') return null;
    return label;
  }

  String _formatRecency(AppLocalizations l10n) {
    final date = profile.updatedAt ?? profile.createdAt;
    if (date == null) return l10n.listingToday;
    final daysOld = DateTime.now().difference(date).inDays;
    if (daysOld <= 0) {
      return l10n.listingToday;
    } else if (daysOld == 1) {
      return l10n.listingYesterday;
    } else if (daysOld < 7) {
      return l10n.listingDaysAgo(daysOld);
    } else if (daysOld < 30) {
      return l10n.listingWeeksAgo((daysOld / 7).floor());
    } else {
      return l10n.listingMonthsAgo((daysOld / 30).floor());
    }
  }

  Widget _buildAvatar(BuildContext context, bool isDark) {
    const double size = 52.0;
    final initials = _candidateInitials(profile.fullName);
    final photoUrl = profile.photo;

    Widget avatarContent;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _buildMonogram(initials, size, isDark),
        ),
      );
    } else {
      avatarContent = _buildMonogram(initials, size, isDark);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        if (profile.isVerified)
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
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

  Widget _buildMonogram(String initials, double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF064E3B), Color(0xFF0F766E)]
              : const [Color(0xFF0F766E), Color(0xFF115E59)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
            fontSize: 17,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 0.8)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: textColor),
          const SizedBox(width: 4.5),
          Flexible(
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.theme.isDark;

    final category = profile.jobCategory;
    final categoryLabel = (category == null || category.isEmpty)
        ? null
        : jobCategoryLabel(category, l10n);

    final experienceChip = _experienceChipText(l10n);
    final educationChip = _educationChipText(l10n);
    final hasCv = profile.hasCv;

    final seniority = _seniorityLevel(l10n);
    final activity = _activityText(l10n);

    final recencyStr = _formatRecency(l10n);

    final hasBio = profile.description != null &&
        profile.description!.trim().isNotEmpty;

    return Semantics(
      button: true,
      label: '${profile.fullName}, ${profile.professionalTitle}',
      child: WaveCard(
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            context.push('/job-seekers/${profile.id}');
          }
        },
        margin: EdgeInsets.zero,
        borderRadius: AppSpacing.borderRadiusLg,
        padding: const EdgeInsets.all(14),
        useLiquidGlass: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Avatar + Identity Column + Heart Shortlist Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(context, isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line 1: Candidate Name + Verified Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.fullName,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: context.theme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profile.isVerified) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                                    : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF059669).withValues(alpha: 0.4)
                                      : const Color(0xFFA7F3D0),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 10,
                                    color: isDark
                                        ? const Color(0xFF6EE7B7)
                                        : const Color(0xFF047857),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    l10n.listingVerified.toUpperCase(),
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF6EE7B7)
                                          : const Color(0xFF047857),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Line 2: Professional Title
                      Text(
                        profile.professionalTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.accent300 : AppColors.accent700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Line 3: Seniority & Activity status
                      Row(
                        children: [
                          if (seniority != null) ...[
                            Text(
                              seniority,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: context.theme.textMuted,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: context.theme.textMuted,
                              ),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              activity,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: context.theme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!widget.hideFavoriteButton) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: _isFav
                        ? l10n.favoritesRemoved
                        : l10n.favoritesAdded,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _handleFavorite();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _isFav
                              ? Colors.red.withValues(alpha: 0.95)
                              : Colors.black.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: widget.isTogglingFavorite
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                _isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Middle: Scannable Qualification Chips
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: [
                if (experienceChip != null)
                  _buildPill(
                    icon: Icons.work_outline_rounded,
                    text: experienceChip,
                    bgColor: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFECFDF5),
                    textColor: isDark
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFF047857),
                    borderColor: isDark
                        ? const Color(0xFF059669).withValues(alpha: 0.35)
                        : const Color(0xFFA7F3D0),
                  ),
                if (educationChip != null)
                  _buildPill(
                    icon: Icons.school_outlined,
                    text: educationChip,
                    bgColor: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                        : const Color(0xFFEFF6FF),
                    textColor: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF1D4ED8),
                    borderColor: isDark
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.35)
                        : const Color(0xFFBFDBFE),
                  ),
                if (categoryLabel != null)
                  _buildPill(
                    icon: Icons.computer_rounded,
                    text: categoryLabel,
                    bgColor: isDark
                        ? const Color(0xFF581C87).withValues(alpha: 0.4)
                        : const Color(0xFFFAF5FF),
                    textColor: isDark
                        ? const Color(0xFFD8B4FE)
                        : const Color(0xFF7E22CE),
                    borderColor: isDark
                        ? const Color(0xFF9333EA).withValues(alpha: 0.35)
                        : const Color(0xFFE9D5FF),
                  ),
                if (hasCv)
                  _buildPill(
                    icon: Icons.description_outlined,
                    text: l10n.seekerCvAttached,
                    bgColor: isDark
                        ? const Color(0xFF78350F).withValues(alpha: 0.4)
                        : const Color(0xFFFEF3C7),
                    textColor: isDark
                        ? const Color(0xFFFCD34D)
                        : const Color(0xFFB45309),
                    borderColor: isDark
                        ? const Color(0xFFD97706).withValues(alpha: 0.35)
                        : const Color(0xFFFDE68A),
                  ),
              ],
            ),

            // Bio / Summary preview snippet
            if (hasBio) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '"${profile.description!.trim()}"',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.theme.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                    fontSize: 11.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 1,
                thickness: 0.6,
                color: context.theme.divider.withValues(alpha: 0.5),
              ),
            ),

            // Footer Row: Recency on Left, Available for Hire Badge on Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: context.theme.textMuted,
                      ),
                      const SizedBox(width: 3.5),
                      Flexible(
                        child: Text(
                          recencyStr,
                          style: AppTextStyles.caption.copyWith(
                            color: context.theme.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF059669).withValues(alpha: 0.35)
                          : const Color(0xFFA7F3D0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4.5),
                      Text(
                        l10n.seekerAvailableForHire,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF047857),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder matching [JobSeekerCard], used while profiles load.
class JobSeekerCardSkeleton extends StatelessWidget {
  const JobSeekerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.shimmerBase,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bar(context, 140, 15),
                      const SizedBox(height: 6),
                      _bar(context, 180, 12),
                      const SizedBox(height: 6),
                      _bar(context, 110, 11),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.shimmerBase,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Chips Row
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: [
                _pillBar(context, 85, 22),
                _pillBar(context, 95, 22),
                _pillBar(context, 90, 22),
                _pillBar(context, 80, 22),
              ],
            ),
            const SizedBox(height: 8),
            // Bio Container bar
            Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                color: context.shimmerBase,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 0.6,
              color: context.shimmerBase,
            ),
            const SizedBox(height: 8),
            // Footer Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bar(context, 120, 12),
                _pillBar(context, 95, 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _pillBar(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
