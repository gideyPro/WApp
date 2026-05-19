import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../../../data/services/address_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../widgets/common/wave_common_widgets.dart';
import 'widgets/listing_form_steps.dart';

 
class EditListingScreen extends ConsumerStatefulWidget {
  final Listing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _pageController = PageController();
  late ListingFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;
  final _addressService = AddressService();
  final Map<int, List<String>> _stepErrors = {};

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    
    _formData = ListingFormData(
      type: listing.propertyType == PropertyType.house ? 'house' : 'land',
      listingType: listing.listingType == ListingType.sale ? 'sale' : 'rental',
      description: listing.description,
      priceFixed: listing.priceFixed,
      totalSquareMeters: listing.totalSquareMeters,
      holdingType: listing.holdingType ?? 'Free Hold',
      useType: listing.useType ?? 'Residential',
      hasDebtOrEncumbrance: listing.hasDebtOrEncumbrance,
      debtAmount: listing.debtAmount,
      taxPaidUntilYear: listing.taxPaidUntilYear,
      acquisitionClarification: listing.acquisitionType,
      leasedYear: listing.leasedYear,
      leasePricePerSqm: listing.leasePricePerSqm,
      buildType: listing.buildType,
      annualPayment: listing.annualPayment,
      cooperativeName: listing.cooperativeName,
      cooperativeCode: listing.cooperativeCode,
      buildingStatus: listing.buildingStatus,
      totalRooms: listing.totalRooms,
      bedrooms: listing.bedrooms,
      bathrooms: listing.bathrooms,
      kitchens: listing.kitchens,
      salons: listing.salons,
      yearBuilt: listing.yearBuilt,
      houseType: listing.houseType,
      electricity: listing.electricity,
      water: listing.water,
      parkingAvailable: listing.parkingAvailable,
      frontAreaSqm: listing.frontAreaSqm,
      sideAreaSqm: listing.sideAreaSqm,
      facingDirection: listing.facingDirection,
      specificLocation: listing.specificLocation,
      rentalPeriodUnit: listing.rentalPeriodUnit?.toString().split('.').last,
      addressRegion: listing.address?.region,
      addressZone: listing.address?.zone,
      addressWoreda: listing.address?.woreda,
      addressKebele: listing.address?.kebele,
      addressId: listing.addressId,
      existingImages: listing.images,
      existingSitePlanUrl: listing.sitePlanUrl,
      existingOwnershipProofUrl: listing.ownershipProofUrl,
      existingLeaseContractUrl: listing.leaseContractUrl,
      existingVideoUrl: listing.videoUrl,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateFormData(ListingFormData data) {
    setState(() => _formData = data);
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _nextStep() {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      if (mounted) {
        WaveToast.showError(context, errors.first);
      }
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
    switch (_currentStep) {
      case 0:
        return _formData.validateStep1();
      case 1:
        return _formData.validateStep2();
      case 2:
        final errors = <String>[];
        
        // 1. Check images (must have at least one either existing or new)
        final hasImages = _formData.images.isNotEmpty || 
            (_formData.existingImages.length > _formData.removedImageIds.length);
        if (!hasImages) errors.add('At least one property image is required');

        // 2. Site Plan is mandatory (Industry Standard #3)
        final hasSitePlan = _formData.sitePlan != null ||
            (_formData.existingSitePlanUrl != null &&
                !_formData.removeExistingSitePlan);
        if (!hasSitePlan) errors.add('A site plan is required');

        // 3. Ownership Proof for Cooperative (Industry Standard #3)
        if (_formData.holdingType == 'Cooperative') {
          final hasOwnership = _formData.ownershipProof != null || _formData.existingOwnershipProofUrl != null;
          if (!hasOwnership) errors.add('Ownership proof is required for cooperative properties');
        }

        // 4. Lease Contract for Lease Hold (Industry Standard #3)
        if (_formData.holdingType == 'Lease Hold') {
          final hasLease = _formData.leaseContract != null || _formData.existingLeaseContractUrl != null;
          if (!hasLease) errors.add('Lease contract is required for lease hold properties');
        }

        return errors;
      case 3:
        return _formData.validateStep4();
      default:
        return [];
    }
  }

  Future<void> _submitListing() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final service = ListingService();
      final result = await service.updateListing(
        listingId: widget.listing.id,
        formData: _formData,
      );
      
      if (mounted) {
        if (result.success) {
          WaveToast.showSuccess(context, 'Listing updated successfully');
          Navigator.of(context).pop(true);
        } else {
          WaveToast.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, 'Failed to update: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: context.cardBg,
          surfaceTintColor: Colors.transparent,
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _prevStep,
                )
              : null,
          title: Text(l10n.listingEditTitle),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_currentStep == 3
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
                      isEditMode: true),
                  ListingStep2Details(formData: _formData, onUpdate: _updateFormData),
                  ListingStep3Media(formData: _formData, onUpdate: _updateFormData),
                  ListingStep4Review(formData: _formData, onUpdate: _updateFormData),
                ],
              ),
            ),
            if (_stepErrors[_currentStep] != null && _stepErrors[_currentStep]!.isNotEmpty)
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
        children: errors.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: AppColors.error),
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
