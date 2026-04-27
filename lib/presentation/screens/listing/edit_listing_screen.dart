import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../../../data/services/address_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../../../l10n/app_localizations.dart';

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
  final AddressService _addressService = AddressService();

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

  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  Map<String, int?> _kebeleIds = {};
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;
  int? _addressId;

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

    if (listing.address != null) {
      _selectedRegion = listing.address?.region;
      _selectedZone = listing.address?.zone;
      _selectedWoreda = listing.address?.woreda;
      _selectedKebele = listing.address?.kebele;
      _addressId = listing.addressId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRegions());
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

  Future<void> _loadRegions() async {
    final locale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    try {
      final response = await _addressService.getRegions(locale: locale);
      if (response.success && mounted) {
        final regions = response.regions.map((r) => r.region).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        setState(() => _regions = regions);
      }
    } catch (e) {
      if (mounted) setState(() => _regions = []);
    }
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
        'address_id': _addressId ?? _formData.addressId,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(title: Text('Edit Listing')),
        body: Column(
          children: [
            _StepIndicator(currentStep: _currentStep),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _EditStep1Basics(formData: _formData, onUpdate: _updateFormData),
                  _EditStep2Details(formData: _formData, onUpdate: _updateFormData),
                  const _EditStep3Media(),
                  _EditStep4Review(formData: _formData),
                ],
              ),
            ),
            _buildNavButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButtons(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy900 : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) TextButton(onPressed: _prevStep, child: Text(l10n.listingBack)),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(child: WaveButton(text: _currentStep == 3 ? l10n.listingSubmit : l10n.listingNext, isLoading: _isSubmitting, onPressed: _isSubmitting ? null : _nextStep)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / 4,
              backgroundColor: AppColors.zinc200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.wave500),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) {
              final isCompleted = i < currentStep;
              final isCurrent = i == currentStep;
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.wave500 : isCurrent ? AppColors.navy950 : AppColors.zinc300,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}', style: TextStyle(fontSize: 12, color: isCurrent ? Colors.white : AppColors.zinc600)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EditStep1Basics extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _EditStep1Basics({required this.formData, required this.onUpdate});

  @override
  State<_EditStep1Basics> createState() => _EditStep1BasicsState();
}

class _EditStep1BasicsState extends State<_EditStep1Basics> {
  final _specificLocationController = TextEditingController();
  final _priceController = TextEditingController();
  final _debtAmountController = TextEditingController();
  final _taxPaidUntilController = TextEditingController();
  final _leasedYearController = TextEditingController();
  final _leasePriceController = TextEditingController();
  final _buildTypeController = TextEditingController();
  final _annualPaymentController = TextEditingController();
  final _cooperativeNameController = TextEditingController();
  final _cooperativeCodeController = TextEditingController();

  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  Map<String, int?> _kebeleIds = {};
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;

  @override
  void initState() {
    super.initState();
    _specificLocationController.text = widget.formData.specificLocation ?? '';
    if (widget.formData.priceFixed != null) _priceController.text = widget.formData.priceFixed!.toStringAsFixed(0);
    if (widget.formData.debtAmount != null) _debtAmountController.text = widget.formData.debtAmount!.toStringAsFixed(0);
    _taxPaidUntilController.text = widget.formData.taxPaidUntilYear?.toString() ?? '';
    _leasedYearController.text = widget.formData.leasedYear?.toString() ?? '';
    _leasePriceController.text = widget.formData.leasePricePerSqm?.toString() ?? '';
    _buildTypeController.text = widget.formData.buildType ?? '';
    _annualPaymentController.text = widget.formData.annualPayment?.toString() ?? '';
    _cooperativeNameController.text = widget.formData.cooperativeName ?? '';
    _cooperativeCodeController.text = widget.formData.cooperativeCode ?? '';
    
    _selectedRegion = widget.formData.addressRegion;
    _selectedZone = widget.formData.addressZone;
    _selectedWoreda = widget.formData.addressWoreda;
    _selectedKebele = widget.formData.addressKebele;

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialRegions());
  }

  Future<void> _loadInitialRegions() async {
    final service = AddressService();
    final response = await service.getRegions(locale: 'en');
    if (mounted && response.success) {
      final regions = response.regions.map((r) => r.region).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
      setState(() => _regions = regions);
      if (_selectedRegion != null) _loadZones();
    }
  }

  @override
  void dispose() {
    _specificLocationController.dispose();
    _priceController.dispose();
    _debtAmountController.dispose();
    _taxPaidUntilController.dispose();
    _leasedYearController.dispose();
    _leasePriceController.dispose();
    _buildTypeController.dispose();
    _annualPaymentController.dispose();
    _cooperativeNameController.dispose();
    _cooperativeCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.listingPropertyType),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _radioCard(l10n.listingHouse, Icons.home_rounded, 'house', widget.formData.type == 'house', enabled: false)),
              const SizedBox(width: 12),
              Expanded(child: _radioCard(l10n.listingLand, Icons.landscape_rounded, 'land', widget.formData.type == 'land', enabled: false)),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle(l10n.listingHoldingType),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.holdingType.isEmpty ? null : widget.formData.holdingType,
            items: [l10n.listingFreeHold, l10n.listingLeaseHold, l10n.listingCooperative],
            label: l10n.listingSelectHolding,
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(holdingType: v ?? l10n.listingFreeHold)),
          ),
          const SizedBox(height: 16),
          if (widget.formData.holdingType == l10n.listingFreeHold) _buildFreeHoldFields(l10n),
          if (widget.formData.holdingType == l10n.listingLeaseHold) _buildLeaseHoldFields(l10n),
          if (widget.formData.holdingType == l10n.listingCooperative) _buildCooperativeFields(l10n),
          const SizedBox(height: 20),
          _sectionTitle(l10n.listingUseType),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.useType.isEmpty ? null : widget.formData.useType,
            items: [l10n.listingResidential, l10n.listingCommercial, l10n.listingMixed, l10n.listingInvestment],
            label: l10n.listingSelectUse,
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(useType: v ?? l10n.listingResidential)),
          ),
          const SizedBox(height: 20),
          _sectionTitle(l10n.listingLocation),
          const SizedBox(height: 8),
          _buildAddressDropdowns(l10n),
          const SizedBox(height: 12),
          _textField(
            label: l10n.listingSpecificLocation,
            controller: _specificLocationController,
            onSubmitted: (v) => widget.onUpdate(widget.formData.copyWith(specificLocation: v)),
          ),
          const SizedBox(height: 20),
          _sectionTitle(l10n.listingPriceEtb),
          const SizedBox(height: 8),
          _buildNumberField(label: l10n.listingPrice, controller: _priceController, onSubmitted: (v) {
            final cleaned = v.replaceAll(',', '');
            widget.onUpdate(widget.formData.copyWith(priceFixed: double.tryParse(cleaned)));
          }),
          if (widget.formData.listingType == 'rental') ...[
            const SizedBox(height: 12),
            _dropdownField(
              value: widget.formData.rentalPeriodUnit,
              items: ['day', 'week', 'month', 'year'],
              label: l10n.listingRentalPeriod,
              onChanged: (v) => widget.onUpdate(widget.formData.copyWith(rentalPeriodUnit: v)),
            ),
          ],
          const SizedBox(height: 20),
          CheckboxListTile(
            title: Text(l10n.listingHasDebt),
            value: widget.formData.hasDebtOrEncumbrance,
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(hasDebtOrEncumbrance: v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (widget.formData.hasDebtOrEncumbrance) ...[
            const SizedBox(height: 8),
            _buildNumberField(label: l10n.listingDebtAmount, controller: _debtAmountController, onSubmitted: (v) {
              final cleaned = v.replaceAll(',', '');
              widget.onUpdate(widget.formData.copyWith(debtAmount: double.tryParse(cleaned)));
            }),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16));

  Widget _radioCard(String label, IconData icon, String value, bool selected, {bool enabled = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: enabled ? () => widget.onUpdate(widget.formData.copyWith(type: value)) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? (isDark ? AppColors.navy800 : AppColors.navy50) : Colors.transparent,
          border: Border.all(color: selected ? AppColors.wave500 : AppColors.zinc300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? AppColors.wave500 : AppColors.zinc500),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: enabled ? null : AppColors.zinc400)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({required String? value, required List<String> items, required String label, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      dropdownColor: Colors.white,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField({required String label, required TextEditingController controller, required Function(String) onSubmitted}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: TextInputType.number,
      onFieldSubmitted: onSubmitted,
    );
  }

  Widget _textField({required String label, required TextEditingController controller, required Function(String) onSubmitted}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      onFieldSubmitted: onSubmitted,
    );
  }

  Widget _buildFreeHoldFields(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberField(label: l10n.listingTaxPaidYear, controller: _taxPaidUntilController, onSubmitted: (v) {
          final n = int.tryParse(v);
          if (n != null) widget.onUpdate(widget.formData.copyWith(taxPaidUntilYear: n));
        }),
        const SizedBox(height: 12),
        _dropdownField(
          value: widget.formData.acquisitionClarification,
          items: [l10n.listingPurchased, l10n.listingInherited, l10n.listingGift, l10n.listingAssignment, l10n.listingOther],
          label: l10n.listingAcquisition,
          onChanged: (v) => widget.onUpdate(widget.formData.copyWith(acquisitionClarification: v)),
        ),
      ],
    );
  }

  Widget _buildLeaseHoldFields(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberField(label: l10n.listingLeasedYear, controller: _leasedYearController, onSubmitted: (v) {
          final n = int.tryParse(v);
          if (n != null) widget.onUpdate(widget.formData.copyWith(leasedYear: n));
        }),
        const SizedBox(height: 12),
        _buildNumberField(label: l10n.listingLeasePrice, controller: _leasePriceController, onSubmitted: (v) {
          final n = double.tryParse(v.replaceAll(',', ''));
          if (n != null) widget.onUpdate(widget.formData.copyWith(leasePricePerSqm: n));
        }),
        const SizedBox(height: 12),
        _textField(label: l10n.listingBuildType, controller: _buildTypeController, onSubmitted: (v) => widget.onUpdate(widget.formData.copyWith(buildType: v))),
        const SizedBox(height: 12),
        _buildNumberField(label: l10n.listingAnnualPayment, controller: _annualPaymentController, onSubmitted: (v) {
          final n = double.tryParse(v.replaceAll(',', ''));
          if (n != null) widget.onUpdate(widget.formData.copyWith(annualPayment: n));
        }),
      ],
    );
  }

  Widget _buildCooperativeFields(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(label: l10n.listingCooperativeName, controller: _cooperativeNameController, onSubmitted: (v) {
          widget.onUpdate(widget.formData.copyWith(cooperativeName: v));
        }),
        const SizedBox(height: 12),
        _textField(label: l10n.listingCooperativeCode, controller: _cooperativeCodeController, onSubmitted: (v) {
          widget.onUpdate(widget.formData.copyWith(cooperativeCode: v));
        }),
        const SizedBox(height: 12),
        _dropdownField(
          value: widget.formData.buildingStatus,
          items: [l10n.listingFinished, l10n.listingUnfinished],
          label: l10n.listingBuildingStatus,
          onChanged: (v) => widget.onUpdate(widget.formData.copyWith(buildingStatus: v)),
        ),
      ],
    );
  }

  Widget _buildAddressDropdowns(AppLocalizations l10n) {
    return Column(
      children: [
        _addressDropdown(value: _selectedRegion, items: _regions, label: l10n.listingRegion, onChanged: (v) {
          setState(() {
            _selectedRegion = v;
            _selectedZone = null; _selectedWoreda = null; _selectedKebele = null;
            _zones = []; _woredas = []; _kebeles = [];
          });
          if (v != null) _loadZones();
        }),
        const SizedBox(height: 12),
        _addressDropdown(value: _selectedZone, items: _zones, label: l10n.listingZone, isLoading: _loadingZones, onChanged: (v) {
          setState(() {
            _selectedZone = v;
            _selectedWoreda = null; _selectedKebele = null;
            _woredas = []; _kebeles = [];
          });
          if (v != null) _loadWoredas();
        }),
        const SizedBox(height: 12),
        _addressDropdown(value: _selectedWoreda, items: _woredas, label: l10n.listingWoreda, isLoading: _loadingWoredas, onChanged: (v) {
          setState(() {
            _selectedWoreda = v;
            _selectedKebele = null;
            _kebeles = [];
          });
          if (v != null) _loadKebeles();
        }),
        const SizedBox(height: 12),
        _addressDropdown(value: _selectedKebele, items: _kebeles, label: l10n.listingKebele, isLoading: _loadingKebeles, onChanged: (v) {
          setState(() => _selectedKebele = v);
        }),
      ],
    );
  }

  Widget _addressDropdown({required String? value, required List<String> items, required String label, bool isLoading = false, required Function(String?) onChanged}) {
    final effectiveItems = items.isEmpty ? [AppLocalizations.of(context).listingNoOptions] : items;
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      ),
      dropdownColor: Colors.white,
      items: effectiveItems.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: items.isEmpty ? Colors.grey : null)))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _loadZones() async {
    if (_selectedRegion == null) return;
    setState(() => _loadingZones = true);
    try {
      final service = AddressService();
      final response = await service.getZones(region: _selectedRegion!, locale: 'en');
      if (mounted) {
        final zones = response.zones.map((z) => z.zone).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        setState(() { _zones = zones; _loadingZones = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _zones = []);
    }
  }

  Future<void> _loadWoredas() async {
    if (_selectedRegion == null || _selectedZone == null) return;
    setState(() => _loadingWoredas = true);
    try {
      final service = AddressService();
      final response = await service.getWoredas(region: _selectedRegion!, zone: _selectedZone!, locale: 'en');
      if (mounted) {
        final woredas = response.woredas.map((w) => w.woreda).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        setState(() => _woredas = woredas);
      }
    } catch (_) {
      if (mounted) setState(() => _woredas = []);
    } finally {
      if (mounted) setState(() => _loadingWoredas = false);
    }
  }

  Future<void> _loadKebeles() async {
    if (_selectedRegion == null || _selectedZone == null || _selectedWoreda == null) return;
    setState(() => _loadingKebeles = true);
    try {
      final service = AddressService();
      final response = await service.getKebeles(region: _selectedRegion!, zone: _selectedZone!, woreda: _selectedWoreda!, locale: 'en');
      if (mounted) {
        final kebeles = response.kebeles.map((k) => k.kebele).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        for (final k in response.kebeles) {
          if (k.kebele != null && k.kebele!.isNotEmpty) _kebeleIds[k.kebele!] = k.id;
        }
        setState(() => _kebeles = kebeles);
      }
    } catch (_) {
      if (mounted) setState(() => _kebeles = []);
    } finally {
      if (mounted) setState(() => _loadingKebeles = false);
    }
  }
}

class _EditStep2Details extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _EditStep2Details({required this.formData, required this.onUpdate});

  @override
  State<_EditStep2Details> createState() => _EditStep2DetailsState();
}

class _EditStep2DetailsState extends State<_EditStep2Details> {
  final _totalRoomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _kitchensController = TextEditingController();
  final _salonsController = TextEditingController();
  final _yearBuiltController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _frontAreaController = TextEditingController();
  final _sideAreaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalRoomsController.text = widget.formData.totalRooms?.toString() ?? '';
    _bedroomsController.text = widget.formData.bedrooms?.toString() ?? '';
    _bathroomsController.text = widget.formData.bathrooms?.toString() ?? '';
    _kitchensController.text = widget.formData.kitchens?.toString() ?? '';
    _salonsController.text = widget.formData.salons?.toString() ?? '';
    _yearBuiltController.text = widget.formData.yearBuilt?.toString() ?? '';
    _totalAreaController.text = widget.formData.totalSquareMeters?.toStringAsFixed(0) ?? '';
    _frontAreaController.text = widget.formData.frontAreaSqm?.toStringAsFixed(0) ?? '';
    _sideAreaController.text = widget.formData.sideAreaSqm?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _totalRoomsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _kitchensController.dispose();
    _salonsController.dispose();
    _yearBuiltController.dispose();
    _totalAreaController.dispose();
    _frontAreaController.dispose();
    _sideAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.listingListingType),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _radioCard(l10n.listingSale, Icons.sell, 'sale', widget.formData.listingType == 'sale', enabled: false)),
              const SizedBox(width: 12),
              Expanded(child: _radioCard(l10n.listingRent, Icons.home_work, 'rental', widget.formData.listingType == 'rental', enabled: false)),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle(l10n.listingUseType),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.useType.isEmpty ? null : widget.formData.useType,
            items: [l10n.listingResidential, l10n.listingCommercial, l10n.listingMixed, l10n.listingInvestment],
            label: l10n.listingSelectUse,
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(useType: v ?? l10n.listingResidential)),
          ),
          const SizedBox(height: 20),
          if (widget.formData.type == 'house') ...[
            _sectionTitle(l10n.listingRoomConfig),
            const SizedBox(height: 8),
            _buildNumberField(label: l10n.listingTotalRooms, controller: _totalRoomsController, onSubmitted: (v) {
              final n = int.tryParse(v);
              if (n != null) widget.onUpdate(widget.formData.copyWith(totalRooms: n));
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNumberField(label: l10n.listingBedrooms, controller: _bedroomsController, onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null) widget.onUpdate(widget.formData.copyWith(bedrooms: n));
                })),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField(label: l10n.listingBathrooms, controller: _bathroomsController, onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null) widget.onUpdate(widget.formData.copyWith(bathrooms: n));
                })),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNumberField(label: l10n.listingKitchens, controller: _kitchensController, onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null) widget.onUpdate(widget.formData.copyWith(kitchens: n));
                })),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField(label: l10n.listingSalons, controller: _salonsController, onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null) widget.onUpdate(widget.formData.copyWith(salons: n));
                })),
              ],
            ),
            const SizedBox(height: 16),
            _sectionTitle(l10n.listingHouseType),
            const SizedBox(height: 8),
            _dropdownField(
              value: widget.formData.houseType,
              items: [l10n.listingVilla, l10n.listingApartment, l10n.listingCondominium, l10n.listingTownhouse, l10n.listingBungalow],
              label: l10n.listingSelectHouseType,
              onChanged: (v) => widget.onUpdate(widget.formData.copyWith(houseType: v)),
            ),
            const SizedBox(height: 12),
            _buildNumberField(label: l10n.listingYearBuilt, controller: _yearBuiltController, onSubmitted: (v) {
              final n = int.tryParse(v);
              if (n != null) widget.onUpdate(widget.formData.copyWith(yearBuilt: n));
            }),
            const SizedBox(height: 16),
            _sectionTitle(l10n.listingAmenities),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _amenityChip(l10n.listingElectricity, widget.formData.electricity, (v) => widget.onUpdate(widget.formData.copyWith(electricity: v))),
                _amenityChip(l10n.listingWater, widget.formData.water, (v) => widget.onUpdate(widget.formData.copyWith(water: v))),
                _amenityChip(l10n.listingParking, widget.formData.parkingAvailable, (v) => widget.onUpdate(widget.formData.copyWith(parkingAvailable: v))),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _sectionTitle(l10n.listingAreaDimensions),
          const SizedBox(height: 8),
          _buildNumberField(label: l10n.listingTotalArea, controller: _totalAreaController, onSubmitted: (v) {
            final n = double.tryParse(v.replaceAll(',', ''));
            if (n != null) widget.onUpdate(widget.formData.copyWith(totalSquareMeters: n));
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildNumberField(label: l10n.listingFrontArea, controller: _frontAreaController, onSubmitted: (v) {
                final n = double.tryParse(v.replaceAll(',', ''));
                if (n != null) widget.onUpdate(widget.formData.copyWith(frontAreaSqm: n));
              })),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField(label: l10n.listingSideArea, controller: _sideAreaController, onSubmitted: (v) {
                final n = double.tryParse(v.replaceAll(',', ''));
                if (n != null) widget.onUpdate(widget.formData.copyWith(sideAreaSqm: n));
              })),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle(l10n.listingFacingDirection),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.facingDirection,
            items: [l10n.listingNorth, l10n.listingSouth, l10n.listingEast, l10n.listingWest, l10n.listingNorthEast, l10n.listingNorthWest, l10n.listingSouthEast, l10n.listingSouthWest],
            label: l10n.listingSelectDirection,
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(facingDirection: v)),
          ),
          const SizedBox(height: 16),
          _sectionTitle(l10n.listingDescriptionLabel),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.formData.description,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.listingDescribeProperty, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(description: v)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16));

  Widget _radioCard(String label, IconData icon, String value, bool selected, {bool enabled = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: enabled ? () => widget.onUpdate(widget.formData.copyWith(listingType: value)) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? (isDark ? AppColors.navy800 : AppColors.navy50) : Colors.transparent,
          border: Border.all(color: selected ? AppColors.wave500 : AppColors.zinc300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? AppColors.wave500 : AppColors.zinc500),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: enabled ? null : AppColors.zinc400)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({required String? value, required List<String> items, required String label, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      dropdownColor: Colors.white,
      items: items.isEmpty ? [DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context).listingNoOptions, style: const TextStyle(color: Colors.grey)))] : items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField({required String label, required TextEditingController controller, required Function(String) onSubmitted}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: TextInputType.number,
      onFieldSubmitted: onSubmitted,
    );
  }

  Widget _amenityChip(String label, bool isSelected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: AppColors.wave100,
      checkmarkColor: AppColors.wave600,
    );
  }
}

class _EditStep3Media extends StatelessWidget {
  const _EditStep3Media();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.navy50, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const Icon(Icons.photo_library, size: 48, color: AppColors.navy400),
            const SizedBox(height: 12),
            Text(l10n.listingImages, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Images cannot be changed after submission', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EditStep4Review extends StatelessWidget {
  final ListingFormData formData;
  const _EditStep4Review({required this.formData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingReviewTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: isDark ? AppColors.navy800 : AppColors.navy50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _reviewRow(l10n.listingPropertyType, formData.type == 'house' ? l10n.listingHouse : l10n.listingLand, isDark),
                _reviewRow(l10n.listingListingType, formData.listingType == 'sale' ? l10n.listingSale : l10n.listingRent, isDark),
                _reviewRow(l10n.listingLocation, formData.addressRegion ?? '-', isDark),
                _reviewRow(l10n.listingPrice, formData.priceFixed != null ? '${formData.priceFixed!.toStringAsFixed(0)} ETB' : '-', isDark),
                _reviewRow(l10n.listingTotalArea, formData.totalSquareMeters != null ? '${formData.totalSquareMeters!.toStringAsFixed(0)} sqm' : '-', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppColors.zinc400 : AppColors.zinc600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}