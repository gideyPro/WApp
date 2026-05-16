import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/services/order_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_common_widgets.dart';

class EditOrderScreen extends ConsumerStatefulWidget {
  final Order order;
  const EditOrderScreen({super.key, required this.order});

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  late String _type;
  late String _listingType;
  String? _holdingType;
  String? _facingDirection;
  late TextEditingController _minBudgetCtrl;
  late TextEditingController _maxBudgetCtrl;
  late TextEditingController _minAreaCtrl;
  late TextEditingController _maxAreaCtrl;
  late TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _type = o.type;
    _listingType = o.listingType;
    _holdingType = o.holdingType;
    _facingDirection = o.facingDirection;
    _minBudgetCtrl = TextEditingController(text: o.minBudget?.toStringAsFixed(0) ?? '');
    _maxBudgetCtrl = TextEditingController(text: o.maxBudget?.toStringAsFixed(0) ?? '');
    _minAreaCtrl = TextEditingController(text: o.minArea?.toStringAsFixed(0) ?? '');
    _maxAreaCtrl = TextEditingController(text: o.maxArea?.toStringAsFixed(0) ?? '');
    _descriptionCtrl = TextEditingController(text: o.description);
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
    if (_minBudgetCtrl.text.isNotEmpty) data['min_budget'] = _minBudgetCtrl.text;
    if (_maxBudgetCtrl.text.isNotEmpty) data['max_budget'] = _maxBudgetCtrl.text;
    if (_minAreaCtrl.text.isNotEmpty) data['min_area'] = _minAreaCtrl.text;
    if (_maxAreaCtrl.text.isNotEmpty) data['max_area'] = _maxAreaCtrl.text;

    final service = OrderService();
    final response = await service.updateOrder(widget.order.id, data);

    if (mounted) {
      setState(() => _submitting = false);
      if (response.success) {
        WaveToast.showSuccess(context, AppLocalizations.of(context).ordersUpdated);
        Navigator.of(context).pop(true);
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
        title: Text(l10n.ordersEdit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingLg,
          children: [
            Text(l10n.ordersTypeLabel,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                _typeChip('house', l10n.ordersTypeHouse, Icons.home_outlined),
                const SizedBox(width: 12),
                _typeChip('land', l10n.ordersTypeLand, Icons.landscape_outlined),
              ],
            ),
            const SizedBox(height: 24),

            Text(l10n.ordersListingType,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                _listingTypeChip('buy', l10n.ordersBuy),
                const SizedBox(width: 12),
                _listingTypeChip('rental', l10n.ordersRent),
              ],
            ),
            const SizedBox(height: 24),

            Text(l10n.ordersHoldingType,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _holdingType,
              decoration: _inputDecoration(),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.ordersSelect)),
                ...['Free Hold', 'Lease Hold', 'Cooperative'].map((v) =>
                    DropdownMenuItem(value: v, child: Text(v))),
              ],
              onChanged: (v) => setState(() => _holdingType = v),
            ),
            const SizedBox(height: 24),

            Text(l10n.ordersFacing,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _facingDirection,
              decoration: _inputDecoration(),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.ordersSelect)),
                ...['north', 'south', 'east', 'west', 'north_east', 'north_west', 'south_east', 'south_west', 'facing_3_directions', 'Facing All Directions'].map((v) =>
                    DropdownMenuItem(value: v, child: Text(v.replaceAll('_', ' ')))),
              ],
              onChanged: (v) => setState(() => _facingDirection = v),
            ),
            const SizedBox(height: 24),

            Text(l10n.ordersBudget,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minBudgetCtrl,
                    decoration: _inputDecoration(label: l10n.ordersMin),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxBudgetCtrl,
                    decoration: _inputDecoration(label: l10n.ordersMax),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(l10n.ordersArea,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAreaCtrl,
                    decoration: _inputDecoration(label: l10n.ordersMin),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxAreaCtrl,
                    decoration: _inputDecoration(label: l10n.ordersMax),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(l10n.ordersDescription,
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: _inputDecoration(hint: l10n.ordersDescriptionHint),
              maxLines: 5,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 48,
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
                    : Text(l10n.ordersSave),
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
              color: selected ? AppColors.accent500 : AppColors.zinc300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.accent500 : AppColors.primary400, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.accent500 : AppColors.primary600,
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
              color: selected ? AppColors.accent500 : AppColors.zinc300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.accent500 : AppColors.primary600,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
