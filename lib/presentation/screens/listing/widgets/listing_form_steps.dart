import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/address_service.dart';
import '../../../../data/services/listing_media_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../providers/app_providers.dart';
import '../../../../core/constants/app_spacing.dart';

// ===================== STEP INDICATOR =====================

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
            valueColor: AlwaysStoppedAnimation<Color>(context.isDarkMode ? AppColors.accent400 : AppColors.navy950),
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

// ===================== STEP 1: BASICS =====================

class ListingStep1Basics extends ConsumerStatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final AddressService addressService;
  final bool isEditMode;
  final List<String> stepErrors;
  const ListingStep1Basics(
      {super.key,
      required this.formData,
      required this.onUpdate,
      required this.addressService,
      this.isEditMode = false,
      this.stepErrors = const []});
  @override
  ConsumerState<ListingStep1Basics> createState() => _ListingStep1BasicsState();
}

class _ListingStep1BasicsState extends ConsumerState<ListingStep1Basics> {
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
  final Map<String, int?> _kebeleIds = {};
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
    
    _selectedRegion = widget.formData.addressRegion;
    _selectedZone = widget.formData.addressZone;
    _selectedWoreda = widget.formData.addressWoreda;
    _selectedKebele = widget.formData.addressKebele;
    _addressId = widget.formData.addressId;

    _loadRegions().then((_) {
      if (_selectedRegion != null) _loadZones();
      if (_selectedZone != null) _loadWoredas();
      if (_selectedWoreda != null) _loadKebeles();
    });
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
        final regions = response.regions
            .map((r) => r.region)
            .where((s) => s != null && s.isNotEmpty)
            .cast<String>()
            .toList();
        setState(() => _regions = regions);
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
        _selectedWoreda == null) {
      return;
    }
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
        final kebeles = response.kebeles
            .map((k) => k.kebele)
            .where((s) => s != null && s.isNotEmpty)
            .cast<String>()
            .toList();
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
      _addressId = kebele != null ? _kebeleIds[kebele] : null;
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
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            title: l10n.listingPropertyType,
            child: Row(
              children: [
                _radioCard(
                  label: l10n.listingHouse,
                  icon: Icons.home_rounded,
                  value: 'house',
                  groupValue: widget.formData.type,
                  onChanged: widget.isEditMode
                      ? null
                      : (v) => widget.onUpdate(widget.formData.copyWith(type: v)),
                ),
                const SizedBox(width: 12),
                _radioCard(
                  label: l10n.listingLand,
                  icon: Icons.landscape_rounded,
                  value: 'land',
                  groupValue: widget.formData.type,
                  onChanged: widget.isEditMode
                      ? null
                      : (v) => widget.onUpdate(widget.formData.copyWith(type: v)),
                ),
              ],
            ),
          ),

          _sectionCard(
            title: l10n.listingListingType,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _radioCard(
                      label: l10n.listingForSale,
                      icon: Icons.sell_rounded,
                      value: 'sale',
                      groupValue: widget.formData.listingType,
                      onChanged: widget.isEditMode
                          ? null
                          : (v) => widget.onUpdate(widget.formData.copyWith(listingType: v)),
                    ),
                    const SizedBox(width: 12),
                    _radioCard(
                      label: l10n.listingForRent,
                      icon: Icons.key_rounded,
                      value: 'rental',
                      groupValue: widget.formData.listingType,
                      onChanged: widget.isEditMode
                          ? null
                          : (v) => widget.onUpdate(widget.formData.copyWith(listingType: v)),
                    ),
                  ],
                ),
                if (widget.formData.listingType == 'rental') ...[
                  const SizedBox(height: 12),
                  _compactDropdown(
                    value: widget.formData.rentalPeriodUnit,
                    items: {
                      'day': 'Day',
                      'week': 'Week',
                      'month': 'Month',
                      'year': 'Year',
                    },
                    label: l10n.listingRentalPeriod,
                    hintText: l10n.listingSelect,
                    onChanged: (v) => widget.onUpdate(
                        widget.formData.copyWith(rentalPeriodUnit: v)),
                  ),
                ],
              ],
            ),
          ),

          _sectionCard(
            title: l10n.listingHoldingType,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _compactDropdown(
                  value: widget.formData.holdingType,
                  items: {
                    'Free Hold': l10n.listingFreeHold,
                    'Lease Hold': l10n.listingLeaseHold,
                    'Cooperative': l10n.listingCooperative,
                  },
                  label: l10n.listingHoldingType,
                  hintText: l10n.listingSelectHolding,
                  onChanged: (v) => widget.onUpdate(widget.formData
                      .copyWith(holdingType: v ?? 'Free Hold')),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      if (widget.formData.holdingType == 'Free Hold')
                        _buildFreeHoldFields(),
                      if (widget.formData.holdingType == 'Lease Hold')
                        _buildLeaseHoldFields(),
                      if (widget.formData.holdingType == 'Cooperative')
                        _buildCooperativeFields(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _sectionCard(
            title: l10n.listingUseType,
            child: _compactDropdown(
              value: widget.formData.useType,
              items: {
                'Residential': l10n.listingResidential,
                'Commercial': l10n.listingCommercial,
                'Mixed': l10n.listingMixed,
                'Investment': l10n.listingInvestment,
              },
              label: l10n.listingUseType,
              hintText: l10n.listingSelectUse,
              onChanged: (v) => widget.onUpdate(widget.formData
                  .copyWith(useType: v ?? 'Residential')),
            ),
          ),

          _sectionCard(
            title: l10n.listingLocation,
            child: _buildAddressDropdowns(),
          ),

          _sectionCard(
            title: l10n.listingPriceEtb,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompactPriceField(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: widget.formData.hasDebtOrEncumbrance,
                        onChanged: (v) => widget.onUpdate(
                            widget.formData.copyWith(
                              hasDebtOrEncumbrance: v ?? false,
                              debtAmount: (v ?? false) ? widget.formData.debtAmount : null,
                            )),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => widget.onUpdate(
                          widget.formData.copyWith(
                            hasDebtOrEncumbrance: !widget.formData.hasDebtOrEncumbrance,
                            debtAmount: !widget.formData.hasDebtOrEncumbrance ? widget.formData.debtAmount : null,
                          )),
                      child: Text(l10n.listingHasDebt, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: context.theme.textSecondary, letterSpacing: 0.3)),
                    ),
                  ],
                ),
                if (widget.formData.hasDebtOrEncumbrance) ...[
                  const SizedBox(height: 8),
                  _compactTextField(
                    label: l10n.listingDebtAmount,
                    controller: _debtAmountController,
                    onSubmitted: (v) {
                      final cleaned = v.replaceAll(',', '');
                      widget.onUpdate(widget.formData
                          .copyWith(debtAmount: double.tryParse(cleaned)));
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, String? subtitle, required Widget child}) {
    return WaveCard(
      isGlass: true,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: context.theme.textSecondary,
            letterSpacing: 0.3,
          )),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _compactDropdown({
    required String? value,
    required Map<String, String> items,
    required String label,
    required String hintText,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.containsKey(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: AppTextStyles.bodySmall,
      ),
      dropdownColor: context.sheetBg,
      items: items.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value,
                    style: AppTextStyles.bodySmall),
              ))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _compactTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    required void Function(String) onSubmitted,
  }) {
    // FIX: read-only fill must be visible in both themes.
    // Light: stone100 (#F1F5F9) on white bg — clearly different.
    // Dark:  primary700 (#1E293B) on primary800 (#0F172A) bg — clearly different.
    final readOnlyFill = context.isDarkMode ? AppColors.primary700 : AppColors.stone100;
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        filled: readOnly,
        fillColor: readOnly ? readOnlyFill : null,
      ),
      keyboardType: keyboardType,
      onChanged: (v) => onSubmitted(v),
    );
  }

  Widget _buildCompactPriceField() {
    final l10n = AppLocalizations.of(context);
    final price = widget.formData.priceFixed;
    Color borderColor = context.theme.divider;
    if (price != null) {
      if (price < 10000) {
        borderColor = AppColors.error;
      } else if (price < 100000) {
        borderColor = AppColors.warning;
      } else {
        borderColor = AppColors.emerald500;
      }
    }
    return TextFormField(
      controller: _priceController,
      style: AppTextStyles.bodySmall,
      decoration: InputDecoration(
        labelText: l10n.listingPriceEtb,
        labelStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        prefixIcon: const Icon(Icons.attach_money, size: 18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
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
    );
  }

  Widget _radioCard({
    required String label,
    required IconData icon,
    required String value,
    required String groupValue,
    required Function(String)? onChanged,
  }) {
    final isSelected = groupValue == value;
    final isEnabled = onChanged != null;
    final bgColor = isSelected
        ? (context.isDarkMode ? AppColors.accent500 : AppColors.navy950)
        : context.cardBg;

    return Expanded(
      child: InkWell(
        onTap: isEnabled ? () => onChanged(value) : null,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: isEnabled ? 1.0 : 0.6),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: isSelected
                    ? (context.isDarkMode ? AppColors.accent500 : AppColors.navy950)
                    : context.divider,
                width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : context.theme.textSecondary,
                  size: 18),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.primary800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeHoldFields() {
    final l10n = AppLocalizations.of(context);
    return WaveCard(
      isGlass: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingFreeHoldDetails,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _compactTextField(
                      label: l10n.listingTaxPaidYear,
                      controller: _taxPaidUntilController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          widget.onUpdate(widget.formData.copyWith(taxPaidUntilYear: n));
                        }
                      },
                    ),
                    ListenableBuilder(
                      listenable: _taxPaidUntilController,
                      builder: (context, _) {
                        final year = int.tryParse(_taxPaidUntilController.text);
                        if (year == null || year < 1900) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 2, left: 4),
                          child: Text(
                            '${year - 8} ዓ/ም',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                              color: AppColors.accent600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _compactDropdown(
                  value: widget.formData.acquisitionClarification,
                  items: {
                    'Purchased': l10n.listingPurchased,
                    'Inherited': l10n.listingInherited,
                    'Gift': l10n.listingGift,
                    'Assignment': l10n.listingAssignment,
                    'Other': l10n.listingOther,
                  },
                  label: l10n.listingAcquisition,
                  hintText: l10n.listingSelect,
                  onChanged: (v) => widget.onUpdate(
                      widget.formData.copyWith(acquisitionClarification: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseHoldFields() {
    final l10n = AppLocalizations.of(context);
    return WaveCard(
      isGlass: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingLeaseHoldDetails,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _compactTextField(
                      label: l10n.listingLeasedYear,
                      controller: _leasedYearController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          widget.onUpdate(widget.formData.copyWith(leasedYear: n));
                        }
                      },
                    ),
                    ListenableBuilder(
                      listenable: _leasedYearController,
                      builder: (context, _) {
                        final year = int.tryParse(_leasedYearController.text);
                        if (year == null || year < 1900) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 2, left: 4),
                          child: Text(
                            '${year - 8} ዓ/ም',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                              color: AppColors.accent600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _compactTextField(
                  label: l10n.listingLeasePrice,
                  controller: _leasePriceController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final cleaned = v.replaceAll(',', '');
                    final n = double.tryParse(cleaned);
                    if (n != null) {
                      widget.onUpdate(widget.formData.copyWith(leasePricePerSqm: n));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _compactTextField(
                  label: l10n.listingBuildType,
                  controller: _buildTypeController,
                  keyboardType: TextInputType.text,
                  onSubmitted: (v) => widget.onUpdate(widget.formData.copyWith(buildType: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _compactTextField(
                  label: l10n.listingAnnualPayment,
                  controller: _annualPaymentController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (v) {
                    final cleaned = v.replaceAll(',', '');
                    final n = double.tryParse(cleaned);
                    if (n != null) widget.onUpdate(widget.formData.copyWith(annualPayment: n));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCooperativeFields() {
    final l10n = AppLocalizations.of(context);
    return WaveCard(
      isGlass: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingCooperativeDetails,
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _compactTextField(
                  label: l10n.listingCooperativeName,
                  controller: _cooperativeNameController,
                  keyboardType: TextInputType.text,
                  onSubmitted: (v) =>
                      widget.onUpdate(widget.formData.copyWith(cooperativeName: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _compactTextField(
                  label: l10n.listingCooperativeCode,
                  controller: _cooperativeCodeController,
                  keyboardType: TextInputType.text,
                  onSubmitted: (v) =>
                      widget.onUpdate(widget.formData.copyWith(cooperativeCode: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _compactDropdown(
            value: widget.formData.buildingStatus,
            items: {
              'Finished': l10n.listingFinished,
              'Unfinished': l10n.listingUnfinished,
            },
            label: l10n.listingBuildingStatus,
            hintText: l10n.listingSelect,
            onChanged: (v) =>
                widget.onUpdate(widget.formData.copyWith(buildingStatus: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDropdowns() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _compactDropdownField(value: _selectedRegion, items: _regions, label: l10n.listingRegion, onChanged: _onRegionSelected, isLoading: false)),
            const SizedBox(width: 8),
            Expanded(child: _compactDropdownField(value: _selectedZone, items: _zones, label: l10n.listingZone, onChanged: _onZoneSelected, isLoading: _loadingZones)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _compactDropdownField(value: _selectedWoreda, items: _woredas, label: l10n.listingWoreda, onChanged: _onWoredaSelected, isLoading: _loadingWoredas)),
            const SizedBox(width: 8),
            Expanded(child: _compactDropdownField(value: _selectedKebele, items: _kebeles, label: l10n.listingKebele, onChanged: _onKebeleSelected, isLoading: _loadingKebeles)),
          ],
        ),
        const SizedBox(height: 8),
        _compactTextField(
          label: l10n.listingSpecificLocation,
          controller: _specificLocationController,
          onSubmitted: (v) => widget.onUpdate(widget.formData.copyWith(specificLocation: v)),
        ),
      ],
    );
  }

  Widget _compactDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        suffixIcon: isLoading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : null,
      ),
      dropdownColor: context.sheetBg,
      items: items.isEmpty
          ? [DropdownMenuItem(value: null, child: Text(l10n.listingNoOptions, style: AppTextStyles.bodySmall.copyWith(color: context.textMuted)))]
          : items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodySmall))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }
}

// ===================== STEP 2: DETAILS =====================

class ListingStep2Details extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final List<String> stepErrors;
  const ListingStep2Details({super.key, required this.formData, required this.onUpdate, this.stepErrors = const []});

  @override
  State<ListingStep2Details> createState() => _ListingStep2DetailsState();
}

class _ListingStep2DetailsState extends State<ListingStep2Details> {
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

  void _onHouseTypeChanged(String? v) {
    double? newArea = widget.formData.totalSquareMeters;
    if (v == 'cooperative_140') {
      newArea = 140;
    } else if (v == 'cooperative_84') {
      newArea = 84;
    } else if (v == 'cooperative_70') {
      newArea = 70;
    }

    if (newArea != widget.formData.totalSquareMeters) {
      _totalAreaController.text = newArea?.toStringAsFixed(0) ?? '';
    }

    widget.onUpdate(widget.formData.copyWith(
      houseType: v,
      totalSquareMeters: newArea,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCooperative = widget.formData.holdingType == 'Cooperative';

    final Map<String, String> houseTypeItems = isCooperative
        ? {
            'cooperative_140': 'Cooperative (140m²)',
            'cooperative_84': 'Cooperative (84m²)',
            'cooperative_70': 'Cooperative (70m²)',
            'market_place': 'Market Place',
          }
        : {
            'villa': l10n.listingVilla,
            'apartment': l10n.listingApartment,
            'condominium': l10n.listingCondominium,
            'townhouse': l10n.listingTownhouse,
            'bungalow': l10n.listingBungalow,
          };

    final bool isAreaReadOnly = isCooperative &&
        widget.formData.houseType != null &&
        widget.formData.houseType != 'market_place';

    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.formData.type == 'house')
            _sectionCard(
              title: l10n.listingRoomConfig,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _compactTextField(label: l10n.listingTotalRooms, controller: _totalRoomsController, keyboardType: TextInputType.number, onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) widget.onUpdate(widget.formData.copyWith(totalRooms: n));
                      })),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _compactTextField(label: l10n.listingBedrooms, controller: _bedroomsController, keyboardType: TextInputType.number, onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) widget.onUpdate(widget.formData.copyWith(bedrooms: n));
                      })),
                      const SizedBox(width: 8),
                      Expanded(child: _compactTextField(label: l10n.listingBathrooms, controller: _bathroomsController, keyboardType: TextInputType.number, onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) widget.onUpdate(widget.formData.copyWith(bathrooms: n));
                      })),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _compactTextField(label: l10n.listingKitchens, controller: _kitchensController, keyboardType: TextInputType.number, onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) widget.onUpdate(widget.formData.copyWith(kitchens: n));
                      })),
                      const SizedBox(width: 8),
                      Expanded(child: _compactTextField(label: l10n.listingSalons, controller: _salonsController, keyboardType: TextInputType.number, onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) widget.onUpdate(widget.formData.copyWith(salons: n));
                      })),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _compactDropdown(
                    value: widget.formData.houseType,
                    items: houseTypeItems,
                    label: l10n.listingHouseType,
                    hintText: l10n.listingSelectHouseType,
                    onChanged: _onHouseTypeChanged,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _compactTextField(label: l10n.listingYearBuilt, controller: _yearBuiltController, keyboardType: TextInputType.number, onSubmitted: (v) {
                        final n = int.tryParse(v);
                        if (n != null) widget.onUpdate(widget.formData.copyWith(yearBuilt: n));
                      }),
                      ListenableBuilder(
                        listenable: _yearBuiltController,
                        builder: (context, _) {
                          final year = int.tryParse(_yearBuiltController.text);
                          if (year == null || year < 1900) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 2, left: 4),
                            child: Text(
                              '${year - 8} ዓ/ም',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 9,
                                color: AppColors.accent600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.listingAmenities,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: context.theme.textSecondary, letterSpacing: 0.3)),
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
                ],
              ),
            ),

          _sectionCard(
            title: l10n.listingAreaDimensions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _compactTextField(
                  label: l10n.listingTotalArea,
                  controller: _totalAreaController,
                  keyboardType: TextInputType.number,
                  readOnly: isAreaReadOnly,
                  onSubmitted: (v) {
                    final n = int.tryParse(v);
                    if (n != null) widget.onUpdate(widget.formData.copyWith(totalSquareMeters: n.toDouble()));
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _compactTextField(label: l10n.listingFrontArea, controller: _frontAreaController, keyboardType: TextInputType.number, onSubmitted: (v) {
                      final n = int.tryParse(v);
                      if (n != null) widget.onUpdate(widget.formData.copyWith(frontAreaSqm: n.toDouble()));
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: _compactTextField(label: l10n.listingSideArea, controller: _sideAreaController, keyboardType: TextInputType.number, onSubmitted: (v) {
                      final n = int.tryParse(v);
                      if (n != null) widget.onUpdate(widget.formData.copyWith(sideAreaSqm: n.toDouble()));
                    })),
                  ],
                ),
                const SizedBox(height: 12),
                _compactDropdown(
                  value: widget.formData.facingDirection,
                  items: {
                    'north': l10n.listingNorth,
                    'south': l10n.listingSouth,
                    'east': l10n.listingEast,
                    'west': l10n.listingWest,
                    'north_east': l10n.listingNorthEast,
                    'north_west': l10n.listingNorthWest,
                    'south_east': l10n.listingSouthEast,
                    'south_west': l10n.listingSouthWest,
                    'facing_3_directions': l10n.listingFacing3Directions,
                    'facing_all_directions': l10n.listingFacingAllDirections,
                  },
                  label: l10n.listingFacingDirection,
                  hintText: l10n.listingSelectDirection,
                  onChanged: (v) => widget.onUpdate(widget.formData.copyWith(facingDirection: v)),
                ),
              ],
            ),
          ),

          _sectionCard(
            title: l10n.listingDescriptionLabel,
            child: TextFormField(
              initialValue: widget.formData.description,
              maxLines: 3,
              style: AppTextStyles.bodySmall,
              decoration: InputDecoration(
                labelText: l10n.listingDescriptionLabel,
                labelStyle: AppTextStyles.bodySmall,
                hintText: l10n.listingDescribeProperty,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              onChanged: (v) => widget.onUpdate(widget.formData.copyWith(description: v)),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, String? subtitle, required Widget child}) {
    return WaveCard(
      isGlass: true,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: context.theme.textSecondary,
            letterSpacing: 0.3,
          )),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _compactTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    required void Function(String) onSubmitted,
  }) {
    final readOnlyFill = context.isDarkMode ? AppColors.primary700 : AppColors.stone100;
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) onSubmitted(controller.text);
      },
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          filled: readOnly,
          fillColor: readOnly ? readOnlyFill : null,
        ),
        keyboardType: keyboardType,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }

  Widget _compactDropdown({
    required String? value,
    required Map<String, String> items,
    required String label,
    required String hintText,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.containsKey(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dropdownColor: context.sheetBg,
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: AppTextStyles.bodySmall)))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _amenityChip(String label, bool isSelected, Function(bool) onChanged) {
    final isDark = context.isDarkMode;
    return FilterChip(
      label: Text(label, style: AppTextStyles.labelMedium.copyWith(
        color: isSelected
            ? AppColors.accent700
            : context.theme.textPrimary,
      )),
      selected: isSelected,
      onSelected: onChanged,
      backgroundColor: isDark ? AppColors.primary700 : AppColors.stone100,
      selectedColor: isDark ? AppColors.accent900 : AppColors.accent100,
      checkmarkColor: AppColors.accent600,
      side: BorderSide(
        color: isSelected
            ? AppColors.accent400
            : (isDark ? AppColors.primary600 : AppColors.stone200),
      ),
    );
  }
}

// ===================== STEP 3: MEDIA =====================

class ListingStep3Media extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final List<String> stepErrors;
  const ListingStep3Media({super.key, required this.formData, required this.onUpdate, this.stepErrors = const []});

  @override
  State<ListingStep3Media> createState() => _ListingStep3MediaState();
}

class _ListingStep3MediaState extends State<ListingStep3Media> {
  final _picker = ImagePicker();

  Future<void> _pickImages(bool isSitePlan) async {
    if (isSitePlan) {
      final file = await _picker.pickImage(
          imageQuality: 85, maxWidth: 1920, source: ImageSource.gallery);
      if (file != null) {
        final persisted = await ListingMediaManager.persistFile(file);
        widget.onUpdate(widget.formData.copyWith(sitePlan: persisted));
      }
    } else {
      final files =
          await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1920);
      if (files.isNotEmpty) {
        final persisted = await ListingMediaManager.persistFiles(files);
        widget.onUpdate(widget.formData
            .copyWith(images: [...widget.formData.images, ...persisted]));
      }
    }
  }

  Future<void> _pickSingleFile(String type) async {
    final XFile? file;
    if (type == 'video') {
      file = await _picker.pickVideo(
          source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
    } else {
      file = await _picker.pickImage(
          imageQuality: 85, maxWidth: 1920, source: ImageSource.gallery);
    }

    if (file != null) {
      final persisted = await ListingMediaManager.persistFile(file);
      switch (type) {
        case 'sitePlan':
          widget.onUpdate(widget.formData.copyWith(sitePlan: persisted));
          break;
        case 'ownership':
          widget.onUpdate(widget.formData.copyWith(ownershipProof: persisted));
          break;
        case 'lease':
          widget.onUpdate(widget.formData.copyWith(leaseContract: persisted));
          break;
        case 'video':
          widget.onUpdate(widget.formData.copyWith(videoFile: persisted));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          _buildImagesSection(),
          const SizedBox(height: 16),
          _buildSitePlanSection(),
          const SizedBox(height: 16),
          if (widget.formData.holdingType == 'Cooperative')
            _buildOwnershipSection(),
          if (widget.formData.holdingType == 'Cooperative')
            const SizedBox(height: 16),
          if (widget.formData.holdingType == 'Lease Hold')
            _buildLeaseSection(),
          if (widget.formData.holdingType == 'Lease Hold')
            const SizedBox(height: 16),
          _buildVideoSection(),
        ],
      ),
    );
  }

  Widget _mediaSection({required String title, required Widget child}) {
    return WaveCard(
      isGlass: false,
      showShadow: false,
      showBorder: true,
      borderRadius: AppSpacing.borderRadiusMd,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.theme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _uploadZone({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.inputBorder, width: 1.5),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          color: context.theme.inputBg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: context.theme.iconSecondary),
            const SizedBox(height: 10),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filePreviewCard({
    required String fileName,
    required String? subtitle,
    required IconData icon,
    required Widget? thumbnail,
    required VoidCallback onRemove,
    required VoidCallback onPreview,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.border),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        color: context.theme.cardBg,
      ),
      child: Row(
        children: [
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 64,
                height: 64,
                child: thumbnail,
              ),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.theme.iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 28, color: context.theme.iconSecondary),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
                ],
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onPreview,
                  child: Text('Tap to preview', style: AppTextStyles.caption.copyWith(color: context.theme.primary, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, {String? url, File? file}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: url != null
                  ? Image.network(url, fit: BoxFit.contain)
                  : Image.file(file!, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 24, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context, String filePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VideoPlayerScreen(filePath: filePath),
      ),
    );
  }

  // ---- Images ----
  Widget _buildImagesSection() {
    final l10n = AppLocalizations.of(context);
    final newImages = widget.formData.images;
    final existingImages = widget.formData.existingImages;
    final totalCount = existingImages.length -
        widget.formData.removedImageIds.length +
        newImages.length;

    return _mediaSection(
      title: l10n.listingImages,
      child: Column(
        children: [
          _uploadZone(
            icon: Icons.add_photo_alternate_outlined,
            label: l10n.listingTapToAdd,
            subtitle: 'JPEG, PNG, WebP',
            onTap: () => _pickImages(false),
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...existingImages
                      .where((img) =>
                          !widget.formData.removedImageIds.contains(img.id))
                      .map((img) => _ImageThumb(
                            url: img.imageUrl,
                            onRemove: () {
                              final removedIds =
                                  List<int>.from(widget.formData.removedImageIds)
                                    ..add(img.id);
                              widget.onUpdate(widget.formData
                                  .copyWith(removedImageIds: removedIds));
                            },
                          )),
                  ...newImages.map((file) => _ImageThumb(
                        file: File(file.path),
                        onRemove: () {
                          final updated = List<XFile>.from(newImages)
                            ..remove(file);
                          widget.onUpdate(widget.formData
                              .copyWith(images: updated));
                        },
                      )),
                  GestureDetector(
                    onTap: () => _pickImages(false),
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: context.theme.inputBorder, width: 1.5),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.borderRadiusMd),
                        color: context.theme.inputBg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,
                              size: 28, color: context.theme.iconSecondary),
                          const SizedBox(height: 4),
                          Text('Add',
                              style: AppTextStyles.caption
                                  .copyWith(color: context.theme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.listingImagesSelected(totalCount),
                style: AppTextStyles.caption
                    .copyWith(color: context.theme.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Site Plan ----
  Widget _buildSitePlanSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingSitePlanUrl != null &&
        widget.formData.sitePlan == null &&
        !widget.formData.removeExistingSitePlan;
    final pickedFile = widget.formData.sitePlan;

    return _mediaSection(
      title: l10n.listingSitePlans,
      child: Column(
        children: [
          if (hasExisting)
            _existingSitePlanCard(),
          if (pickedFile != null) ...[
            _filePreviewCard(
              fileName: pickedFile.name,
              subtitle: _formatFileSize(pickedFile.path),
              icon: Icons.image,
              thumbnail: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(File(pickedFile.path),
                    width: 64, height: 64, fit: BoxFit.cover),
              ),
              onRemove: () =>
                  widget.onUpdate(widget.formData.copyWith(sitePlan: null)),
              onPreview: () => _showImagePreview(context,
                  file: File(pickedFile.path)),
            ),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.map_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'Site plan image',
              onTap: () => _pickSingleFile('sitePlan'),
            )
          else
            _buildChangeButton('sitePlan', pickedFile),
        ],
      ),
    );
  }

  Widget _existingSitePlanCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _filePreviewCard(
        fileName: widget.formData.existingSitePlanUrl!.split('/').last,
        subtitle: 'Existing site plan',
        icon: Icons.image,
        thumbnail: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(widget.formData.existingSitePlanUrl!,
              width: 64, height: 64, fit: BoxFit.cover),
        ),
        onRemove: () => widget.onUpdate(
            widget.formData.copyWith(removeExistingSitePlan: true)),
        onPreview: () => _showImagePreview(context,
            url: widget.formData.existingSitePlanUrl),
      ),
    );
  }

  // ---- Ownership ----
  Widget _buildOwnershipSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingOwnershipProofUrl != null &&
        widget.formData.ownershipProof == null;
    final pickedFile = widget.formData.ownershipProof;

    return _mediaSection(
      title: l10n.listingOwnershipProof,
      child: Column(
        children: [
          if (hasExisting) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: context.theme.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 18, color: context.theme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.listingExistingFile(
                          widget.formData.existingOwnershipProofUrl!
                              .split('/')
                              .last),
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (pickedFile != null) ...[
            _filePreviewCard(
              fileName: pickedFile.name,
              subtitle: _formatFileSize(pickedFile.path),
              icon: Icons.image,
              thumbnail: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(File(pickedFile.path),
                    width: 64, height: 64, fit: BoxFit.cover),
              ),
              onRemove: () => widget.onUpdate(
                  widget.formData.copyWith(ownershipProof: null)),
              onPreview: () => _showImagePreview(context,
                  file: File(pickedFile.path)),
            ),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.verified_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'Ownership document',
              onTap: () => _pickSingleFile('ownership'),
            )
          else
            _buildChangeButton('ownership', pickedFile),
        ],
      ),
    );
  }

  // ---- Lease ----
  Widget _buildLeaseSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingLeaseContractUrl != null &&
        widget.formData.leaseContract == null;
    final pickedFile = widget.formData.leaseContract;

    return _mediaSection(
      title: l10n.listingLeaseContract,
      child: Column(
        children: [
          if (hasExisting) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: context.theme.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 18, color: context.theme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.listingExistingFile(
                          widget.formData.existingLeaseContractUrl!
                              .split('/')
                              .last),
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (pickedFile != null) ...[
            _filePreviewCard(
              fileName: pickedFile.name,
              subtitle: _formatFileSize(pickedFile.path),
              icon: Icons.image,
              thumbnail: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(File(pickedFile.path),
                    width: 64, height: 64, fit: BoxFit.cover),
              ),
              onRemove: () => widget.onUpdate(
                  widget.formData.copyWith(leaseContract: null)),
              onPreview: () => _showImagePreview(context,
                  file: File(pickedFile.path)),
            ),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.article_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'Lease contract',
              onTap: () => _pickSingleFile('lease'),
            )
          else
            _buildChangeButton('lease', pickedFile),
        ],
      ),
    );
  }

  // ---- Video ----
  Widget _buildVideoSection() {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.formData.existingVideoUrl != null &&
        widget.formData.videoFile == null &&
        !widget.formData.deleteVideo;
    final pickedFile = widget.formData.videoFile;

    return _mediaSection(
      title: l10n.listingsVideoTour,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.listingVideoMaxSize,
              style: AppTextStyles.caption
                  .copyWith(color: context.theme.textMuted)),
          const SizedBox(height: 8),
          if (hasExisting)
            _existingVideoCard(),
          if (pickedFile != null) ...[
            _videoPreviewCard(pickedFile),
            const SizedBox(height: 12),
          ],
          if (!hasExisting && pickedFile == null)
            _uploadZone(
              icon: Icons.videocam_outlined,
              label: l10n.listingTapToAdd,
              subtitle: 'MP4, max 5 minutes',
              onTap: () => _pickSingleFile('video'),
            )
          else
            _buildChangeButton('video', pickedFile),
        ],
      ),
    );
  }

  Widget _existingVideoCard() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.border),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          color: context.theme.cardBg,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.theme.iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.videocam,
                  size: 28, color: context.theme.iconSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.listingExistingFile(
                        widget.formData.existingVideoUrl!.split('/').last),
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text('Existing video',
                      style: AppTextStyles.caption
                          .copyWith(color: context.theme.textMuted)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.onUpdate(
                  widget.formData.copyWith(deleteVideo: true)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, size: 16, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoPreviewCard(XFile file) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.border),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        color: context.theme.cardBg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.theme.iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.play_circle_fill,
                    size: 32, color: AppColors.primary900),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(_formatFileSize(file.path),
                        style: AppTextStyles.caption
                            .copyWith(color: context.theme.textMuted)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onUpdate(
                    widget.formData.copyWith(videoFile: null)),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _playVideo(context, file.path),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Play Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.theme.primary,
                side: BorderSide(color: context.theme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(String type, XFile? currentFile) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _pickSingleFile(type),
        icon: const Icon(Icons.swap_horiz, size: 18),
        label: Text(currentFile != null
            ? l10n.listingChangeFile(currentFile.name)
            : l10n.listingBrowseFile),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.theme.textSecondary,
          side: BorderSide(color: context.theme.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatFileSize(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) return '';
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }
}

class _ImageThumb extends StatelessWidget {
  final String? url;
  final File? file;
  final VoidCallback onRemove;

  const _ImageThumb({this.url, this.file, required this.onRemove});

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: url != null
                  ? Image.network(url!, fit: BoxFit.contain)
                  : Image.file(file!, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 24, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _showPreview(context),
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: url != null
                    ? Image.network(url!,
                        width: 100, height: 100, fit: BoxFit.cover)
                    : Image.file(file!,
                        width: 100, height: 100, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  const _VideoPlayerScreen({required this.filePath});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.file(File(widget.filePath));
    await _controller!.initialize();
    _controller!.play();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: _initialized
            ? GestureDetector(
                onTap: () {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                  setState(() {});
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    if (!_controller!.value.isPlaying)
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: const Icon(Icons.play_arrow,
                            size: 56, color: Colors.white),
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// ===================== STEP 4: REVIEW =====================

class ListingStep4Review extends StatelessWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final List<String> stepErrors;
  const ListingStep4Review({super.key, required this.formData, required this.onUpdate, this.stepErrors = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, l10n.listingSummary),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _summaryCard(context, l10n.listingSummaryProperty,
                      '${formData.type == 'house' ? l10n.listingHouse : l10n.listingLand}\n${_getLocalizedHouseType(formData.houseType, l10n)}',
                      icon: formData.type == 'house' ? Icons.home_rounded : Icons.landscape_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryCard(context, l10n.listingLocation,
                      '${[formData.addressKebele, formData.addressWoreda].where((e) => e != null && e.isNotEmpty).join(', ')}\n${[formData.addressZone, formData.addressRegion].where((e) => e != null && e.isNotEmpty).join(', ')}',
                      icon: Icons.location_on_rounded)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _summaryCard(context, l10n.listingFinancial,
                      '${formData.priceFixed != null ? "${_formatPrice(formData.priceFixed!)} ETB" : l10n.listingPriceOnRequest}\n${_getLocalizedHoldingType(formData.holdingType, l10n)}',
                      icon: Icons.account_balance_wallet_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryCard(context, l10n.listingStepMedia,
                      _buildMediaSummary(formData),
                      icon: Icons.photo_library_rounded)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (formData.description != null) ...[
            _sectionTitle(context, l10n.listingDescriptionLabel),
            const SizedBox(height: 4),
            Text(formData.description!,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: formData.isVip,
                  onChanged: (v) => onUpdate(formData.copyWith(isVip: v ?? false)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onUpdate(formData.copyWith(isVip: !formData.isVip)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.diamond, size: 16, color: AppColors.vip),
                          const SizedBox(width: 4),
                          Text('Mark as VIP', style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.vip,
                            letterSpacing: 0.3,
                          )),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Get a VIP badge for premium visibility', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: formData.termsAccepted,
                  onChanged: (v) => onUpdate(formData.copyWith(termsAccepted: v ?? false)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onUpdate(formData.copyWith(termsAccepted: !formData.termsAccepted)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.listingAcceptTerms, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: context.theme.textSecondary, letterSpacing: 0.3)),
                      const SizedBox(height: 2),
                      Text(l10n.listingTermsSubtitle, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // FIX: was titleSmall which uses the Cinzel heading font. Section titles
  // in a review card should use the body font (Montserrat) for readability.
  // FIX: StatelessWidget has no implicit `context`; accept it as parameter.
  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ));
  }

  Widget _summaryCard(BuildContext context, String title, String content, {IconData? icon}) {
    return WaveCard(
      isGlass: true,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.theme.textSecondary),
                const SizedBox(width: 6),
              ],
              Text(title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.theme.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
              child: Text(content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _buildMediaSummary(ListingFormData data) {
    final imageCount = data.images.length + data.existingImages.length - data.removedImageIds.length;
    final hasSitePlan = data.sitePlan != null || (data.existingSitePlanUrl != null && !data.removeExistingSitePlan);
    final hasOwnership = data.ownershipProof != null || data.existingOwnershipProofUrl != null;
    final hasLease = data.leaseContract != null || data.existingLeaseContractUrl != null;
    final hasVideo = data.videoFile != null || (data.existingVideoUrl != null && !data.deleteVideo);
    final lines = <String>[
      '$imageCount ${imageCount == 1 ? 'Picture' : 'Pictures'}',
      if (hasSitePlan) '1 Site Plan',
      if (hasOwnership) '1 Ownership Proof',
      if (hasLease) '1 Lease Contract',
      if (hasVideo) '1 Video',
    ];
    return lines.join('\n');
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  String _getLocalizedHouseType(String? type, AppLocalizations l10n) {
    if (type == null) return '';
    switch (type) {
      case 'villa': return l10n.listingVilla;
      case 'apartment': return l10n.listingApartment;
      case 'condominium': return l10n.listingCondominium;
      case 'townhouse': return l10n.listingTownhouse;
      case 'bungalow': return l10n.listingBungalow;
      default: return type;
    }
  }

  String _getLocalizedHoldingType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Free Hold': return l10n.listingFreeHold;
      case 'Lease Hold': return l10n.listingLeaseHold;
      case 'Cooperative': return l10n.listingCooperative;
      default: return type;
    }
  }
}
