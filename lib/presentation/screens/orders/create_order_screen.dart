import '../../../core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/services/order_service.dart';
import '../../../data/services/address_service.dart';
import '../../../data/models/address.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_common_widgets.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  String _type = 'house';
  String _listingType = 'sale';
  String? _holdingType;
  String? _facingDirection;

  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();
  final _minAreaCtrl = TextEditingController();
  final _maxAreaCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Address picker
  final _addressService = AddressService();
  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [];
  List<Address> _kebeles = [];
  int? _kebeleId;
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;

  bool _formatting = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    _minAreaCtrl.dispose();
    _maxAreaCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String _formatNumber(String raw) {
    if (raw.isEmpty) return '';
    final n = int.tryParse(raw);
    if (n == null) return raw;
    return NumberFormat('#,###', 'en_US').format(n);
  }

  void _onNumberChanged(TextEditingController ctrl, String value) {
    if (_formatting) return;
    _formatting = true;
    final raw = value.replaceAll(',', '');
    final formatted = _formatNumber(raw);
    if (formatted != value) {
      ctrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    _formatting = false;
  }

  Future<void> _loadRegions() async {
    final response = await _addressService.getRegions();
    if (mounted && response.success) {
      setState(() {
        _regions = response.regions.map((a) => a.region ?? '').where((n) => n.isNotEmpty).toList();
      });
    }
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null;
      _selectedWoreda = null;
      _selectedKebele = null;
      _zones = [];
      _woredas = [];
      _kebeles = [];
    });
    if (region == null) return;
    setState(() => _loadingZones = true);
    final response = await _addressService.getZones(region: region);
    if (mounted) {
      setState(() {
        _loadingZones = false;
        if (response.success) {
          _zones = response.zones.map((a) => a.zone ?? '').where((n) => n.isNotEmpty).toList();
        }
      });
    }
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone;
      _selectedWoreda = null;
      _selectedKebele = null;
      _woredas = [];
      _kebeles = [];
    });
    if (zone == null || _selectedRegion == null) return;
    setState(() => _loadingWoredas = true);
    final response = await _addressService.getWoredas(region: _selectedRegion!, zone: zone);
    if (mounted) {
      setState(() {
        _loadingWoredas = false;
        if (response.success) {
          _woredas = response.woredas.map((a) => a.woreda ?? '').where((n) => n.isNotEmpty).toList();
        }
      });
    }
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda;
      _selectedKebele = null;
      _kebeles = [];
      _kebeleId = null;
    });
    if (woreda == null || _selectedRegion == null || _selectedZone == null) return;
    setState(() => _loadingKebeles = true);
    final response = await _addressService.getKebeles(
      region: _selectedRegion!,
      zone: _selectedZone!,
      woreda: woreda,
    );
    if (mounted) {
      setState(() {
        _loadingKebeles = false;
        if (response.success) {
          _kebeles = response.kebeles.where((a) => a.kebele != null && a.kebele!.isNotEmpty).toList();
        }
      });
    }
  }

  void _onKebeleSelected(String? kebele) {
    final match = _kebeles.where((a) => a.kebele == kebele).firstOrNull;
    setState(() {
      _selectedKebele = kebele;
      _kebeleId = match?.id;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final data = <String, dynamic>{
      'type': _type,
      'listing_type': _listingType,
      'description': _descriptionCtrl.text.trim(),
    };
    if (_holdingType != null) data['holding_type'] = _holdingType;
    if (_facingDirection != null) data['facing_direction'] = _facingDirection;
    if (_kebeleId != null) data['address_id'] = _kebeleId;
    if (_minBudgetCtrl.text.isNotEmpty) data['min_budget'] = _minBudgetCtrl.text.replaceAll(',', '');
    if (_maxBudgetCtrl.text.isNotEmpty) data['max_budget'] = _maxBudgetCtrl.text.replaceAll(',', '');
    if (_minAreaCtrl.text.isNotEmpty) data['min_area'] = _minAreaCtrl.text.replaceAll(',', '');
    if (_maxAreaCtrl.text.isNotEmpty) data['max_area'] = _maxAreaCtrl.text.replaceAll(',', '');

    final service = OrderService();
    final response = await service.createOrder(data);

    if (mounted) {
      setState(() => _submitting = false);
      if (response.success) {
        WaveToast.showSuccess(context, AppLocalizations.of(context).ordersCreated);
        Navigator.of(context).pop();
      } else {
        WaveToast.showError(context, response.message);
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: context.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.ordersCreate),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            _sectionCard(
              title: l10n.ordersTypeLabel,
              subtitle: 'Select the type of property',
              child: Row(
                children: [
                  _typeChip('house', l10n.ordersTypeHouse, Icons.home_outlined),
                  const SizedBox(width: 12),
                  _typeChip('land', l10n.ordersTypeLand, Icons.landscape_outlined),
                ],
              ),
            ),

            _sectionCard(
              title: l10n.ordersListingType,
              subtitle: 'Budget, area, and transaction type',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _listingTypeChip('sale', l10n.ordersBuy),
                      const SizedBox(width: 12),
                      _listingTypeChip('rental', l10n.ordersRent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.ordersBudget,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minBudgetCtrl,
                          style: AppTextStyles.bodySmall,
                          decoration: _inputDecoration(label: l10n.ordersMin),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_minBudgetCtrl, v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxBudgetCtrl,
                          style: AppTextStyles.bodySmall,
                          decoration: _inputDecoration(label: l10n.ordersMax),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_maxBudgetCtrl, v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.ordersArea,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minAreaCtrl,
                          style: AppTextStyles.bodySmall,
                          decoration: _inputDecoration(label: l10n.ordersMin),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_minAreaCtrl, v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAreaCtrl,
                          style: AppTextStyles.bodySmall,
                          decoration: _inputDecoration(label: l10n.ordersMax),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_maxAreaCtrl, v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: l10n.ordersHoldingType,
              subtitle: 'Holding type and facing direction',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _holdingType,
                    decoration: _inputDecoration(label: l10n.ordersSelect),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.ordersSelect, style: AppTextStyles.bodySmall)),
                      ...['Free Hold', 'Lease Hold', 'Cooperative'].map((v) =>
                          DropdownMenuItem(value: v, child: Text(v, style: AppTextStyles.bodySmall))),
                    ],
                    onChanged: (v) => setState(() => _holdingType = v),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.ordersFacing,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _facingDirection,
                    decoration: _inputDecoration(label: l10n.ordersSelect),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.ordersSelect, style: AppTextStyles.bodySmall)),
                      ...['north', 'south', 'east', 'west', 'north_east', 'north_west', 'south_east', 'south_west', 'facing_3_directions', 'Facing All Directions'].map((v) =>
                          DropdownMenuItem(value: v, child: Text(v.replaceAll('_', ' '), style: AppTextStyles.bodySmall))),
                    ],
                    onChanged: (v) => setState(() => _facingDirection = v),
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: 'Location',
              subtitle: 'Region, Zone, Woreda, and Kebele',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedRegion,
                          items: _regions,
                          label: 'Region',
                          onChanged: _onRegionSelected,
                          isLoading: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedZone,
                          items: _zones,
                          label: 'Zone',
                          onChanged: _onZoneSelected,
                          isLoading: _loadingZones,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedWoreda,
                          items: _woredas,
                          label: 'Woreda',
                          onChanged: _onWoredaSelected,
                          isLoading: _loadingWoredas,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedKebele,
                          items: _kebeles.map((a) => a.kebele ?? '').where((n) => n.isNotEmpty).toList(),
                          label: 'Kebele',
                          onChanged: _onKebeleSelected,
                          isLoading: _loadingKebeles,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: l10n.ordersDescription,
              subtitle: 'Describe the property you need in detail',
              child: TextFormField(
                controller: _descriptionCtrl,
                style: AppTextStyles.bodySmall,
                decoration: _inputDecoration(hint: l10n.ordersDescriptionHint),
                maxLines: 4,
                validator: _requiredValidator,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.ordersSubmit),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent50 : AppColors.zinc100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? AppColors.accent500 : context.theme.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.accent500 : context.theme.iconSecondary, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.accent500 : context.theme.textSecondary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listingTypeChip(String value, String label) {
    final selected = _listingType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _listingType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent50 : AppColors.zinc100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? AppColors.accent500 : context.theme.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.accent500 : context.theme.textSecondary,
            ),
          ),
        ),
      ),
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
      style: AppTextStyles.bodySmall,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        suffixIcon: isLoading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : null,
      ),
      items: items.isEmpty
          ? [DropdownMenuItem(value: null, child: Text(l10n.ordersSelect, style: AppTextStyles.bodySmall))]
          : items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodySmall))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }

  InputDecoration _inputDecoration({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodySmall,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  Widget _sectionCard({required String title, String? subtitle, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary50.withValues(alpha: 0.5),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary100.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary500)),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
