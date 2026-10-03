import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/job_data.dart';
import '../../../../data/models/job_seeker_profile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';

class JobSeekerCard extends StatelessWidget {
  final JobSeekerProfile profile;
  final VoidCallback? onTap;

  const JobSeekerCard({super.key, required this.profile, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = profile.jobCategory;
    final categoryLabel =
        (category == null || category.isEmpty) ? null : jobCategoryLabel(category, l10n);

    return WaveCard(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          context.push('/job-seekers/${profile.id}');
        }
      },
      margin: EdgeInsets.zero,
      borderRadius: AppSpacing.borderRadiusSm,
      padding: const EdgeInsets.all(12),
      useLiquidGlass: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(photo: profile.photo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.professionalTitle,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: context.theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
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
                Text(
                  profile.fullName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.theme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.theme.textMuted,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photo;
  const _Avatar({this.photo});

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    if (photo == null || photo!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent500.withValues(alpha: 0.12),
          border: Border.all(
            color: AppColors.accent500.withValues(alpha: 0.25),
          ),
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 30,
          color: AppColors.accent600,
        ),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photo!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.accent500.withValues(alpha: 0.12),
          child: const Icon(
            Icons.person_rounded,
            size: 30,
            color: AppColors.accent600,
          ),
        ),
      ),
    );
  }
}
