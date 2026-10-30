import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/v2/api_v2_error.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/address_service.dart';
import '../../../../data/services/listing_media_manager.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../../providers/app_providers.dart';
import '../../providers/v2_providers.dart';
import 'widgets/listing_form_steps.dart';
import 'widgets/submission_overlay.dart';

/// Create Listing Screen - 4-step wizard matching web version
class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _pageController = PageController();
  ListingFormData _formData = ListingFormData.empty();
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _submittedSuccessfully = false;
  String? _currentSubmissionKey;
  ValueNotifier<SubmissionState>? _submissionNotifier;
  Timer? _autoSaveTimer;
  Timer? _uploadProgressTimer;
  AddressService get _addressService => ref.read(addressServiceProvider);

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

  void _checkInitialRentalAutoSelect() {
    final settingsAsync = ref.read(appSettingsProvider);
    final rentalEnabled = settingsAsync.maybeWhen(
      data: (data) => data['rental_enabled'] == true,
      orElse: () => false,
    );
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => false,
    );
    final subState = ref.read(subscriptionProvider);
    if (rentalEnabled &&
        subscriptionEnabled &&
        !subState.canCreateListing &&
        subState.canCreateRentalListing &&
        _formData.listingType == 'sale') {
      setState(() {
        _formData.listingType = 'rental';
      });
    }
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
    _checkInitialRentalAutoSelect();
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
    final settingsAsync = ref.read(appSettingsProvider);
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => false,
    );
    final subState = ref.read(subscriptionProvider);
    if (subscriptionEnabled) {
      if (_formData.listingType == 'rental' &&
          !subState.canCreateRentalListing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionLimitReachedRental),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_formData.listingType == 'sale' && !subState.canCreateListing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionLimitReached),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

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

    _currentSubmissionKey ??= _generateSubmissionKey();
    final (:notifier, :dismissed) = SubmissionOverlay.show(context);
    _submissionNotifier = notifier;
    unawaited(dismissed.then(_handleSubmissionResult));
    _submissionNotifier!.value = SubmissionState.submitting(
      phase: SubmissionPhase.validating,
      label: l10n.submissionValidating,
      progress: 0.2,
    );

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.uploading,
        label: l10n.submissionUploading,
        progress: 0.3,
      );

      _startUploadProgressSimulation();

      final payload = <String, dynamic>{
        'type': _formData.type,
        'submission_key': _currentSubmissionKey,
        'listing_type': _formData.listingType,
        if (_formData.priceFixed != null) 'price': _formData.priceFixed,
        if (_formData.isRental && _formData.rentalPeriodUnit != null)
          'rental_period': _formData.rentalPeriodUnit,
        if (_formData.addressId != null) 'address_id': _formData.addressId,
        if (_formData.specificLocation != null &&
            _formData.specificLocation!.isNotEmpty)
          'specific_location': _formData.specificLocation,
        if (_formData.description != null && _formData.description!.isNotEmpty)
          'description': _formData.description,
        'attributes': {
          if (_formData.useType.isNotEmpty) 'use_type': _formData.useType,
          if (_formData.facingDirection != null)
            'facing_direction': _formData.facingDirection,
          if (_formData.totalSquareMeters != null)
            'total_square_meters': _formData.totalSquareMeters,
          if (_formData.frontAreaSqm != null)
            'front_area_sqm': _formData.frontAreaSqm,
          if (_formData.sideAreaSqm != null)
            'side_area_sqm': _formData.sideAreaSqm,
          if (_formData.hasDebtOrEncumbrance) 'has_debt_or_encumbrance': true,
          if (_formData.hasDebtOrEncumbrance && _formData.debtAmount != null)
            'debt_amount': _formData.debtAmount,
        },
        if (_formData.type == 'house')
          'details': {
            if (_formData.totalRooms != null)
              'total_rooms': _formData.totalRooms,
            if (_formData.bedrooms != null) 'bedrooms': _formData.bedrooms,
            if (_formData.bathrooms != null) 'bathrooms': _formData.bathrooms,
            if (_formData.kitchens != null) 'kitchens': _formData.kitchens,
            if (_formData.salons != null) 'salons': _formData.salons,
            if (_formData.floors != null) 'floors': _formData.floors,
            if (_formData.yearBuilt != null) 'year_built': _formData.yearBuilt,
            if (_formData.houseType != null) 'house_type': _formData.houseType,
            'electricity': _formData.electricity,
            'water': _formData.water,
            'parking_available': _formData.parkingAvailable,
          },
        'holding': {
          'type': _formData.holdingType,
          if (_formData.holdingType == 'Free Hold')
            'private': {
              if (_formData.taxPaidUntilYear != null)
                'tax_paid_until_year': _formData.taxPaidUntilYear,
              if (_formData.acquisitionClarification != null)
                'acquisition_clarification': _formData.acquisitionClarification,
            },
          if (_formData.holdingType == 'Lease Hold')
            'lease': {
              if (_formData.leasedYear != null)
                'leased_year': _formData.leasedYear,
              if (_formData.leasePricePerSqm != null)
                'lease_price_per_sqm': _formData.leasePricePerSqm,
              if (_formData.buildType != null)
                'build_type': _formData.buildType,
              if (_formData.annualPayment != null)
                'annual_payment': _formData.annualPayment,
              'is_transferable': _formData.isTransferable,
            },
          if (_formData.holdingType == 'Cooperative')
            'cooperative': {
              if (_formData.cooperativeName != null)
                'cooperative_name': _formData.cooperativeName,
              if (_formData.cooperativeCode != null)
                'cooperative_code': _formData.cooperativeCode,
              if (_formData.buildingStatus != null)
                'building_status': _formData.buildingStatus,
            },
        },
      };

      final draft =
          await ref.read(ownerListingServiceProvider).createProperty(payload);

      // Upload media
      final imageFiles = _formData.images.map((img) => File(img.path)).toList();
      if (imageFiles.isNotEmpty) {
        await ref
            .read(listingMediaV2ServiceProvider)
            .uploadImages(draft.id, imageFiles);
      }

      if (_formData.videoFile != null) {
        await ref
            .read(listingMediaV2ServiceProvider)
            .uploadVideo(draft.id, File(_formData.videoFile!.path));
      }

      if (_formData.sitePlan != null) {
        await ref
            .read(listingMediaV2ServiceProvider)
            .uploadSitePlan(draft.id, File(_formData.sitePlan!.path));
      }

      _stopUploadProgressSimulation();

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.saving,
        label: l10n.submissionSaving,
        progress: 0.9,
      );

      // Submit for moderation
      await ref.read(ownerListingServiceProvider).submit(draft.id);

      _submittedSuccessfully = true;
      ref.invalidate(subscriptionOverviewProvider);
      unawaited(ref.read(subscriptionProvider.notifier).refresh());
      await _clearDraft();
      await ListingMediaManager.cleanFormDataFiles(_formData);
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.success(
        message: l10n.submissionCreatedMessage,
      );
    } on ApiV2Exception catch (e) {
      _stopUploadProgressSimulation();
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(
        message: e.message,
        onRetry: _retrySubmission,
        canSaveDraft: true,
      );
    } catch (e) {
      _stopUploadProgressSimulation();
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(
        message: _friendlyErrorMessage(e),
        onRetry: _retrySubmission,
        canSaveDraft: true,
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
          label: l10n.submissionUploading,
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
    await _submitListing();
  }

  String _friendlyErrorMessage(Object error) {
    final l10n = AppLocalizations.of(context);
    final msg = error.toString();
    if (msg.contains('Connection refused') || msg.contains('SocketException')) {
      return l10n.submissionConnectionLost;
    }
    if (msg.contains('timeout')) {
      return l10n.submissionRequestTimedOut;
    }
    return msg.replaceAll(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _handleSubmissionResult(SubmissionDismissAction? action) async {
    if (!mounted ||
        action == null ||
        action == SubmissionDismissAction.goBack) {
      return;
    }

    // Let the dialog route finish its reverse transition before touching
    // the navigation stack underneath it.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    switch (action) {
      case SubmissionDismissAction.viewListings:
        context.pushReplacement('/my-listings');
        break;
      case SubmissionDismissAction.createAnother:
        context.pushReplacement('/listings/create');
        break;
      case SubmissionDismissAction.saveDraftAndExit:
        await _formData.saveDraft();
        if (mounted) Navigator.of(context).pop(false);
        break;
      case SubmissionDismissAction.goBack:
        break;
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
    if (plan == null ||
        (plan.maxListings == 0 && plan.maxRentalListings == 0)) {
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
                    borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
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
    final rentalEnabled = settingsAsync.maybeWhen(
      data: (data) => data['rental_enabled'] == true,
      orElse: () => false,
    );
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => false,
    );

    ref.listen<SubscriptionState>(subscriptionProvider, (prev, next) {
      final settings = ref.read(appSettingsProvider).valueOrNull;
      final rentEnabled = settings?['rental_enabled'] == true;
      final subEnabled = settings?['subscription_enabled'] == true;
      if (rentEnabled &&
          subEnabled &&
          !next.canCreateListing &&
          next.canCreateRentalListing &&
          _formData.listingType == 'sale') {
        setState(() {
          _formData.listingType = 'rental';
        });
      }
    });

    // Loading state — wait for data before gating
    if (subState.isLoading || kycState.isLoading || settingsAsync.isLoading) {
      return _buildSkeleton();
    }

    // KYC network error — full screen with retry
    if (kycState.hasError) {
      return WaveMessageScreen.error(
        title: l10n.kycConnectionErrorTitle,
        subtitle: kycState.errorMessage ?? l10n.kycConnectionErrorSubtitle,
        onRetry: () => ref.read(kycStatusProvider.notifier).loadKycStatus(),
      );
    }

    // Subscription network error — full screen with retry
    if (subState.hasError) {
      return WaveMessageScreen.error(
        title: l10n.errorSubscription,
        subtitle: subState.errorMessage!,
        onRetry: () => ref.read(subscriptionProvider.notifier).refresh(),
      );
    }

    // KYC gate — full page matching listing detail error view
    if (!kycState.isVerified && !kycState.isApproved) {
      return WaveFullPageUpgrade(
        appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
        icon: Icons.verified_outlined,
        iconColor: AppColors.accent500,
        title:
            kycState.isPending ? l10n.kycPendingTitle : l10n.kycRequiredTitle,
        subtitle: kycState.isPending
            ? l10n.kycPendingSubtitleReview
            : l10n.kycRequiredSubtitlePost,
        buttonLabel: kycState.isPending ? '' : l10n.kycVerifyNow,
        onButtonTap: kycState.isPending ? null : () => context.push('/kyc'),
      );
    }

    // Subscription gate — full page matching listing detail error view
    final canCreateAny = subState.canCreateListing ||
        (rentalEnabled && subState.canCreateRentalListing);
    if (subscriptionEnabled && !canCreateAny) {
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
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 48),
                )
              : null,
          title: Text(l10n.listingsCreate),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: Text(
                  _currentStep == 3 ? l10n.listingSubmit : l10n.listingNext),
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
                  ListingStep2Details(
                      formData: _formData,
                      onUpdate: _updateFormData,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                  ListingStep3Media(
                      formData: _formData,
                      onUpdate: _updateFormData,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                  ListingStep4Review(
                      formData: _formData,
                      onUpdate: _updateFormData,
                      stepErrors: _stepErrors[_currentStep] ?? []),
                ],
              ),
            ),
            if (_stepErrors[_currentStep] != null &&
                _stepErrors[_currentStep]!.isNotEmpty)
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
        children: errors
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
