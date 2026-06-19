import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/address_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../providers/app_providers.dart';
import '../../../../core/constants/app_spacing.dart';

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
    } catch (e) {
      debugPrint('Error: $e');
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
    } catch (e) {
      debugPrint('Error: $e');
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
    } catch (e) {
      debugPrint('Error: $e');
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
      useLiquidGlass: true,
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
        ? (context.isDarkMode ? AppColors.accent500 : AppColors.primary950)
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
                    ? (context.isDarkMode ? AppColors.accent500 : AppColors.primary950)
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
      useLiquidGlass: true,
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
      useLiquidGlass: true,
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
          const SizedBox(height: 12),
          _compactDropdown(
            value: widget.formData.isTransferable.toString(),
            items: {
              'true': l10n.listingTransferable,
              'false': l10n.listingNotTransferable,
            },
            label: l10n.listingIsTransferable,
            hintText: l10n.listingSelect,
            onChanged: (v) => widget.onUpdate(
                widget.formData.copyWith(isTransferable: v == 'true')),
          ),
        ],
      ),
    );
  }

  Widget _buildCooperativeFields() {
    final l10n = AppLocalizations.of(context);
    return WaveCard(
      useLiquidGlass: true,
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
