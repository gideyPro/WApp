import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

export 'listing_step1_basics.dart';
export 'listing_step2_details.dart';
export 'listing_step3_media.dart';
export 'listing_step4_review.dart';

class ListingStepIndicator extends StatelessWidget {
  final int currentStep;
  const ListingStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n.listingStepBasics,
      l10n.listingStepDetails,
      l10n.listingStepMedia,
      l10n.listingStepReview
    ];
    return Container(
      color: context.scaffoldBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentStep + 1) / 4,
            backgroundColor: context.divider,
            valueColor: AlwaysStoppedAnimation<Color>(context.isDarkMode ? AppColors.accent400 : AppColors.primary950),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          // Step circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              final isCompleted = i < currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : context.divider,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? Colors.white
                                      : context.theme.textMuted,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        steps[i],
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : context.theme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
