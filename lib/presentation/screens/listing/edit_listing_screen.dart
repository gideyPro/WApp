import 'package:flutter/material.dart';
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
      existingSitePlanUrl: listing.sitePlanImageLink != null ? 'https://wavemart.et/storage/${listing.sitePlanImageLink}' : null,
      existingOwnershipProofUrl: listing.ownershipProofLink != null ? 'https://wavemart.et/storage/${listing.ownershipProofLink}' : null,
      existingLeaseContractUrl: listing.leaseContractLink != null ? 'https://wavemart.et/storage/${listing.leaseContractLink}' : null,
      existingDebtDocumentUrl: listing.debtEncumbranceFileLink != null ? 'https://wavemart.et/storage/${listing.debtEncumbranceFileLink}' : null,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), backgroundColor: AppColors.error),
      );
      return;
    }

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
        // Skip media validation on edit if there are existing images
        if (_formData.existingImages.length > _formData.removedImageIds.length) {
          return [];
        }
        return _formData.validateStep3();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully'), backgroundColor: AppColors.success),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.error),
        );
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
                    addressService: _addressService
                  ),
                  ListingStep2Details(formData: _formData, onUpdate: _updateFormData),
                  ListingStep3Media(formData: _formData, onUpdate: _updateFormData),
                  ListingStep4Review(formData: _formData, onUpdate: _updateFormData),
                ],
              ),
            ),
            if (!_isSubmitting) _buildBottomBar(),
          ],
        ),
      );
  }

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sheetBg, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4)
          ),
        ],
        border: Border(top: BorderSide(color: context.divider.withOpacity(0.5))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: Text(l10n.listingBack),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wave500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_currentStep == 3
                        ? l10n.listingSubmitListing
                        : l10n.listingContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
