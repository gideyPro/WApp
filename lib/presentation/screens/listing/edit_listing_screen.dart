import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../../../data/services/address_service.dart';
import '../../providers/app_providers.dart';
import '../../../../l10n/app_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _debtAmountController = TextEditingController();
  final _taxPaidUntilController = TextEditingController();
  final _cooperativeNameController = TextEditingController();
  final _cooperativeCodeController = TextEditingController();
  final _totalRoomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _kitchensController = TextEditingController();
  final _salonsController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _frontAreaController = TextEditingController();
  final _sideAreaController = TextEditingController();

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
    );

    _titleController.text = listing.specificLocation ?? '';
    _priceController.text = listing.priceFixed?.toStringAsFixed(0) ?? '';
    _descriptionController.text = listing.description ?? '';
    if (listing.debtAmount != null) _debtAmountController.text = listing.debtAmount!.toStringAsFixed(0);
    if (listing.taxPaidUntilYear != null) _taxPaidUntilController.text = listing.taxPaidUntilYear.toString();
    _cooperativeNameController.text = listing.cooperativeName ?? '';
    _cooperativeCodeController.text = listing.cooperativeCode ?? '';
    if (listing.totalRooms != null) _totalRoomsController.text = listing.totalRooms.toString();
    if (listing.bedrooms != null) _bedroomsController.text = listing.bedrooms.toString();
    if (listing.bathrooms != null) _bathroomsController.text = listing.bathrooms.toString();
    if (listing.kitchens != null) _kitchensController.text = listing.kitchens.toString();
    if (listing.salons != null) _salonsController.text = listing.salons.toString();
    if (listing.totalSquareMeters != null) _totalAreaController.text = listing.totalSquareMeters!.toStringAsFixed(0);
    if (listing.frontAreaSqm != null) _frontAreaController.text = listing.frontAreaSqm!.toStringAsFixed(0);
    if (listing.sideAreaSqm != null) _sideAreaController.text = listing.sideAreaSqm!.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _debtAmountController.dispose();
    _taxPaidUntilController.dispose();
    _cooperativeNameController.dispose();
    _cooperativeCodeController.dispose();
    _totalRoomsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _kitchensController.dispose();
    _salonsController.dispose();
    _totalAreaController.dispose();
    _frontAreaController.dispose();
    _sideAreaController.dispose();
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
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
    } else {
      _submitListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  Future<void> _submitListing() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final service = ListingService();
      final data = <String, dynamic>{
        'type': _formData.type,
        'listing_type': _formData.listingType,
        'description': _formData.description ?? '',
        'specific_location': _formData.specificLocation,
        if (_formData.priceFixed != null) 'price_fixed': _formData.priceFixed,
        if (_formData.rentalPeriodUnit != null) 'rental_period_unit': _formData.rentalPeriodUnit,
        if (_formData.totalSquareMeters != null) 'total_square_meters': _formData.totalSquareMeters,
        'holding_type': _formData.holdingType,
        'use_type': _formData.useType,
        'has_debt_or_encumbrance': _formData.hasDebtOrEncumbrance ? 1 : 0,
        if (_formData.debtAmount != null) 'debt_amount': _formData.debtAmount,
        if (_formData.taxPaidUntilYear != null) 'tax_paid_until_year': _formData.taxPaidUntilYear,
        if (_formData.acquisitionClarification != null) 'acquisition_clarification': _formData.acquisitionClarification,
        if (_formData.leasedYear != null) 'leased_year': _formData.leasedYear,
        if (_formData.leasePricePerSqm != null) 'lease_price_per_sqm': _formData.leasePricePerSqm,
        if (_formData.buildType != null) 'build_type': _formData.buildType,
        if (_formData.annualPayment != null) 'annual_payment': _formData.annualPayment,
        if (_formData.cooperativeName != null) 'cooperative_name': _formData.cooperativeName,
        if (_formData.cooperativeCode != null) 'cooperative_code': _formData.cooperativeCode,
        if (_formData.buildingStatus != null) 'building_status': _formData.buildingStatus,
        if (_formData.totalRooms != null) 'total_rooms': _formData.totalRooms,
        if (_formData.bedrooms != null) 'bedrooms': _formData.bedrooms,
        if (_formData.bathrooms != null) 'bathrooms': _formData.bathrooms,
        if (_formData.kitchens != null) 'kitchens': _formData.kitchens,
        if (_formData.salons != null) 'salons': _formData.salons,
        if (_formData.yearBuilt != null) 'year_built': _formData.yearBuilt,
        if (_formData.houseType != null) 'house_type': _formData.houseType,
        'electricity': _formData.electricity ? 1 : 0,
        'water': _formData.water ? 1 : 0,
        'parking_available': _formData.parkingAvailable ? 1 : 0,
        if (_formData.frontAreaSqm != null) 'front_area_sqm': _formData.frontAreaSqm,
        if (_formData.sideAreaSqm != null) 'side_area_sqm': _formData.sideAreaSqm,
        if (_formData.facingDirection != null) 'facing_direction': _formData.facingDirection,
      };

      final result = await service.updateListing(listingId: widget.listing.id, listingData: data);
      if (mounted) {
        if (result.success) {
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
            StepIndicator(currentStep: _currentStep),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  EditStep1Basics(formData: _formData, onUpdate: _updateFormData),
                  EditStep2Details(formData: _formData, onUpdate: _updateFormData),
                  EditStep3Media(formData: _formData, onUpdate: _updateFormData),
                  EditStep4Review(formData: _formData),
                ],
              ),
            ),
            if (!_isSubmitting) buildBottomBar(),
          ],
        ),
      );
  }

  Widget buildBottomBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2)),
      ]),
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

class StepIndicator extends StatelessWidget {
  final int currentStep;
  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n.listingStepBasics,
      l10n.listingStepDetails,
      l10n.listingStepMedia,
      l10n.listingStepReview
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / 4,
            backgroundColor: AppColors.zinc200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy950),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
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
                            ? AppColors.navy950
                            : AppColors.zinc200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : AppColors.zinc600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (i < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < currentStep ? AppColors.navy950 : AppColors.zinc200,
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

class EditStep1Basics extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const EditStep1Basics({super.key, required this.formData, required this.onUpdate});

  @override
  State<EditStep1Basics> createState() => _EditStep1BasicsState();
}

class _EditStep1BasicsState extends State<EditStep1Basics> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16));
  }
}

class EditStep2Details extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const EditStep2Details({super.key, required this.formData, required this.onUpdate});

  @override
  State<EditStep2Details> createState() => _EditStep2DetailsState();
}

class _EditStep2DetailsState extends State<EditStep2Details> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16));
  }
}

class EditStep3Media extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const EditStep3Media({super.key, required this.formData, required this.onUpdate});

  @override
  State<EditStep3Media> createState() => _EditStep3MediaState();
}

class _EditStep3MediaState extends State<EditStep3Media> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16));
  }
}

class EditStep4Review extends StatelessWidget {
  final ListingFormData formData;
  const EditStep4Review({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16));
  }
}
