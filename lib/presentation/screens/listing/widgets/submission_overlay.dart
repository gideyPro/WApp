import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_liquid_glass.dart';

enum SubmissionPhase { validating, uploading, saving }

class SubmissionState {
  final bool isSubmitting;
  final bool isSuccess;
  final bool isError;
  final SubmissionPhase? phase;
  final String label;
  final double progress;
  final String message;
  final bool isEdit;
  final VoidCallback? onRetry;
  final VoidCallback? onSaveDraft;

  const SubmissionState._({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isError = false,
    this.phase,
    this.label = '',
    this.progress = 0,
    this.message = '',
    this.isEdit = false,
    this.onRetry,
    this.onSaveDraft,
  });

  factory SubmissionState.submitting({
    required SubmissionPhase phase,
    required String label,
    double progress = 0,
  }) {
    return SubmissionState._(
      isSubmitting: true,
      phase: phase,
      label: label,
      progress: progress,
    );
  }

  factory SubmissionState.success({required String message, bool isEdit = false}) {
    return SubmissionState._(isSuccess: true, message: message, isEdit: isEdit);
  }

  factory SubmissionState.error({
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onSaveDraft,
  }) {
    return SubmissionState._(
      isError: true,
      message: message,
      onRetry: onRetry,
      onSaveDraft: onSaveDraft,
    );
  }
}

class SubmissionOverlay extends StatefulWidget {
  final SubmissionState state;
  final ValueChanged<bool?>? onDismiss;

  const SubmissionOverlay({
    super.key,
    required this.state,
    this.onDismiss,
  });

  static ({ValueNotifier<SubmissionState> notifier, Future<bool?> dismissed}) show(BuildContext context) {
    final notifier = ValueNotifier<SubmissionState>(
      SubmissionState.submitting(
        phase: SubmissionPhase.validating,
        label: 'Validating data...',
      ),
    );

    final future = showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      barrierLabel: 'Submission overlay',
      pageBuilder: (ctx, anim1, anim2) {
        return PopScope(
          canPop: false,
          child: ValueListenableBuilder<SubmissionState>(
            valueListenable: notifier,
            builder: (context, state, _) {
              return SubmissionOverlay(
                state: state,
                onDismiss: (result) {
                  Navigator.of(ctx).pop(result);
                },
              );
            },
          ),
        );
      },
    );

    return (notifier: notifier, dismissed: future);
  }

  @override
  State<SubmissionOverlay> createState() => _SubmissionOverlayState();
}

class _SubmissionOverlayState extends State<SubmissionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final themeColors = ThemeColors(context);

    if (state.isSubmitting) return _buildSubmitting(context, themeColors);
    if (state.isSuccess) return _buildSuccess(context, themeColors);
    return _buildError(context, themeColors);
  }

  Widget _buildSubmitting(BuildContext context, ThemeColors themeColors) {
    final state = widget.state;
    final isUploading = state.phase == SubmissionPhase.uploading;

    return Scaffold(
      backgroundColor: themeColors.scaffold,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated pulse ring
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent500.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accent500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Submitting Your Listing',
                style: AppTextStyles.headline3.copyWith(
                  color: themeColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Step indicators
              _StepIndicator(
                phase: SubmissionPhase.validating,
                currentPhase: state.phase,
                label: 'Validating data',
              ),
              const SizedBox(height: 12),
              _StepIndicator(
                phase: SubmissionPhase.uploading,
                currentPhase: state.phase,
                label: 'Uploading files',
              ),
              const SizedBox(height: 12),
              _StepIndicator(
                phase: SubmissionPhase.saving,
                currentPhase: state.phase,
                label: 'Saving listing',
              ),
              const SizedBox(height: 28),

              // Progress bar (shown during upload)
              if (isUploading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 4,
                    backgroundColor: themeColors.textMuted.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.progress * 100).toInt()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: themeColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Text(
                state.label,
                style: AppTextStyles.caption.copyWith(
                  color: themeColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, ThemeColors themeColors) {
    return Scaffold(
      backgroundColor: themeColors.scaffold,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated checkmark
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, scale, _) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeColors.isDark
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.successLight,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: themeColors.isDark
                            ? AppColors.accent400
                            : AppColors.success,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Listing Submitted!',
                style: AppTextStyles.headline3.copyWith(
                  color: themeColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.state.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: themeColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your listing is pending approval. We\'ll notify you once it\'s live.',
                style: AppTextStyles.caption.copyWith(
                  color: themeColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeightMd,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColors.primary,
                    foregroundColor: themeColors.primaryText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                    ),
                  ),
                  onPressed: () => widget.onDismiss?.call(true),
                  child: Text(
                    'View My Listings',
                    style: AppTextStyles.buttonMedium,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!widget.state.isEdit)
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightMd,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColors.textPrimary,
                      side: BorderSide(color: themeColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                      ),
                    ),
                    onPressed: () => widget.onDismiss?.call(false),
                    child: Text(
                      'Create Another',
                      style: AppTextStyles.buttonMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ThemeColors themeColors) {
    final state = widget.state;
    return Scaffold(
      backgroundColor: themeColors.scaffold,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, scale, _) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeColors.isDark
                            ? AppColors.error.withValues(alpha: 0.2)
                            : AppColors.errorLight,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 40,
                        color: themeColors.isDark
                            ? AppColors.error
                            : AppColors.error,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context).submissionFailed,
                style: AppTextStyles.headline3.copyWith(
                  color: themeColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              LiquidGlass(
                borderRadius: AppSpacing.borderRadiusSm,
                blur: 20,
                tint: AppColors.error,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  state.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: themeColors.isDark
                        ? AppColors.stone300
                        : AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              if (state.onRetry != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightMd,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColors.primary,
                      foregroundColor: themeColors.primaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                      ),
                    ),
                    onPressed: state.onRetry,
                    child: Text(
                      AppLocalizations.of(context).commonRetry,
                      style: AppTextStyles.buttonMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (state.onSaveDraft != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeightMd,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColors.textPrimary,
                      side: BorderSide(color: themeColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                      ),
                    ),
                    onPressed: state.onSaveDraft,
                    child: Text(
                      AppLocalizations.of(context).submissionSaveDraft,
                      style: AppTextStyles.buttonMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: () => widget.onDismiss?.call(null),
                child: Text(
                  AppLocalizations.of(context).submissionGoBack,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: themeColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final SubmissionPhase phase;
  final SubmissionPhase? currentPhase;
  final String label;

  const _StepIndicator({
    required this.phase,
    required this.currentPhase,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = phase == currentPhase;
    final isCompleted = currentPhase != null && phase.index < currentPhase!.index;
    final themeColors = ThemeColors(context);

    Widget leading;
    if (isCompleted) {
      leading = Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent500,
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      );
    } else if (isActive) {
      leading = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent500, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent500,
            ),
          ),
        ),
      );
    } else {
      leading = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: themeColors.textMuted.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive
                ? AppColors.accent500
                : isCompleted
                    ? themeColors.textPrimary
                    : themeColors.textMuted,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
