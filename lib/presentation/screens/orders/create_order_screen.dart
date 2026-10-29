import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/v2/api_v2_error.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/v2/address_option.dart';
import '../../../data/models/v2/subscription_state.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';

import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_upgrade_card.dart';

/// Buyer request form backed by the v2 nested payload.
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

  /// One key per form instance so a retry after a network error reuses the
  /// order instead of consuming another quota slot.
  late final String _submissionKey;

  // Address picker
  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [];
  List<AddressOption> _kebeles = [];
  int? _kebeleId;
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;

  bool _formatting = false;

  @override
  void initState() {
    super.initState();
    _submissionKey = _newSubmissionKey();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRegions());
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

  static String _newSubmissionKey() {
    final random = Random();
    final suffix = random.nextInt(0x7fffffff).toRadixString(36);
    return 'ord-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }

  String get _locale => Localizations.localeOf(context).languageCode;

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
    if (!mounted) return;
    try {
      final regions = await ref.read(addressV2ServiceProvider).regions(
            locale: _locale,
          );
      if (mounted) {
        setState(() {
          _regions = regions.map((option) => option.name).toList();
        });
      }
    } catch (_) {
      // The picker is optional; a failed load leaves it empty.
    }
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null;
      _selectedWoreda = null;
      _selectedKebele = null;
      _kebeleId = null;
      _zones = [];
      _woredas = [];
      _kebeles = [];
    });
    if (region == null) return;
    setState(() => _loadingZones = true);
    try {
      final zones = await ref.read(addressV2ServiceProvider).zones(
            region,
            locale: _locale,
          );
      if (mounted) {
        setState(() {
          _zones = zones.map((option) => option.name).toList();
        });
      }
    } finally {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone;
      _selectedWoreda = null;
      _selectedKebele = null;
      _kebeleId = null;
      _woredas = [];
      _kebeles = [];
    });
    if (zone == null || _selectedRegion == null) return;
    setState(() => _loadingWoredas = true);
    try {
      final woredas = await ref.read(addressV2ServiceProvider).woredas(
            _selectedRegion!,
            zone,
            locale: _locale,
          );
      if (mounted) {
        setState(() {
          _woredas = woredas.map((option) => option.name).toList();
        });
      }
    } finally {
      if (mounted) setState(() => _loadingWoredas = false);
    }
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda;
      _selectedKebele = null;
      _kebeleId = null;
      _kebeles = [];
    });
    if (woreda == null || _selectedRegion == null || _selectedZone == null) {
      return;
    }
    setState(() => _loadingKebeles = true);
    try {
      final kebeles = await ref.read(addressV2ServiceProvider).kebeles(
            _selectedRegion!,
            _selectedZone!,
            woreda,
            locale: _locale,
          );
      if (mounted) {
        setState(() {
          _kebeles = kebeles.where((option) => option.name.isNotEmpty).toList();
        });
      }
    } finally {
      if (mounted) setState(() => _loadingKebeles = false);
    }
  }

  void _onKebeleSelected(String? kebele) {
    final match = _kebeles.where((option) => option.name == kebele).firstOrNull;
    setState(() {
      _selectedKebele = kebele;
      _kebeleId = match?.id;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final budget = <String, dynamic>{
      if (_minBudgetCtrl.text.isNotEmpty)
        'min': double.tryParse(_minBudgetCtrl.text.replaceAll(',', '')),
      if (_maxBudgetCtrl.text.isNotEmpty)
        'max': double.tryParse(_maxBudgetCtrl.text.replaceAll(',', '')),
    }..removeWhere((_, value) => value == null);

    final area = <String, dynamic>{
      if (_minAreaCtrl.text.isNotEmpty)
        'min': double.tryParse(_minAreaCtrl.text.replaceAll(',', '')),
      if (_maxAreaCtrl.text.isNotEmpty)
        'max': double.tryParse(_maxAreaCtrl.text.replaceAll(',', '')),
    }..removeWhere((_, value) => value == null);

    final attributes = <String, dynamic>{
      if (_holdingType != null) 'holding_type': _holdingType,
      if (_facingDirection != null) 'facing_direction': _facingDirection,
    };

    final data = <String, dynamic>{
      'submission_key': _submissionKey,
      'type': _type,
      'listing_type': _listingType,
      'description': _descriptionCtrl.text.trim(),
      if (_kebeleId != null) 'address_id': _kebeleId,
      if (budget.isNotEmpty) 'budget': budget,
      if (area.isNotEmpty) 'area': area,
      if (attributes.isNotEmpty) 'attributes': attributes,
    };

    final l10n = AppLocalizations.of(context);

    try {
      await ref.read(orderV2ServiceProvider).create(data);

      // Quota usage changed; refresh the gate for the next visit.
      ref.invalidate(subscriptionOverviewProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ordersCreated),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiV2Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commonError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).orderRequired;
    }
    return null;
  }

  /// Returns the upgrade copy when the plan cannot create another order.
  ({String title, String subtitle})? _orderGate(
    SubscriptionOverview overview,
    AppLocalizations l10n,
  ) {
    if (!overview.hasActiveSubscription) {
      return (
        title: l10n.subscriptionRequiredTitle,
        subtitle: l10n.subscriptionRequiredOrderSubtitle,
      );
    }

    final capability = overview.capabilities.maxOrders;

    // No reported quota means the server decides; do not block locally.
    if (capability == null) return null;

    if (!capability.allowed) {
      return (
        title: l10n.subscriptionRequiredTitle,
        subtitle: l10n.subscriptionRequiredOrderSubtitle,
      );
    }

    if (capability.max == 0) {
      return (
        title: l10n.subscriptionPlanNotSupportedOrder,
        subtitle: l10n.subscriptionPlanNotSupportedOrderSubtitle,
      );
    }

    if (!capability.hasCapacity) {
      return (
        title: l10n.ordersLimitTitle,
        subtitle: l10n.ordersLimitMessage,
      );
    }

    return null;
  }

  Widget _buildSkeleton() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        centerTitle: false,
        title: Text(l10n.ordersCreate),
      ),
      body: Shimmer.fromColors(
        baseColor: context.shimmerBase,
        highlightColor: context.shimmerHighlight,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: 120,
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
              const SizedBox(height: 24),
              for (int i = 0; i < 4; i++) ...[
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overviewAsync = ref.watch(subscriptionOverviewProvider);
    final configAsync = ref.watch(appConfigProvider);
    final rentalEnabled = configAsync.maybeWhen(
        data: (config) => config.rentalEnabled, orElse: () => false);

    // Loading state — wait for the overview before gating.
    if (overviewAsync.isLoading) {
      return _buildSkeleton();
    }

    if (overviewAsync.hasError) {
      return WaveMessageScreen.error(
        title: l10n.errorSubscription,
        subtitle: l10n.commonError,
        onRetry: () => ref.invalidate(subscriptionOverviewProvider),
      );
    }

    final overview = overviewAsync.value;
    if (overview != null && overview.enabled) {
      final gate = _orderGate(overview, l10n);
      if (gate != null) {
        return WaveFullPageUpgrade(
          appBar: WaveAppBar(
            centerTitle: false,
            title: Text(l10n.ordersCreate),
          ),
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.accent500,
          title: gate.title,
          subtitle: gate.subtitle,
        );
      }
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        centerTitle: false,
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
              subtitle: l10n.orderSelectPropertyType,
              child: Row(
                children: [
                  _typeChip('house', l10n.ordersTypeHouse, Icons.home_outlined),
                  const SizedBox(width: 12),
                  _typeChip(
                    'land',
                    l10n.ordersTypeLand,
                    Icons.landscape_outlined,
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: l10n.ordersListingType,
              subtitle: l10n.orderBudgetAreaSubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rentalEnabled) ...[
                    Row(
                      children: [
                        _listingTypeChip('sale', l10n.ordersBuy),
                        const SizedBox(width: 12),
                        _listingTypeChip('rental', l10n.ordersRent),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    l10n.ordersBudget,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minBudgetCtrl,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.theme.textPrimary,
                          ),
                          decoration: _inputDecoration(label: l10n.ordersMin),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_minBudgetCtrl, v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxBudgetCtrl,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.theme.textPrimary,
                          ),
                          decoration: _inputDecoration(label: l10n.ordersMax),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_maxBudgetCtrl, v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ordersArea,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minAreaCtrl,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.theme.textPrimary,
                          ),
                          decoration: _inputDecoration(label: l10n.ordersMin),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _onNumberChanged(_minAreaCtrl, v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAreaCtrl,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.theme.textPrimary,
                          ),
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
              subtitle: l10n.orderHoldingFacingSubtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _holdingType,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.theme.textPrimary,
                    ),
                    decoration: _inputDecoration(label: l10n.ordersSelect),
                    dropdownColor: context.sheetBg,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          l10n.ordersSelect,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textMuted),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Free Hold',
                        child: Text(
                          l10n.listingFreeHold,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Lease Hold',
                        child: Text(
                          l10n.listingLeaseHold,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Cooperative',
                        child: Text(
                          l10n.listingCooperative,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _holdingType = v),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ordersFacing,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _facingDirection,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.theme.textPrimary,
                    ),
                    decoration: _inputDecoration(label: l10n.ordersSelect),
                    dropdownColor: context.sheetBg,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          l10n.ordersSelect,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textMuted),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'north',
                        child: Text(
                          l10n.listingNorth,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'south',
                        child: Text(
                          l10n.listingSouth,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'east',
                        child: Text(
                          l10n.listingEast,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'west',
                        child: Text(
                          l10n.listingWest,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'north_east',
                        child: Text(
                          l10n.listingNorthEast,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'north_west',
                        child: Text(
                          l10n.listingNorthWest,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'south_east',
                        child: Text(
                          l10n.listingSouthEast,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'south_west',
                        child: Text(
                          l10n.listingSouthWest,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'facing_3_directions',
                        child: Text(
                          l10n.listingFacing3Directions,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'facing_all_directions',
                        child: Text(
                          l10n.listingFacingAllDirections,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: context.theme.textPrimary),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _facingDirection = v),
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: l10n.listingLocation,
              subtitle:
                  '${l10n.listingKebele}, ${l10n.listingWoreda}, ${l10n.listingZone}, ${l10n.listingRegion}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedRegion,
                          items: _regions,
                          label: l10n.listingRegion,
                          onChanged: _onRegionSelected,
                          isLoading: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedZone,
                          items: _zones,
                          label: l10n.listingZone,
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
                          label: l10n.listingWoreda,
                          onChanged: _onWoredaSelected,
                          isLoading: _loadingWoredas,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _compactDropdownField(
                          value: _selectedKebele,
                          items: _kebeles.map((option) => option.name).toList(),
                          label: l10n.listingKebele,
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
              subtitle: l10n.orderDescriptionSubtitle,
              child: TextFormField(
                controller: _descriptionCtrl,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.theme.textPrimary,
                ),
                decoration: _inputDecoration(hint: l10n.ordersDescriptionHint),
                maxLines: 4,
                validator: _requiredValidator,
              ),
            ),
            const SizedBox(height: 8),
            WaveButton(
              text: l10n.ordersSubmit,
              icon: Icons.add,
              variant: ButtonVariant.success,
              onPressed: _submitting ? null : _submit,
              isLoading: _submitting,
              isFullWidth: true,
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
      child: LiquidGlass(
        borderRadius: 16,
        blur: selected ? 20 : 16,
        variant: selected
            ? LiquidGlassVariant.prominent
            : LiquidGlassVariant.regular,
        tint: selected ? AppColors.accent500 : null,
        interactive: true,
        onTap: () => setState(() => _type = value),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppColors.accent500 : context.theme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? AppColors.accent500
                    : context.theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingTypeChip(String value, String label) {
    final selected = _listingType == value;
    return Expanded(
      child: LiquidGlass(
        borderRadius: 16,
        blur: selected ? 20 : 16,
        variant: selected
            ? LiquidGlassVariant.prominent
            : LiquidGlassVariant.regular,
        tint: selected ? AppColors.accent500 : null,
        interactive: true,
        onTap: () => setState(() => _listingType = value),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'sale' ? Icons.sell_rounded : Icons.key_rounded,
              size: 16,
              color: selected ? AppColors.accent500 : context.theme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? AppColors.accent500
                    : context.theme.textSecondary,
              ),
            ),
          ],
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
      style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        suffixIcon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
      dropdownColor: context.sheetBg,
      items: items.isEmpty
          ? [
              DropdownMenuItem(
                value: null,
                child: Text(
                  l10n.ordersSelect,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: context.theme.textMuted),
                ),
              ),
            ]
          : items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: context.theme.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }

  InputDecoration _inputDecoration({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
      hintText: hint,
      hintStyle:
          AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return WaveCard(
      useLiquidGlass: true,
      isGlass: true,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: context.theme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.theme.textMuted),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
