import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../../../data/services/address_service.dart';
import '../../../../data/models/address.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';

/// Create Listing Screen - 4-step wizard matching web version
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _pageController = PageController();
  ListingFormData _formData = ListingFormData.empty();
  int _currentStep = 0;
  bool _isSubmitting = false;
  Timer? _autoSaveTimer;
  final _addressService = AddressService();

  // Validation state
  Map<int, List<String>> _stepErrors = {};

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _startAutoSave();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSaveTimer?.cancel();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.first),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
    switch (_currentStep) {
      case 0:
        return _formData.validateStep1();
      case 1:
        return _formData.validateStep2();
      case 2:
        return _formData.validateStep3();
      case 3:
        return _formData.validateStep4();
      default:
        return [];
    }
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);
    try {
      final service = ListingService();
      final response = await service.createListing(formData: _formData);
      if (mounted) {
        if (response.success) {
          await _clearDraft();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(l10n.listingSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.message),
                backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.listingError(e.toString())), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _updateFormData(ListingFormData newData) {
    setState(() => _formData = newData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveDraft();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.listingsCreate),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: _isSubmitting
                  ? SizedBox(
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
            _StepIndicator(currentStep: _currentStep),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Basics(
                      formData: _formData,
                      onUpdate: _updateFormData,
                      addressService: _addressService),
                  _Step2Details(formData: _formData, onUpdate: _updateFormData),
                  _Step3Media(formData: _formData, onUpdate: _updateFormData),
                  _Step4Review(formData: _formData, onUpdate: _updateFormData),
                ],
              ),
            ),
            if (!_isSubmitting) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
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
            if (_currentStep > 0) SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wave500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? SizedBox(
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

// ===================== STEP INDICATOR =====================

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

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
          // Progress bar
          LinearProgressIndicator(
            value: (currentStep + 1) / 4,
            backgroundColor: AppColors.zinc200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy950),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          SizedBox(height: 8),
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
                            ? AppColors.navy950
                            : AppColors.zinc200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? Colors.white
                                      : AppColors.zinc500,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isCurrent ? AppColors.navy900 : AppColors.zinc400,
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

// ===================== STEP 1: BASICS =====================

class _Step1Basics extends ConsumerStatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final AddressService addressService;
  const _Step1Basics(
      {required this.formData,
      required this.onUpdate,
      required this.addressService});

  @override
  ConsumerState<_Step1Basics> createState() => _Step1BasicsState();
}

class _Step1BasicsState extends ConsumerState<_Step1Basics> {
  late TextEditingController _priceController;
  late TextEditingController _debtAmountController;
  late TextEditingController _taxPaidUntilController;
  late TextEditingController _leasedYearController;
  late TextEditingController _leasePriceController;
  late TextEditingController _buildTypeController;
  late TextEditingController _annualPaymentController;
  late TextEditingController _cooperativeNameController;
  late TextEditingController _cooperativeCodeController;
  late TextEditingController _specificLocationController;

  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  Map<String, int?> _kebeleIds = {};
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;
  int? _addressId;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.formData.priceFixed != null
          ? _formatNumber(widget.formData.priceFixed!)
          : '',
    );
    _debtAmountController = TextEditingController(
      text: widget.formData.debtAmount != null
          ? _formatNumber(widget.formData.debtAmount!)
          : '',
    );
    _taxPaidUntilController = TextEditingController(
      text: widget.formData.taxPaidUntilYear?.toString() ?? '',
    );
    _leasedYearController = TextEditingController(
      text: widget.formData.leasedYear?.toString() ?? '',
    );
    _leasePriceController = TextEditingController(
      text: widget.formData.leasePricePerSqm?.toString() ?? '',
    );
    _buildTypeController = TextEditingController(
      text: widget.formData.buildType ?? '',
    );
    _annualPaymentController = TextEditingController(
      text: widget.formData.annualPayment?.toString() ?? '',
    );
    _cooperativeNameController = TextEditingController(
      text: widget.formData.cooperativeName ?? '',
    );
    _cooperativeCodeController = TextEditingController(
      text: widget.formData.cooperativeCode ?? '',
    );
    _specificLocationController = TextEditingController(
      text: widget.formData.specificLocation ?? '',
    );
    _loadRegions();
    if (widget.formData.addressRegion != null) {
      _selectedRegion = widget.formData.addressRegion;
      _loadZones();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _debtAmountController.dispose();
    _taxPaidUntilController.dispose();
    _leasedYearController.dispose();
    _leasePriceController.dispose();
    _buildTypeController.dispose();
    _annualPaymentController.dispose();
    _cooperativeNameController.dispose();
    _cooperativeCodeController.dispose();
    _specificLocationController.dispose();
    super.dispose();
  }

  String _formatNumber(double n) {
    return n.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1] ?? ''},',
        );
  }

  Future<void> _loadRegions() async {
    final locale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    try {
      final response = await widget.addressService.getRegions(locale: locale);
      if (response.success && mounted) {
        // API now returns simple string array: ["Tigray", "Amhara", ...]
        final regions = response.regions
            .map((r) => r.region)
            .where((s) => s != null && s.isNotEmpty)
            .cast<String>()
            .toList();
        dev.log('Loaded ${regions.length} regions: $regions',
            name: 'AddressPicker');
        setState(() => _regions = regions);
      } else {
        dev.log('Failed to load regions: ${response.message}',
            name: 'AddressPicker');
      }
    } catch (e, st) {
      dev.log('Error loading regions: $e\n$st', name: 'AddressPicker');
      if (mounted) setState(() => _regions = []);
    }
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null;
      _selectedWoreda = null;
      _selectedKebele = null;
      _addressId = null;
      _zones = [];
      _woredas = [];
      _kebeles = [];
    });
    if (region != null) await _loadZones();
    _syncAddressToForm();
  }

  Future<void> _loadZones() async {
    if (_selectedRegion == null) return;
    setState(() => _loadingZones = true);
    final locale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    try {
      final response = await widget.addressService
          .getZones(region: _selectedRegion!, locale: locale);
      if (response.success && mounted) {
        // API returns simple string array: ["Centeral", "Eastern", ...]
        final zones = response.zones
            .map((z) => z.zone)
            .where((s) => s != null && s.isNotEmpty)
            .cast<String>()
            .toList();
        setState(() => _zones = zones);
      }
    } catch (_) {
      if (mounted) setState(() => _zones = []);
    } finally {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone;
      _selectedWoreda = null;
      _selectedKebele = null;
      _addressId = null;
      _woredas = [];
      _kebeles = [];
    });
    if (zone != null) await _loadWoredas();
    _syncAddressToForm();
  }

  Future<void> _loadWoredas() async {
    if (_selectedRegion == null || _selectedZone == null) return;
    setState(() => _loadingWoredas = true);
    final locale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    try {
      final response = await widget.addressService.getWoredas(
          region: _selectedRegion!, zone: _selectedZone!, locale: locale);
      if (response.success && mounted) {
        // API returns simple string array: ["01", "02", ...]
        final woredas = response.woredas
            .map((w) => w.woreda)
            .where((s) => s != null && s.isNotEmpty)
            .cast<String>()
            .toList();
        setState(() => _woredas = woredas);
      }
    } catch (_) {
      if (mounted) setState(() => _woredas = []);
    } finally {
      if (mounted) setState(() => _loadingWoredas = false);
    }
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda;
      _selectedKebele = null;
      _addressId = null;
      _kebeles = [];
    });
    if (woreda != null) await _loadKebeles();
    _syncAddressToForm();
  }

  Future<void> _loadKebeles() async {
    if (_selectedRegion == null ||
        _selectedZone == null ||
        _selectedWoreda == null) return;
    setState(() => _loadingKebeles = true);
    final locale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    try {
      final response = await widget.addressService.getKebeles(
        region: _selectedRegion!,
        zone: _selectedZone!,
        woreda: _selectedWoreda!,
        locale: locale,
      );
      if (response.success && mounted) {
        // API returns array of {id, kebele}: [{id: 1, kebele: "Kebele 01"}, ...]
        final kebeles = response.kebeles
            .map((k) => k.kebele)
            .where((s) => s != null && s.isNotEmpty)
            .cast<String>()
            .toList();
        // Store IDs for address_id mapping
        _kebeleIds.clear();
        for (final k in response.kebeles) {
          if (k.kebele != null && k.kebele!.isNotEmpty) {
            _kebeleIds[k.kebele!] = k.id;
          }
        }
        setState(() => _kebeles = kebeles);
      }
    } catch (_) {
      if (mounted) setState(() => _kebeles = []);
    } finally {
      if (mounted) setState(() => _loadingKebeles = false);
    }
  }

  void _onKebeleSelected(String? kebele) {
    setState(() {
      _selectedKebele = kebele;
      // Look up the actual address ID from the kebele ID map
      _addressId = kebele != null ? _kebeleIds[kebele] : null;
      dev.log('Kebele selected: $kebele, addressId: $_addressId',
          name: 'AddressPicker');
    });
    _syncAddressToForm();
  }

  void _syncAddressToForm() {
    widget.onUpdate(widget.formData.copyWith(
      addressRegion: _selectedRegion,
      addressZone: _selectedZone,
      addressWoreda: _selectedWoreda,
      addressKebele: _selectedKebele,
      addressId: _addressId,
    ));
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
          SizedBox(height: 8),
          Row(
            children: [
              _radioCard(l10n.listingHouse, Icons.home_rounded, 'house'),
              SizedBox(width: 12),
              _radioCard(l10n.listingLand, Icons.landscape_rounded, 'land'),
            ],
          ),
          SizedBox(height: 20),

          _sectionTitle(l10n.listingHoldingType),
          SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.holdingType.isEmpty
                ? null
                : widget.formData.holdingType,
            items: [
              l10n.listingFreeHold,
              l10n.listingLeaseHold,
              l10n.listingCooperative
            ],
            label: l10n.listingSelectHolding,
            onChanged: (v) => widget.onUpdate(widget.formData
                .copyWith(holdingType: v ?? l10n.listingFreeHold)),
          ),
          SizedBox(height: 16),

          // Conditional Holding Details
          if (widget.formData.holdingType == l10n.listingFreeHold)
            _buildFreeHoldFields(),
          if (widget.formData.holdingType == l10n.listingLeaseHold)
            _buildLeaseHoldFields(),
          if (widget.formData.holdingType == l10n.listingCooperative)
            _buildCooperativeFields(),

          SizedBox(height: 20),
          _sectionTitle(l10n.listingUseType),
          SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.useType.isEmpty
                ? null
                : widget.formData.useType,
            items: [
              l10n.listingResidential,
              l10n.listingCommercial,
              l10n.listingMixed,
              l10n.listingInvestment
            ],
            label: l10n.listingSelectUse,
            onChanged: (v) => widget.onUpdate(widget.formData
                .copyWith(useType: v ?? l10n.listingResidential)),
          ),
          SizedBox(height: 20),

          _sectionTitle(l10n.listingLocation),
          SizedBox(height: 8),
          _buildAddressDropdowns(),
          SizedBox(height: 20),

          _sectionTitle(l10n.listingPriceEtb),
          SizedBox(height: 8),
          _buildPriceField(),
          SizedBox(height: 20),

          // Debt section
          CheckboxListTile(
            title: Text(l10n.listingHasDebt),
            value: widget.formData.hasDebtOrEncumbrance,
            onChanged: (v) => widget.onUpdate(
                widget.formData.copyWith(hasDebtOrEncumbrance: v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (widget.formData.hasDebtOrEncumbrance) ...[
            SizedBox(height: 8),
            _buildFormattedField(
              label: l10n.listingDebtAmount,
              controller: _debtAmountController,
              onSubmitted: (v) {
                final cleaned = v.replaceAll(',', '');
                widget.onUpdate(widget.formData
                    .copyWith(debtAmount: double.tryParse(cleaned)));
              },
            ),
          ],
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.titleSmall
            .copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _radioCard(String label, IconData icon, String value) {
    final isSelected = widget.formData.type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onUpdate(widget.formData.copyWith(type: value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navy950 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? AppColors.navy950 : AppColors.zinc300,
                width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : AppColors.navy600,
                  size: 20),
              SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.navy800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeHoldFields() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.navy50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.navy100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingFreeHoldDetails,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.navy700, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingTaxPaidYear,
            controller: _taxPaidUntilController,
            keyboardType: TextInputType.number,
            onSubmitted: (v) {
              final n = int.tryParse(v);
              if (n != null)
                widget.onUpdate(widget.formData.copyWith(taxPaidUntilYear: n));
            },
          ),
          SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.acquisitionClarification,
            items: [
              l10n.listingPurchased,
              l10n.listingInherited,
              l10n.listingGift,
              l10n.listingAssignment,
              l10n.listingOther
            ],
            label: l10n.listingAcquisition,
            onChanged: (v) => widget.onUpdate(
                widget.formData.copyWith(acquisitionClarification: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseHoldFields() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingLeaseHoldDetails,
              style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.purple.shade700, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingLeasedYear,
            controller: _leasedYearController,
            keyboardType: TextInputType.number,
            onSubmitted: (v) {
              final n = int.tryParse(v);
              if (n != null)
                widget.onUpdate(widget.formData.copyWith(leasedYear: n));
            },
          ),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingLeasePrice,
            controller: _leasePriceController,
            keyboardType: TextInputType.number,
            onSubmitted: (v) {
              final cleaned = v.replaceAll(',', '');
              final n = double.tryParse(cleaned);
              if (n != null)
                widget.onUpdate(widget.formData.copyWith(leasePricePerSqm: n));
            },
          ),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingBuildType,
            controller: _buildTypeController,
            keyboardType: TextInputType.text,
            onSubmitted: (v) =>
                widget.onUpdate(widget.formData.copyWith(buildType: v)),
          ),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingAnnualPayment,
            controller: _annualPaymentController,
            keyboardType: TextInputType.number,
            onSubmitted: (v) {
              final cleaned = v.replaceAll(',', '');
              final n = double.tryParse(cleaned);
              if (n != null)
                widget.onUpdate(widget.formData.copyWith(annualPayment: n));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCooperativeFields() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.wave50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.wave100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingCooperativeDetails,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.wave700, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingCooperativeName,
            controller: _cooperativeNameController,
            keyboardType: TextInputType.text,
            onSubmitted: (v) =>
                widget.onUpdate(widget.formData.copyWith(cooperativeName: v)),
          ),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingCooperativeCode,
            controller: _cooperativeCodeController,
            keyboardType: TextInputType.text,
            onSubmitted: (v) =>
                widget.onUpdate(widget.formData.copyWith(cooperativeCode: v)),
          ),
          SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.buildingStatus?.isEmpty ?? true
                ? null
                : widget.formData.buildingStatus,
            items: [l10n.listingFinished, l10n.listingUnfinished],
            label: l10n.listingBuildingStatus,
            onChanged: (v) =>
                widget.onUpdate(widget.formData.copyWith(buildingStatus: v)),
          ),
        ],
      ),
    );
  }

  /// Persistent text field that saves on submit OR focus loss
  Widget _buildPersistedField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    required void Function(String) onSubmitted,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        // Save value when focus is lost
        if (!hasFocus) {
          onSubmitted(controller.text);
        }
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: keyboardType,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }

  Widget _buildAddressDropdowns() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _dropdownField(
                    value: _selectedRegion,
                    items: _regions,
                    label: l10n.listingRegion,
                    onChanged: _onRegionSelected,
                    isLoading: false)),
            SizedBox(width: 8),
            Expanded(
                child: _dropdownField(
                    value: _selectedZone,
                    items: _zones,
                    label: l10n.listingZone,
                    onChanged: _onZoneSelected,
                    isLoading: _loadingZones)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _dropdownField(
                    value: _selectedWoreda,
                    items: _woredas,
                    label: l10n.listingWoreda,
                    onChanged: _onWoredaSelected,
                    isLoading: _loadingWoredas)),
            SizedBox(width: 8),
            Expanded(
                child: _dropdownField(
                    value: _selectedKebele,
                    items: _kebeles,
                    label: l10n.listingKebele,
                    onChanged: _onKebeleSelected,
                    isLoading: _loadingKebeles)),
          ],
        ),
        SizedBox(height: 8),
        _buildTextField(
          label: l10n.listingSpecificLocation,
          controller: _specificLocationController,
          onSubmitted: (v) =>
              widget.onUpdate(widget.formData.copyWith(specificLocation: v)),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    final price = widget.formData.priceFixed;
    Color borderColor = AppColors.zinc300;
    if (price != null) {
      if (price < 10000)
        borderColor = Colors.red;
      else if (price < 100000)
        borderColor = Colors.amber;
      else
        borderColor = AppColors.emerald500;
    }
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          final cleaned = _priceController.text.replaceAll(',', '');
          final parsed = double.tryParse(cleaned);
          if (parsed != null && parsed > 0) {
            widget.onUpdate(widget.formData.copyWith(priceFixed: parsed));
          }
        }
      },
      child: TextFormField(
        controller: _priceController,
        decoration: InputDecoration(
          labelText: 'Price',
          prefixIcon: Icon(Icons.attach_money, size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 2)),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onChanged: (v) {
          final cleaned = v.replaceAll(',', '');
          final parsed = double.tryParse(cleaned);
          if (parsed != null && parsed > 0) {
            widget.onUpdate(widget.formData.copyWith(priceFixed: parsed));
          }
        },
        onFieldSubmitted: (v) {
          final cleaned = v.replaceAll(',', '');
          final parsed = double.tryParse(cleaned);
          if (parsed != null && parsed > 0) {
            widget.onUpdate(widget.formData.copyWith(priceFixed: parsed));
          }
        },
      ),
    );
  }

  /// Formatted text field that saves on submit OR focus loss
  Widget _buildFormattedField({
    required String label,
    required TextEditingController controller,
    required void Function(String) onSubmitted,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onSubmitted(controller.text);
        }
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dropdownColor: Colors.white,
      items: items.isEmpty
          ? [
              const DropdownMenuItem(
                  value: null,
                  child: Text(l10n.listingNoOptions,
                      style: TextStyle(color: Colors.grey)))
            ]
          : items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14)),
                  ))
              .toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    void Function(String)? onSubmitted,
    TextInputType? keyboardType,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && onSubmitted != null && controller != null) {
          onSubmitted(controller.text);
        }
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: keyboardType ?? TextInputType.text,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}

// ===================== STEP 2: DETAILS =====================

class _Step2Details extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _Step2Details({required this.formData, required this.onUpdate});

  @override
  State<_Step2Details> createState() => _Step2DetailsState();
}

class _Step2DetailsState extends State<_Step2Details> {
  late TextEditingController _totalRoomsController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _kitchensController;
  late TextEditingController _salonsController;
  late TextEditingController _yearBuiltController;
  late TextEditingController _totalAreaController;
  late TextEditingController _frontAreaController;
  late TextEditingController _sideAreaController;

  @override
  void initState() {
    super.initState();
    _totalRoomsController = TextEditingController(
        text: widget.formData.totalRooms?.toString() ?? '');
    _bedroomsController =
        TextEditingController(text: widget.formData.bedrooms?.toString() ?? '');
    _bathroomsController = TextEditingController(
        text: widget.formData.bathrooms?.toString() ?? '');
    _kitchensController =
        TextEditingController(text: widget.formData.kitchens?.toString() ?? '');
    _salonsController =
        TextEditingController(text: widget.formData.salons?.toString() ?? '');
    _yearBuiltController = TextEditingController(
        text: widget.formData.yearBuilt?.toString() ?? '');
    _totalAreaController = TextEditingController(
        text: widget.formData.totalSquareMeters?.toStringAsFixed(0) ?? '');
    _frontAreaController = TextEditingController(
        text: widget.formData.frontAreaSqm?.toStringAsFixed(0) ?? '');
    _sideAreaController = TextEditingController(
        text: widget.formData.sideAreaSqm?.toStringAsFixed(0) ?? '');
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
          if (widget.formData.type == 'house') ...[
            _sectionTitle(l10n.listingRoomConfig),
            SizedBox(height: 8),
            _buildPersistedField(
              label: l10n.listingTotalRooms,
              controller: _totalRoomsController,
              keyboardType: TextInputType.number,
              onSubmitted: (v) {
                final n = int.tryParse(v);
                if (n != null)
                  widget.onUpdate(widget.formData.copyWith(totalRooms: n));
              },
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildPersistedField(
                  label: l10n.listingBedrooms,
                  controller: _bedroomsController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n != null)
                      widget.onUpdate(widget.formData.copyWith(bedrooms: n));
                  },
                )),
                SizedBox(width: 8),
                Expanded(
                    child: _buildPersistedField(
                  label: l10n.listingBathrooms,
                  controller: _bathroomsController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n != null)
                      widget.onUpdate(widget.formData.copyWith(bathrooms: n));
                  },
                )),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildPersistedField(
                  label: l10n.listingKitchens,
                  controller: _kitchensController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n != null)
                      widget.onUpdate(widget.formData.copyWith(kitchens: n));
                  },
                )),
                SizedBox(width: 8),
                Expanded(
                    child: _buildPersistedField(
                  label: l10n.listingSalons,
                  controller: _salonsController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n != null)
                      widget.onUpdate(widget.formData.copyWith(salons: n));
                  },
                )),
              ],
            ),
            SizedBox(height: 16),
            _sectionTitle(l10n.listingHouseType),
            SizedBox(height: 8),
            _dropdownField(
              value: widget.formData.houseType?.isEmpty ?? true
                  ? null
                  : widget.formData.houseType,
              items: [
                l10n.listingVilla,
                l10n.listingApartment,
                l10n.listingCondominium,
                l10n.listingTownhouse,
                l10n.listingBungalow
              ],
              label: l10n.listingSelectHouseType,
              onChanged: (v) =>
                  widget.onUpdate(widget.formData.copyWith(houseType: v)),
            ),
            SizedBox(height: 16),
            _sectionTitle(l10n.listingAmenities),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _amenityChip(
                    l10n.listingElectricity,
                    widget.formData.electricity,
                    (v) => widget
                        .onUpdate(widget.formData.copyWith(electricity: v))),
                _amenityChip(l10n.listingWater, widget.formData.water,
                    (v) => widget.onUpdate(widget.formData.copyWith(water: v))),
                _amenityChip(
                    l10n.listingParking,
                    widget.formData.parkingAvailable,
                    (v) => widget.onUpdate(
                        widget.formData.copyWith(parkingAvailable: v))),
              ],
            ),
            SizedBox(height: 16),
          ],
          _sectionTitle(l10n.listingAreaDimensions),
          SizedBox(height: 8),
          _buildPersistedField(
            label: l10n.listingTotalArea,
            controller: _totalAreaController,
            keyboardType: TextInputType.number,
            onSubmitted: (v) {
              final n = int.tryParse(v);
              if (n != null)
                widget.onUpdate(
                    widget.formData.copyWith(totalSquareMeters: n.toDouble()));
            },
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildPersistedField(
                label: l10n.listingFrontArea,
                controller: _frontAreaController,
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null)
                    widget.onUpdate(
                        widget.formData.copyWith(frontAreaSqm: n.toDouble()));
                },
              )),
              SizedBox(width: 8),
              Expanded(
                  child: _buildPersistedField(
                label: l10n.listingSideArea,
                controller: _sideAreaController,
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null)
                    widget.onUpdate(
                        widget.formData.copyWith(sideAreaSqm: n.toDouble()));
                },
              )),
            ],
          ),
          SizedBox(height: 16),
          _sectionTitle(l10n.listingFacingDirection),
          SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.facingDirection?.isEmpty ?? true
                ? null
                : widget.formData.facingDirection,
            items: [
              l10n.listingNorth,
              l10n.listingSouth,
              l10n.listingEast,
              l10n.listingWest,
              l10n.listingNorthEast,
              l10n.listingNorthWest,
              l10n.listingSouthEast,
              l10n.listingSouthWest
            ],
            label: l10n.listingSelectDirection,
            onChanged: (v) =>
                widget.onUpdate(widget.formData.copyWith(facingDirection: v)),
          ),
          SizedBox(height: 16),
          _sectionTitle(l10n.listingDescriptionLabel),
          SizedBox(height: 8),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                widget.onUpdate(widget.formData
                    .copyWith(description: widget.formData.description));
              }
            },
            child: TextFormField(
              initialValue: widget.formData.description,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.listingDescribeProperty,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (v) =>
                  widget.onUpdate(widget.formData.copyWith(description: v)),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.titleSmall
            .copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  /// Persistent text field that saves on submit OR focus loss
  Widget _buildPersistedField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    required void Function(String) onSubmitted,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        // Save value when focus is lost
        if (!hasFocus) {
          onSubmitted(controller.text);
        }
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: keyboardType,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }

  Widget _dropdownField(
      {required String? value,
      required List<String> items,
      required String label,
      required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dropdownColor: Colors.white,
      items: items.isEmpty
          ? [
              const DropdownMenuItem(
                  value: null,
                  child: Text(l10n.listingSelect,                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.normal)))
            ]
          : items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14)),
                  ))
              .toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
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

// ===================== STEP 3: MEDIA =====================

class _Step3Media extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _Step3Media({required this.formData, required this.onUpdate});

  @override
  State<_Step3Media> createState() => _Step3MediaState();
}

class _Step3MediaState extends State<_Step3Media> {
  final _picker = ImagePicker();

  Future<void> _pickImages(bool isSitePlan) async {
    final files =
        await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1920);
    if (files.isNotEmpty) {
      if (isSitePlan) {
        widget.onUpdate(widget.formData
            .copyWith(sitePlans: [...widget.formData.sitePlans, ...files]));
      } else {
        widget.onUpdate(widget.formData
            .copyWith(images: [...widget.formData.images, ...files]));
      }
    }
  }

  Future<void> _pickSingleFile(String type) async {
    final file = await _picker.pickImage(
        imageQuality: 85, maxWidth: 1920, source: ImageSource.gallery);
    if (file != null) {
      switch (type) {
        case 'ownership':
          widget.onUpdate(widget.formData.copyWith(ownershipProof: file));
          break;
        case 'lease':
          widget.onUpdate(widget.formData.copyWith(leaseContract: file));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.listingImages),
          SizedBox(height: 8),
          _buildImageGrid(widget.formData.images, 'images'),
          SizedBox(height: 16),
          _sectionTitle(l10n.listingSitePlans),
          SizedBox(height: 8),
          _buildFileList(widget.formData.sitePlans.map((f) => f.path).toList(),
              isSitePlan: true),
          SizedBox(height: 16),
          if (widget.formData.holdingType == l10n.listingCooperative) ...[
            _sectionTitle(l10n.listingOwnershipProof),
            SizedBox(height: 8),
            _buildSingleFilePicker('ownership', widget.formData.ownershipProof),
            SizedBox(height: 16),
          ],
          if (widget.formData.holdingType == l10n.listingLeaseHold) ...[
            _sectionTitle(l10n.listingLeaseContract),
            SizedBox(height: 8),
            _buildSingleFilePicker('lease', widget.formData.leaseContract),
            SizedBox(height: 16),
          ],
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.titleSmall
            .copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _buildImageGrid(List<XFile> files, String type) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImages(type == 'site_plans'),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.zinc300, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.add_photo_alternate,
                      size: 32, color: AppColors.navy400),
                  SizedBox(height: 8),
                  Text(l10n.listingTapToAdd,
                      style: TextStyle(color: AppColors.navy400)),
                ])),
          ),
        ),
        if (files.isNotEmpty) ...[
          SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(files[i].path),
                          width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            final newFiles = List<XFile>.from(files)
                              ..removeAt(i);
                            widget.onUpdate(type == 'images'
                                ? widget.formData.copyWith(images: newFiles)
                                : widget.formData
                                    .copyWith(sitePlans: newFiles));
                          },
                          child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: Icon(Icons.close,
                                  size: 12, color: Colors.white)),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Text(l10n.listingImagesSelected(files.length),
              style: AppTextStyles.caption.copyWith(color: AppColors.zinc500)),
        ],
      ],
    );
  }

  Widget _buildFileList(List<String> files, {bool isSitePlan = false}) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImages(isSitePlan),
          icon: Icon(Icons.upload_file),
          label: Text(l10n.listingBrowseFiles),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy950),
        ),
        if (files.isNotEmpty) ...[
          SizedBox(height: 8),
          ...files.map((f) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(f.split('/').last, style: AppTextStyles.caption))),
        ],
      ],
    );
  }

  Widget _buildSingleFilePicker(String type, XFile? file) {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton.icon(
      onPressed: () => _pickSingleFile(type),
      icon: Icon(Icons.upload_file),
      label: Text(file != null
          ? l10n.listingChangeFile(file.name.split('/').last)
          : l10n.listingBrowseFile),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy950),
    );
  }
}

// ===================== STEP 4: REVIEW =====================

class _Step4Review extends StatelessWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _Step4Review({required this.formData, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l10n.listingSummary),
          SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _summaryCard(l10n.listingSummaryProperty,
                  '${formData.type == 'house' ? '🏠 ${l10n.listingHouse}' : '🌄 ${l10n.listingLand}'}\n${formData.houseType ?? ''}'),
              _summaryCard(l10n.listingLocation,
                  '${formData.addressRegion ?? ''}\n${formData.addressZone ?? ''}'),
              _summaryCard(l10n.listingFinancial,
                  '${formData.priceFixed != null ? "${_formatPrice(formData.priceFixed!)} ETB" : l10n.listingPriceOnRequest}\n${formData.holdingType}'),
              _summaryCard(l10n.listingStepMedia,
                  '${formData.images.length} ${l10n.listingImagesSelected(formData.images.length)}\n${formData.sitePlans.length} ${l10n.listingSitePlans}'),
            ],
          ),
          SizedBox(height: 16),
          if (formData.description != null) ...[
            _sectionTitle(l10n.listingDescriptionLabel),
            SizedBox(height: 4),
            Text(formData.description!,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 16),
          ],
          CheckboxListTile(
            title: Text(l10n.listingAcceptTerms),
            subtitle: Text(l10n.listingTermsSubtitle),
            value: formData.termsAccepted,
            onChanged: (v) =>
                onUpdate(formData.copyWith(termsAccepted: v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.titleSmall
            .copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _summaryCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.navy50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.navy100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.navy500)),
          SizedBox(height: 4),
          Expanded(
              child: Text(content,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
