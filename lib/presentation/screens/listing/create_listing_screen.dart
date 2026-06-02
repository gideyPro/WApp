import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../../../data/services/address_service.dart';
import '../../../../data/services/listing_media_manager.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../../providers/app_providers.dart';
import '../kyc/kyc_verification_screen.dart';
import 'widgets/listing_form_steps.dart';
import 'widgets/submission_overlay.dart';
/// Create Listing Screen - 4-step wizard matching web version
class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _pageController = PageController();
  ListingFormData _formData = ListingFormData.empty();
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _submittedSuccessfully = false;
  String? _currentSubmissionKey;
  ValueNotifier<SubmissionState>? _submissionNotifier;
  Future<bool?>? _submissionDismissed;
  Timer? _autoSaveTimer;
  Timer? _uploadProgressTimer;
  final _addressService = AddressService();

  AppLocalizations get l10n => AppLocalizations.of(context);

  // Validation state
  final Map<int, List<String>> _stepErrors = {};

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _startAutoSave();
    ref.read(kycStatusProvider.notifier).loadKycStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSaveTimer?.cancel();
    _uploadProgressTimer?.cancel();
    if (!_submittedSuccessfully) {
      ListingMediaManager.cleanFormDataFiles(_formData);
    }
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = ListingFormData.loadDraft();
    if (draft != null) {
      setState(() => _formData = draft);
    }
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _saveDraft());
  }

  Future<void> _saveDraft() async {
    await _formData.saveDraft();
  }

  Future<void> _clearDraft() async {
    await ListingFormData.clearDraft();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _nextStep() async {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      return;
    }
    setState(() => _stepErrors.remove(_currentStep));
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
      await _saveDraft();
    } else {
      await _submitListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  List<String> _validateCurrentStep() {
    final l10n = AppLocalizations.of(context);
    switch (_currentStep) {
      case 0:
        return _formData.validateStep1(l10n);
      case 1:
        return _formData.validateStep2(l10n);
      case 2:
        return _formData.validateStep3(l10n);
      case 3:
        return _formData.validateStep4(l10n);
      default:
        return [];
    }
  }

  String _generateSubmissionKey() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'sub_${now}_$random';
  }

  Future<void> _submitListing() async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    _currentSubmissionKey = _generateSubmissionKey();
    final (:notifier, :dismissed) = SubmissionOverlay.show(context);
    _submissionNotifier = notifier;
    _submissionDismissed = dismissed;
    _submissionNotifier!.value = SubmissionState.submitting(
      phase: SubmissionPhase.validating,
      label: 'Validating data...',
      progress: 0.2,
    );

    try {
      final service = ListingService();
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.uploading,
        label: 'Uploading files...',
      );

      _startUploadProgressSimulation();

      final response = await service.createListing(
        formData: _formData,
        submissionKey: _currentSubmissionKey,
        onProgress: (progress) {
          if (!mounted) return;
          _stopUploadProgressSimulation();
          _submissionNotifier!.value = SubmissionState.submitting(
            phase: SubmissionPhase.uploading,
            label: 'Uploading files...',
            progress: 0.2 + progress * 0.7,
          );
        },
      );

      _stopUploadProgressSimulation();

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.saving,
        label: 'Saving listing...',
        progress: 0.9,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.saving,
        label: 'Saving listing...',
        progress: 1.0,
      );

      if (!mounted) return;
      if (response.success) {
        _submittedSuccessfully = true;
        await _clearDraft();
        await ListingMediaManager.cleanFormDataFiles(_formData);
        if (!mounted) return;
        _submissionNotifier!.value = SubmissionState.success(
          message: 'Your listing has been submitted.',
        );
        final result = await dismissed;
        if (mounted && result == true) Navigator.of(context).pop(true);
      } else {
        _submissionNotifier!.value = SubmissionState.error(
          message: response.message.isNotEmpty
              ? response.message
              : 'Something went wrong. Please try again.',
          onRetry: _retrySubmission,
          onSaveDraft: _saveDraftAndExit,
        );
      }
    } catch (e) {
      _stopUploadProgressSimulation();
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(
        message: _friendlyErrorMessage(e),
        onRetry: _retrySubmission,
        onSaveDraft: _saveDraftAndExit,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _startUploadProgressSimulation() {
    _uploadProgressTimer?.cancel();
    double simulatedProgress = 0.2;
    _uploadProgressTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (_) {
        if (!mounted) return;
        simulatedProgress += 0.04;
        if (simulatedProgress >= 0.9) {
          simulatedProgress = 0.9;
          _uploadProgressTimer?.cancel();
        }
        _submissionNotifier?.value = SubmissionState.submitting(
          phase: SubmissionPhase.uploading,
          label: 'Uploading files...',
          progress: simulatedProgress,
        );
      },
    );
  }

  void _stopUploadProgressSimulation() {
    _uploadProgressTimer?.cancel();
    _uploadProgressTimer = null;
  }

  Future<void> _retrySubmission() async {
    if (!mounted) return;

    // First check if the listing was actually created despite the error
    if (_currentSubmissionKey != null) {
      final service = ListingService();
      final listingId = await service.checkSubmissionKey(_currentSubmissionKey!);
      if (listingId != null) {
        // Listing was already created — show success
        _submittedSuccessfully = true;
        await _clearDraft();
        await ListingMediaManager.cleanFormDataFiles(_formData);
        if (!mounted) return;
        _submissionNotifier!.value = SubmissionState.success(
          message: 'Your listing was submitted successfully.',
        );
        final result = await _submissionDismissed;
        if (mounted && result == true) Navigator.of(context).pop(true);
        return;
      }
    }

    // Normal retry — re-submit
    _submissionNotifier!.value = SubmissionState.submitting(
      phase: SubmissionPhase.validating,
      label: 'Validating data...',
      progress: 0.2,
    );

    try {
      final service = ListingService();
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.uploading,
        label: 'Uploading files...',
      );

      _startUploadProgressSimulation();

      final response = await service.createListing(
        formData: _formData,
        submissionKey: _currentSubmissionKey,
        onProgress: (progress) {
          if (!mounted) return;
          _stopUploadProgressSimulation();
          _submissionNotifier!.value = SubmissionState.submitting(
            phase: SubmissionPhase.uploading,
            label: 'Uploading files...',
            progress: 0.2 + progress * 0.7,
          );
        },
      );

      _stopUploadProgressSimulation();

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.saving,
        label: 'Saving listing...',
        progress: 0.9,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.saving,
        label: 'Saving listing...',
        progress: 1.0,
      );

      if (!mounted) return;
      if (response.success) {
        _submittedSuccessfully = true;
        await _clearDraft();
        await ListingMediaManager.cleanFormDataFiles(_formData);
        if (!mounted) return;
        _submissionNotifier!.value = SubmissionState.success(
          message: 'Your listing has been submitted.',
        );
        final result = await _submissionDismissed;
        if (mounted && result == true) Navigator.of(context).pop(true);
      } else {
        _submissionNotifier!.value = SubmissionState.error(
          message: response.message.isNotEmpty
              ? response.message
              : 'Something went wrong. Please try again.',
          onRetry: _retrySubmission,
          onSaveDraft: _saveDraftAndExit,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(
        message: _friendlyErrorMessage(e),
        onRetry: _retrySubmission,
        onSaveDraft: _saveDraftAndExit,
      );
    }
  }

  String _friendlyErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('Connection refused') || msg.contains('SocketException')) {
      return 'Connection lost. Your data has been saved.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Your data has been saved.';
    }
    return msg.replaceAll(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _saveDraftAndExit() async {
    await _formData.saveDraft();
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  void _updateFormData(ListingFormData newData) {
    setState(() => _formData = newData);
  }

  ({String title, String subtitle}) _listingGateMessage(
      SubscriptionState subState, AppLocalizations l10n) {
    if (!subState.hasPaidSubscription) {
      return (
        title: l10n.subscriptionRequiredTitle,
        subtitle: l10n.subscriptionRequiredListingSubtitle,
      );
    }
    final plan = subState.subscription?.plan;
    if (plan == null || plan.maxListings == 0) {
      return (
        title: l10n.subscriptionPlanNotSupportedListing,
        subtitle: l10n.subscriptionPlanNotSupportedListingSubtitle,
      );
    }
    return (
      title: l10n.subscriptionLimitReachedTitle,
      subtitle: l10n.subscriptionLimitReached,
    );
  }

  Widget _buildSkeleton() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
      body: Shimmer.fromColors(
        baseColor: context.shimmerBase,
        highlightColor: context.shimmerHighlight,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 3; i++) ...[
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: context.shimmerHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.shimmerHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 12),
              Container(
                height: 14,
                width: 140,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subState = ref.watch(subscriptionProvider);
    final kycState = ref.watch(kycStatusProvider);
    final settingsAsync = ref.watch(appSettingsProvider);
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => true,
    );

    // Loading state — wait for data before gating
    if (subState.isLoading || kycState.isLoading) {
      return _buildSkeleton();
    }

    // KYC network error — retry before any gate
    if (kycState.hasError) {
      return WaveMessageScreen.error(
        title: l10n.kycConnectionErrorTitle,
        subtitle: kycState.errorMessage ?? l10n.kycConnectionErrorSubtitle,
        onRetry: () => ref.read(kycStatusProvider.notifier).loadKycStatus(),
        isEmbedded: true,
      );
    }

    // Subscription network error — retry before any gate
    if (subState.hasError) {
      return WaveMessageScreen.error(
        title: l10n.errorSubscription,
        subtitle: subState.errorMessage!,
        onRetry: () => ref.read(subscriptionProvider.notifier).refresh(),
        isEmbedded: true,
      );
    }

    // KYC gate — full page matching listing detail error view
    if (!kycState.isVerified && !kycState.isApproved) {
      return WaveFullPageUpgrade(
        appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
        icon: Icons.verified_outlined,
        iconColor: AppColors.accent500,
        title: kycState.isPending
            ? l10n.kycPendingSubtitleReview
            : l10n.kycRequiredTitle,
        subtitle: kycState.isPending
            ? l10n.kycPendingSubtitleReview
            : l10n.kycRequiredSubtitlePost,
        buttonLabel: kycState.isPending ? '' : l10n.kycVerifyNow,
        onButtonTap: kycState.isPending
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const KycVerificationScreen(),
                  ),
                ),
      );
    }

    // Subscription gate — full page matching listing detail error view
    if (subscriptionEnabled && !subState.canCreateListing) {
      final (:title, :subtitle) = _listingGateMessage(subState, l10n);
      return WaveFullPageUpgrade(
        appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
        icon: Icons.add_home_work_outlined,
        iconColor: AppColors.accent500,
        title: title,
        subtitle: subtitle,
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveDraft();
      },
      child: Scaffold(
        appBar: WaveAppBar(
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _prevStep,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
                )
              : null,
          title: Text(l10n.listingsCreate),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: Text(_currentStep == 3
                  ? l10n.listingSubmit
                  : l10n.listingNext),
            ),
          ],
        ),
        body: Column(
          children: [
            ListingStepIndicator(currentStep: _currentStep),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListingStep1Basics(
                      formData: _formData,
                      onUpdate: _updateFormData,
                      addressService: _addressService,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                  ListingStep2Details(formData: _formData, onUpdate: _updateFormData,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                  ListingStep3Media(formData: _formData, onUpdate: _updateFormData,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                  ListingStep4Review(formData: _formData, onUpdate: _updateFormData,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                ],
              ),
            ),
            if (_stepErrors[_currentStep] != null && _stepErrors[_currentStep]!.isNotEmpty)
              _buildErrorBanner(_stepErrors[_currentStep]!),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(List<String> errors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.errorLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: errors.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(e, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
