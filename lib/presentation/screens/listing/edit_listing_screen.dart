import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/v2/api_v2_error.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/image.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/models/v2/listing_detail.dart';
import '../../../../data/models/v2/listing_summary.dart';
import '../../../../data/models/v2/owner_listing.dart';
import '../../../../data/services/address_service.dart';
import '../../../../data/services/listing_media_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import 'widgets/listing_form_steps.dart';
import 'widgets/submission_overlay.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final dynamic listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _pageController = PageController();
  late ListingFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _submittedSuccessfully = false;
  ValueNotifier<SubmissionState>? _submissionNotifier;
  Timer? _uploadProgressTimer;
  AddressService get _addressService => ref.read(addressServiceProvider);
  final Map<int, List<String>> _stepErrors = {};

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final raw = widget.listing;

    if (raw is ListingDetail) {
      final images = raw.images
          .where((img) => img.url != null)
          .map((img) => ImageModel(
                id: img.id ?? 0,
                imagePath: img.url!,
              ))
          .toList();
      _formData = ListingFormData(
        type: raw.kind == ListingKind.house ? 'house' : 'land',
        listingType: raw.listingType,
        description: raw.description,
        priceFixed: raw.price.amount,
        priceOnAgreement: raw.price.negotiable ||
            (raw.listingType == 'rental' && raw.price.amount == null),
        rentalPeriodUnit: raw.price.period ?? 'month',
        totalSquareMeters: raw.attributes.totalSquareMeters,
        holdingType: raw.attributes.holdingType ?? 'Free Hold',
        useType: raw.attributes.useType ?? 'Residential',
        hasDebtOrEncumbrance: raw.attributes.hasDebtOrEncumbrance,
        debtAmount: raw.attributes.debtAmount,
        taxPaidUntilYear: raw.holdingDetails.private?.taxPaidUntilYear,
        acquisitionClarification:
            raw.holdingDetails.private?.acquisitionClarification,
        leasedYear: raw.holdingDetails.lease?.leasedYear,
        leasePricePerSqm: raw.holdingDetails.lease?.leasePricePerSqm,
        buildType: raw.holdingDetails.lease?.buildType,
        annualPayment: raw.holdingDetails.lease?.annualPayment,
        cooperativeName: raw.holdingDetails.cooperative?.cooperativeName,
        cooperativeCode: raw.holdingDetails.cooperative?.cooperativeCode,
        buildingStatus: raw.holdingDetails.cooperative?.buildingStatus,
        bedrooms: raw.details.bedrooms,
        bathrooms: raw.details.bathrooms,
        kitchens: raw.details.kitchens,
        yearBuilt: raw.details.yearBuilt,
        houseType: raw.details.houseType,
        electricity: raw.details.electricity,
        water: raw.details.water,
        parkingAvailable: raw.details.parkingAvailable,
        frontAreaSqm: raw.attributes.frontAreaSqm,
        sideAreaSqm: raw.attributes.sideAreaSqm,
        facingDirection: raw.attributes.facingDirection,
        specificLocation: raw.attributes.specificLocation,
        existingImages: images,
        existingVideoUrl: raw.video.url,
        isVip: raw.isVip,
      );
    } else if (raw is OwnerListing) {
      _formData = ListingFormData(
        type: raw.kind == ListingKind.house ? 'house' : 'land',
        listingType: raw.listingType,
        priceFixed: raw.price.amount,
        priceOnAgreement: raw.price.negotiable,
        isVip: raw.isVip,
      );
    } else if (raw is Listing) {
      final localeCode = ref.read(localeProvider).locale?.languageCode ?? 'en';
      final useLocalized = localeCode != 'en';
      _formData = ListingFormData(
        type: raw.propertyType == PropertyType.house ? 'house' : 'land',
        listingType: raw.listingType == ListingType.sale ? 'sale' : 'rental',
        description: raw.description,
        priceFixed: raw.priceFixed,
        priceOnAgreement:
            raw.listingType == ListingType.rental && raw.priceFixed == null,
        totalSquareMeters: raw.totalSquareMeters,
        holdingType: raw.holdingType ?? 'Free Hold',
        useType: raw.useType ?? 'Residential',
        hasDebtOrEncumbrance: raw.hasDebtOrEncumbrance,
        debtAmount: raw.debtAmount,
        taxPaidUntilYear: raw.taxPaidUntilYear,
        acquisitionClarification: raw.acquisitionType,
        leasedYear: raw.leasedYear,
        leasePricePerSqm: raw.leasePricePerSqm,
        buildType: raw.buildType,
        annualPayment: raw.annualPayment,
        cooperativeName: raw.cooperativeName,
        cooperativeCode: raw.cooperativeCode,
        buildingStatus: raw.buildingStatus,
        totalRooms: raw.totalRooms,
        bedrooms: raw.bedrooms,
        bathrooms: raw.bathrooms,
        kitchens: raw.kitchens,
        salons: raw.salons,
        yearBuilt: raw.yearBuilt,
        houseType: raw.houseType,
        electricity: raw.electricity,
        water: raw.water,
        parkingAvailable: raw.parkingAvailable,
        frontAreaSqm: raw.frontAreaSqm,
        sideAreaSqm: raw.sideAreaSqm,
        facingDirection: raw.facingDirection,
        specificLocation: raw.specificLocation,
        rentalPeriodUnit: raw.listingType == ListingType.rental
            ? 'month'
            : raw.rentalPeriodUnit?.toString().split('.').last,
        postedForOtherOwner: raw.postedForOtherOwner,
        ownerName: raw.ownerName ?? '',
        ownerPhone: raw.ownerPhone ?? '',
        addressRegion: useLocalized && raw.address?.regionLocalized != null
            ? raw.address!.regionLocalized!
            : raw.address?.region,
        addressZone: useLocalized && raw.address?.zoneLocalized != null
            ? raw.address!.zoneLocalized!
            : raw.address?.zone,
        addressWoreda: useLocalized && raw.address?.woredaLocalized != null
            ? raw.address!.woredaLocalized!
            : raw.address?.woreda,
        addressKebele: useLocalized && raw.address?.kebeleLocalized != null
            ? raw.address!.kebeleLocalized!
            : raw.address?.kebele,
        addressId: raw.addressId,
        existingImages: raw.images,
        existingSitePlanUrl: raw.sitePlanUrl,
        existingOwnershipProofUrl: raw.ownershipProofUrl,
        existingVideoUrl: raw.videoUrl,
        isVip: raw.isVip,
        postedByAgent: raw.postedByAgent,
        agentId: raw.agentId?.toString() ?? '',
      );
    } else {
      _formData = ListingFormData.empty();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uploadProgressTimer?.cancel();
    if (!_submittedSuccessfully) {
      ListingMediaManager.cleanFormDataFiles(_formData);
    }
    super.dispose();
  }

  void _updateFormData(ListingFormData data) {
    setState(() => _formData = data);
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _nextStep() {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      return;
    }
    setState(() => _stepErrors.remove(_currentStep));

    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
    } else {
      _submitListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
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

  Future<void> _submitListing() async {
    if (_isSubmitting) return;
    if (!mounted) return;
    setState(() => _isSubmitting = true);

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
      );

      _startUploadProgressSimulation();

      final raw = widget.listing;
      final int id = raw is ListingDetail
          ? raw.id
          : raw is OwnerListing
              ? raw.id
              : raw is Listing
                  ? raw.id
                  : 0;

      final payload = <String, dynamic>{
        'type': _formData.type,
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

      await ref.read(ownerListingServiceProvider).updateProperty(id, payload);

      for (final imageId in _formData.removedImageIds) {
        try {
          await ref
              .read(listingMediaV2ServiceProvider)
              .deleteImage(id, imageId);
        } catch (_) {}
      }

      final imageFiles = _formData.images.map((img) => File(img.path)).toList();
      if (imageFiles.isNotEmpty) {
        await ref
            .read(listingMediaV2ServiceProvider)
            .uploadImages(id, imageFiles);
      }

      if (_formData.videoFile != null) {
        await ref
            .read(listingMediaV2ServiceProvider)
            .uploadVideo(id, File(_formData.videoFile!.path));
      } else if (_formData.deleteVideo) {
        try {
          await ref.read(listingMediaV2ServiceProvider).deleteVideo(id);
        } catch (_) {}
      }

      if (_formData.sitePlan != null) {
        await ref
            .read(listingMediaV2ServiceProvider)
            .uploadSitePlan(id, File(_formData.sitePlan!.path));
      } else if (_formData.removeExistingSitePlan) {
        try {
          await ref.read(listingMediaV2ServiceProvider).deleteSitePlan(id);
        } catch (_) {}
      }

      _stopUploadProgressSimulation();

      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.submitting(
        phase: SubmissionPhase.saving,
        label: l10n.submissionSavingChanges,
        progress: 0.9,
      );

      _submittedSuccessfully = true;
      ref.invalidate(catalogItemDetailV2Provider);
      ref.invalidate(myListingsV2Provider);
      ref.invalidate(homeV2Provider);
      await ListingMediaManager.cleanFormDataFiles(_formData);
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.success(
        message: l10n.submissionUpdatedMessage,
        isEdit: true,
      );
    } on ApiV2Exception catch (e) {
      _stopUploadProgressSimulation();
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(
        message: e.message,
        onRetry: _retrySubmission,
      );
    } catch (e) {
      _stopUploadProgressSimulation();
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(
        message: _friendlyErrorMessage(e),
        onRetry: _retrySubmission,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _retrySubmission() async {
    await _submitListing();
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

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    switch (action) {
      case SubmissionDismissAction.viewListings:
        context.pushReplacement('/my-listings');
        break;
      case SubmissionDismissAction.saveDraftAndExit:
        Navigator.of(context).pop(false);
        break;
      case SubmissionDismissAction.createAnother:
      case SubmissionDismissAction.goBack:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: WaveAppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _prevStep,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
              )
            : null,
        title: Text(l10n.listingEditTitle),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _nextStep,
            child:
                Text(_currentStep == 3 ? l10n.listingSubmit : l10n.listingNext),
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
                    isEditMode: true),
                ListingStep2Details(
                    formData: _formData, onUpdate: _updateFormData),
                ListingStep3Media(
                    formData: _formData,
                    onUpdate: _updateFormData,
                    isMediaLocked: true),
                ListingStep4Review(
                    formData: _formData, onUpdate: _updateFormData),
              ],
            ),
          ),
          if (_stepErrors[_currentStep] != null &&
              _stepErrors[_currentStep]!.isNotEmpty)
            _buildErrorBanner(_stepErrors[_currentStep]!),
        ],
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
