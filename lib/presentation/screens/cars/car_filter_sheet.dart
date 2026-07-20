import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/car_data.dart';
import '../../../l10n/app_localizations.dart';

class CarFilterValues {
  final String? make;
  final String? model;
  final int? yearMin;
  final int? yearMax;
  final int? mileageMax;
  final String? transmission;
  final String? fuelType;
  final String? bodyType;
  final int? priceMin;
  final int? priceMax;
  final String sort;

  const CarFilterValues({
    this.make,
    this.model,
    this.yearMin,
    this.yearMax,
    this.mileageMax,
    this.transmission,
    this.fuelType,
    this.bodyType,
    this.priceMin,
    this.priceMax,
    this.sort = 'newest',
  });

  CarFilterValues clearField(String key) {
    return CarFilterValues(
      make: key == 'make' ? null : make,
      model: key == 'model' ? null : model,
      yearMin: key == 'year_min' ? null : yearMin,
      yearMax: key == 'year_max' ? null : yearMax,
      mileageMax: key == 'mileage_max' ? null : mileageMax,
      transmission: key == 'transmission' ? null : transmission,
      fuelType: key == 'fuel_type' ? null : fuelType,
      bodyType: key == 'body_type' ? null : bodyType,
      priceMin: key == 'price_min' ? null : priceMin,
      priceMax: key == 'price_max' ? null : priceMax,
      sort: sort,
    );
  }

  bool get hasAnyFilter =>
      make != null ||
      model != null ||
      yearMin != null ||
      yearMax != null ||
      mileageMax != null ||
      transmission != null ||
      fuelType != null ||
      bodyType != null ||
      priceMin != null ||
      priceMax != null;

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (make != null) params['make'] = make;
    if (model != null && model!.isNotEmpty) params['model'] = model;
    if (yearMin != null) params['year_min'] = yearMin;
    if (yearMax != null) params['year_max'] = yearMax;
    if (mileageMax != null) params['mileage_max'] = mileageMax;
    if (transmission != null) params['transmission'] = transmission;
    if (fuelType != null) params['fuel_type'] = fuelType;
    if (bodyType != null) params['body_type'] = bodyType;
    if (priceMin != null) params['price_min'] = priceMin;
    if (priceMax != null) params['price_max'] = priceMax;
    if (sort == 'price_low' || sort == 'price_high') {
      params['sort'] = sort;
    } else if (sort == 'year_desc' || sort == 'year_asc') {
      params['sort'] = 'year';
      params['order'] = sort == 'year_desc' ? 'desc' : 'asc';
    } else if (sort == 'mileage_low' || sort == 'mileage_high') {
      params['sort'] = 'mileage';
      params['order'] = sort == 'mileage_low' ? 'asc' : 'desc';
    } else {
      params['sort'] = sort;
    }
    return params;
  }
}

const _priceRanges = <String, (int?, int?)>{
  'Under 5M': (0, 5000000),
  '5M-10M': (5000000, 10000000),
  '10M-50M': (10000000, 50000000),
  '50M-100M': (50000000, 100000000),
  '100M+': (100000000, null),
};

const _sortOptions = [
  ('newest', 'newest'),
  ('oldest', 'oldest'),
  ('price_low', 'price_low'),
  ('price_high', 'price_high'),
  ('year_desc', 'year_desc'),
  ('year_asc', 'year_asc'),
  ('mileage_low', 'mileage_low'),
  ('mileage_high', 'mileage_high'),
];

class CarFilterSheet extends StatefulWidget {
  final CarFilterValues initialValues;

  const CarFilterSheet({super.key, required this.initialValues});

  @override
  State<CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<CarFilterSheet> {
  late String? _make;
  late String? _model;
  late int? _yearMin;
  late int? _yearMax;
  late int? _mileageMax;
  late String? _transmission;
  late String? _fuelType;
  late String? _bodyType;
  late int? _priceMin;
  late int? _priceMax;
  late String _sort;
  late String? _priceLabel;

  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _make = widget.initialValues.make;
    _model = widget.initialValues.model;
    _yearMin = widget.initialValues.yearMin;
    _yearMax = widget.initialValues.yearMax;
    _mileageMax = widget.initialValues.mileageMax;
    _transmission = widget.initialValues.transmission;
    _fuelType = widget.initialValues.fuelType;
    _bodyType = widget.initialValues.bodyType;
    _priceMin = widget.initialValues.priceMin;
    _priceMax = widget.initialValues.priceMax;
    _sort = widget.initialValues.sort;
    _priceLabel = _labelForPrice(_priceMin, _priceMax);

    _modelController.text = _model ?? '';
    _mileageController.text = _mileageMax?.toString() ?? '';
  }

  String? _labelForPrice(int? min, int? max) {
    for (final entry in _priceRanges.entries) {
      if (entry.value.$1 == min && entry.value.$2 == max) return entry.key;
    }
    return null;
  }

  @override
  void dispose() {
    _modelController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _make = null;
      _model = null;
      _yearMin = null;
      _yearMax = null;
      _mileageMax = null;
      _transmission = null;
      _fuelType = null;
      _bodyType = null;
      _priceMin = null;
      _priceMax = null;
      _priceLabel = null;
      _sort = 'newest';
      _modelController.clear();
      _mileageController.clear();
    });
  }

  void _apply() {
    _model = _modelController.text.isNotEmpty ? _modelController.text : null;
    _mileageMax = int.tryParse(_mileageController.text);

    Navigator.pop(context, CarFilterValues(
      make: _make,
      model: _model,
      yearMin: _yearMin,
      yearMax: _yearMax,
      mileageMax: _mileageMax,
      transmission: _transmission,
      fuelType: _fuelType,
      bodyType: _bodyType,
      priceMin: _priceMin,
      priceMax: _priceMax,
      sort: _sort,
    ));
  }

  List<String> get _availableModels =>
      _make != null ? (carModelsByMake[_make] ?? []) : [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: context.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.searchFilters, style: AppTextStyles.title.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _reset,
                    child: Text(l10n.searchReset, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary500)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Make
              Text(l10n.listingMake, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _modalChipRow(
                options: [
                  (l10n.searchFilterAny, null, _make == null),
                  ...carMakes.map((m) => (m, m, _make == m)),
                ],
                onSelected: (v) => setState(() {
                  _make = v as String?;
                  if (_make == null) {
                    _model = null;
                    _modelController.clear();
                  } else {
                    final models = _availableModels;
                    if (models.isNotEmpty && (_model == null || !models.contains(_model))) {
                      _model = null;
                      _modelController.clear();
                    }
                  }
                }),
              ),
              const SizedBox(height: 16),

              // Model
              if (_make != null && _availableModels.isNotEmpty) ...[
                Text(l10n.listingModel, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _modalChipRow(
                  options: [
                    (l10n.searchFilterAny, null, _model == null),
                    ..._availableModels.map((m) => (m, m, _model == m)),
                  ],
                  onSelected: (v) => setState(() => _model = v as String?),
                ),
                const SizedBox(height: 16),
              ],

              // Year
              Text(l10n.listingYear, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _yearDropdown(l10n.searchFilterAny, _yearMin, (v) => setState(() => _yearMin = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _yearDropdown(l10n.searchFilterAny, _yearMax, (v) => setState(() => _yearMax = v))),
                ],
              ),
              const SizedBox(height: 16),

              // Transmission
              Text(l10n.listingTransmission, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _modalChipRow(
                options: [
                  (l10n.searchFilterAny, null, _transmission == null),
                  ('Automatic', 'Automatic', _transmission == 'Automatic'),
                  ('Manual', 'Manual', _transmission == 'Manual'),
                ],
                onSelected: (v) => setState(() => _transmission = v as String?),
              ),
              const SizedBox(height: 16),

              // Fuel Type
              Text(l10n.listingFuelType, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _modalChipRow(
                options: [
                  (l10n.searchFilterAny, null, _fuelType == null),
                  ('Petrol', 'Petrol', _fuelType == 'Petrol'),
                  ('Diesel', 'Diesel', _fuelType == 'Diesel'),
                  ('Electric', 'Electric', _fuelType == 'Electric'),
                  ('Hybrid', 'Hybrid', _fuelType == 'Hybrid'),
                ],
                onSelected: (v) => setState(() => _fuelType = v as String?),
              ),
              const SizedBox(height: 16),

              // Body Type
              Text(l10n.listingBodyType, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _modalChipRow(
                options: [
                  (l10n.searchFilterAny, null, _bodyType == null),
                  ('Sedan', 'Sedan', _bodyType == 'Sedan'),
                  ('SUV', 'SUV', _bodyType == 'SUV'),
                  ('Hatchback', 'Hatchback', _bodyType == 'Hatchback'),
                  ('Pickup', 'Pickup', _bodyType == 'Pickup'),
                  ('Minivan', 'Minivan', _bodyType == 'Minivan'),
                  ('Coupe', 'Coupe', _bodyType == 'Coupe'),
                  ('Convertible', 'Convertible', _bodyType == 'Convertible'),
                  ('Wagon', 'Wagon', _bodyType == 'Wagon'),
                  ('Van', 'Van', _bodyType == 'Van'),
                  ('Truck', 'Truck', _bodyType == 'Truck'),
                ],
                onSelected: (v) => setState(() => _bodyType = v as String?),
              ),
              const SizedBox(height: 16),

              // Mileage
              Text(l10n.listingMileageMax, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _mileageController,
                decoration: _inputDecoration('e.g. 100000'),
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Price Range
              Text(l10n.searchPriceRange, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _modalChipRow(
                options: [
                  (l10n.searchFilterAny, null, _priceLabel == null),
                  (l10n.searchUnder5M, 'Under 5M', _priceLabel == 'Under 5M'),
                  (l10n.search5M10M, '5M-10M', _priceLabel == '5M-10M'),
                  (l10n.search10M50M, '10M-50M', _priceLabel == '10M-50M'),
                  (l10n.search50M100M, '50M-100M', _priceLabel == '50M-100M'),
                  (l10n.search100MPlus, '100M+', _priceLabel == '100M+'),
                ],
                onSelected: (v) {
                  final label = v as String?;
                  setState(() {
                    _priceLabel = label;
                    if (label == null) {
                      _priceMin = null;
                      _priceMax = null;
                    } else {
                      final range = _priceRanges[label]!;
                      _priceMin = range.$1;
                      _priceMax = range.$2;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Sort
              Text(l10n.searchSortBy, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _modalChipRow(
                options: _sortOptions.map((opt) {
                  final (key, _) = opt;
                  String label;
                  switch (key) {
                    case 'newest': label = l10n.searchSortNewest;
                    case 'oldest': label = l10n.searchSortOldest;
                    case 'price_low': label = l10n.searchSortPriceLow;
                    case 'price_high': label = l10n.searchSortPriceHigh;
                    case 'year_desc': label = l10n.searchSortYearDesc;
                    case 'year_asc': label = l10n.searchSortYearAsc;
                    case 'mileage_low': label = l10n.searchSortMileageLow;
                    case 'mileage_high': label = l10n.searchSortMileageHigh;
                    default: label = key;
                  }
                  return (label, key, _sort == key);
                }).toList(),
                onSelected: (v) => setState(() => _sort = v as String),
              ),
              const SizedBox(height: 24),

              // Apply
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(l10n.searchApplyFilters, style: AppTextStyles.bodyLargePlus.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _modalChipRow({
    required List<(String, dynamic, bool)> options,
    required void Function(dynamic) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((chip) {
        final (label, value, isSelected) = chip;
        return GestureDetector(
          onTap: () => onSelected(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent500.withValues(alpha: 0.12) : context.cardBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppColors.accent500.withValues(alpha: 0.4) : context.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.accent500 : context.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary.withValues(alpha: 0.5)),
      filled: true,
      fillColor: context.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: context.divider.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: context.divider.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.accent500),
      ),
    );
  }

  Widget _yearDropdown(String hint, int? value, void Function(int?) onChanged) {
    final years = List.generate(26, (i) => 2025 - i);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary.withValues(alpha: 0.5))),
          items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: AppTextStyles.bodyMedium))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
