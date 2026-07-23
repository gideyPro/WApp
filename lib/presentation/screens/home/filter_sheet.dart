import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/car_data.dart';
import '../../../l10n/app_localizations.dart';
import 'home_screen.dart';

class UnifiedFilterValues {
  final HomeCategory category;
  final int? priceMin;
  final int? priceMax;
  final String sort;
  final String? location;

  final String? propertyType;
  final String? listingType;
  final bool isFeatured;

  final String? make;
  final String? model;
  final int? yearMin;
  final int? yearMax;
  final int? mileageMax;
  final String? vehicleCategory;
  final String? bodyType;

  const UnifiedFilterValues({
    this.category = HomeCategory.property,
    this.priceMin,
    this.priceMax,
    this.sort = 'newest',
    this.location,
    this.propertyType,
    this.listingType,
    this.isFeatured = false,
    this.make,
    this.model,
    this.yearMin,
    this.yearMax,
    this.mileageMax,
    this.vehicleCategory,
    this.bodyType,
  });

  bool get hasAnyFilter {
    if (category == HomeCategory.all) {
      return priceMin != null ||
          priceMax != null ||
          (location != null && location!.isNotEmpty);
    }
    if (category == HomeCategory.vehicles) {
      return make != null ||
          model != null ||
          yearMin != null ||
          yearMax != null ||
          mileageMax != null ||
          vehicleCategory != null ||
          bodyType != null ||
          priceMin != null ||
          priceMax != null ||
          (location != null && location!.isNotEmpty);
    }
    return propertyType != null ||
        listingType != null ||
        isFeatured ||
        priceMin != null ||
        priceMax != null ||
        (location != null && location!.isNotEmpty);
  }

  UnifiedFilterValues clearField(String key) {
    if (category == HomeCategory.all) {
      return UnifiedFilterValues(
        category: category,
        priceMin: key == 'price_min' ? null : priceMin,
        priceMax: key == 'price_max' ? null : priceMax,
        sort: sort,
        location: key == 'location' ? null : location,
      );
    }
    if (category == HomeCategory.vehicles) {
      return UnifiedFilterValues(
        category: category,
        priceMin: key == 'price_min' ? null : priceMin,
        priceMax: key == 'price_max' ? null : priceMax,
        sort: sort,
        location: key == 'location' ? null : location,
        make: key == 'make' ? null : make,
        model: key == 'model' ? null : model,
        yearMin: key == 'year_min' ? null : yearMin,
        yearMax: key == 'year_max' ? null : yearMax,
        mileageMax: key == 'mileage_max' ? null : mileageMax,
        vehicleCategory: key == 'vehicle_category' ? null : vehicleCategory,
        bodyType: key == 'body_type' ? null : bodyType,
      );
    }
    return UnifiedFilterValues(
      category: category,
      priceMin: key == 'price_min' ? null : priceMin,
      priceMax: key == 'price_max' ? null : priceMax,
      sort: sort,
      location: key == 'location' ? null : location,
      propertyType: key == 'type' ? null : propertyType,
      listingType: key == 'listing_type' ? null : listingType,
      isFeatured: key == 'is_featured' ? false : isFeatured,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (location != null && location!.isNotEmpty) params['location'] = location;
    if (sort != 'newest') {
      if (category == HomeCategory.vehicles &&
          (sort == 'year_desc' || sort == 'year_asc' ||
              sort == 'mileage_low' || sort == 'mileage_high')) {
        if (sort == 'year_desc' || sort == 'year_asc') {
          params['sort'] = 'year';
          params['order'] = sort == 'year_desc' ? 'desc' : 'asc';
        } else {
          params['sort'] = 'mileage';
          params['order'] = sort == 'mileage_low' ? 'asc' : 'desc';
        }
      } else {
        params['sort'] = sort;
      }
    }
    if (priceMin != null) params['price_min'] = priceMin;
    if (priceMax != null) params['price_max'] = priceMax;

    if (category == HomeCategory.vehicles) {
      if (make != null) params['make'] = make;
      if (model != null && model!.isNotEmpty) params['model'] = model;
      if (yearMin != null) params['year_min'] = yearMin;
      if (yearMax != null) params['year_max'] = yearMax;
      if (mileageMax != null) params['mileage_max'] = mileageMax;
      if (vehicleCategory != null) params['vehicle_category'] = vehicleCategory;
      if (bodyType != null) params['body_type'] = bodyType;
    } else if (category == HomeCategory.property) {
      if (propertyType != null) params['type'] = propertyType;
      if (listingType != null) params['listing_type'] = listingType;
      if (isFeatured) params['is_featured'] = true;
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

class FilterSheet extends StatefulWidget {
  final UnifiedFilterValues initialValues;
  final bool showCategoryToggle;

  const FilterSheet({
    super.key,
    required this.initialValues,
    this.showCategoryToggle = true,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late HomeCategory _category;
  late int? _priceMin;
  late int? _priceMax;
  late String? _priceLabel;
  late String _sort;
  late String? _propertyType;
  late String? _listingType;
  late bool _isFeatured;

  late String? _make;
  late String? _model;
  late int? _yearMin;
  late int? _yearMax;
  late int? _mileageMax;
  late String? _vehicleCategory;
  late String? _bodyType;

  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final v = widget.initialValues;
    _category = v.category;
    _priceMin = v.priceMin;
    _priceMax = v.priceMax;
    _sort = v.sort;
    _priceLabel = _labelForPrice(_priceMin, _priceMax);
    _propertyType = v.propertyType;
    _listingType = v.listingType;
    _isFeatured = v.isFeatured;
    _make = v.make;
    _model = v.model;
    _yearMin = v.yearMin;
    _yearMax = v.yearMax;
    _mileageMax = v.mileageMax;
    _vehicleCategory = v.vehicleCategory;
    _bodyType = v.bodyType;
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
      _priceMin = null;
      _priceMax = null;
      _priceLabel = null;
      _sort = 'newest';
      _propertyType = null;
      _listingType = null;
      _isFeatured = false;
      _make = null;
      _model = null;
      _yearMin = null;
      _yearMax = null;
      _mileageMax = null;
      _vehicleCategory = null;
      _bodyType = null;
      _modelController.clear();
      _mileageController.clear();
    });
  }

  void _apply() {
    _model = _modelController.text.isNotEmpty ? _modelController.text : null;
    _mileageMax = int.tryParse(_mileageController.text);

    Navigator.pop(context, UnifiedFilterValues(
      category: _category,
      priceMin: _priceMin,
      priceMax: _priceMax,
      sort: _sort,
      propertyType: _category == HomeCategory.property ? _propertyType : null,
      listingType: _category == HomeCategory.property ? _listingType : null,
      isFeatured: _category == HomeCategory.property ? _isFeatured : false,
      make: _category == HomeCategory.vehicles ? _make : null,
      model: _category == HomeCategory.vehicles ? _model : null,
      yearMin: _category == HomeCategory.vehicles ? _yearMin : null,
      yearMax: _category == HomeCategory.vehicles ? _yearMax : null,
      mileageMax: _category == HomeCategory.vehicles ? _mileageMax : null,
      vehicleCategory: _category == HomeCategory.vehicles ? _vehicleCategory : null,
      bodyType: _category == HomeCategory.vehicles ? _bodyType : null,
    ));
  }

  List<String> get _availableModels {
    if (_make == null) return [];
    if (_vehicleCategory != null) return modelsForCategoryMake(_vehicleCategory!, _make!);
    for (final cat in vehicleCategories) {
      final models = modelsForCategoryMake(cat, _make!);
      if (models.isNotEmpty) return models;
    }
    return [];
  }

  List<String> get _bodyTypeOptions {
    if (_vehicleCategory != null) return bodyTypesByCategory[_vehicleCategory] ?? [];
    final all = <String>{};
    for (final cat in vehicleCategories) {
      if (cat == 'motorcycle' || cat == 'bicycle') continue;
      all.addAll(bodyTypesByCategory[cat] ?? []);
    }
    return all.toList();
  }

  List<String> get _allMakes {
    if (_vehicleCategory != null) return makesForCategory(_vehicleCategory!);
    final all = <String>{};
    for (final cat in vehicleCategories) {
      all.addAll(makesForCategory(cat));
    }
    return all.toList()..sort();
  }

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
                  Row(
                    children: [
                      TextButton(
                        onPressed: _reset,
                        child: Text(l10n.searchReset, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary500)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _apply,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent500,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(l10n.searchApplyFilters, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.showCategoryToggle)
                _buildCategoryToggle(l10n),

              if (_category == HomeCategory.all) ...[
                _buildPriceSection(l10n),
                _buildSortSection(l10n, isVehicle: false),
              ] else if (_category == HomeCategory.property) ..._buildPropertySections(l10n)
              else ..._buildVehicleSections(l10n),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryToggle(AppLocalizations l10n) {
    const categories = HomeCategory.values;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat == _category;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() {
                  _category = cat;
                  _make = null;
                  _model = null;
                  _modelController.clear();
                  _propertyType = null;
                  _listingType = null;
                  _isFeatured = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.gradientAccent : null,
                    color: isSelected ? null : context.cardBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : context.divider.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 15, color: isSelected ? Colors.white : context.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        cat.label(l10n),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildPropertySections(AppLocalizations l10n) {
    return [
      Text(l10n.searchPropertyType, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _modalChipRow(
        options: [
          (l10n.searchFilterAll, null, _propertyType == null),
          (l10n.listingHouse, 'house', _propertyType == 'house'),
          (l10n.listingLand, 'land', _propertyType == 'land'),
        ],
        onSelected: (v) => setState(() => _propertyType = v as String?),
      ),
      const SizedBox(height: 16),

      Text(l10n.searchListingStatus, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _modalChipRow(
        options: [
          (l10n.searchFilterAll, null, _listingType == null),
          (l10n.listingForSale, 'sale', _listingType == 'sale'),
          (l10n.listingForRent, 'rental', _listingType == 'rental'),
        ],
        onSelected: (v) => setState(() => _listingType = v as String?),
      ),
      const SizedBox(height: 16),

      Text(l10n.listingsFeatured, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _modalChipRow(
        options: [
          (l10n.searchFilterAll, null, !_isFeatured),
          (l10n.listingsFeatured, true, _isFeatured),
        ],
        onSelected: (v) => setState(() => _isFeatured = v == true),
      ),
      const SizedBox(height: 16),

      _buildPriceSection(l10n),
      _buildSortSection(l10n, isVehicle: false),
    ];
  }

  List<Widget> _buildVehicleSections(AppLocalizations l10n) {
    return [
      Text(l10n.listingVehicleCategory, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _modalChipRow(
        options: [
          (l10n.searchFilterAny, null, _vehicleCategory == null),
          ...vehicleCategories.map((c) => (vehicleCategoryLabel(c, l10n), c, _vehicleCategory == c)),
        ],
        onSelected: (v) => setState(() {
          _vehicleCategory = v as String?;
          _make = null;
          _model = null;
          _modelController.clear();
          _bodyType = null;
        }),
      ),
      const SizedBox(height: 16),

      Text(l10n.listingMake, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      _modalChipRow(
        options: [
          (l10n.searchFilterAny, null, _make == null),
          ..._allMakes.map((m) => (m, m, _make == m)),
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

      if (_vehicleCategory == null || _vehicleCategory != 'bicycle') ...[
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
      ],

      if (_vehicleCategory == null || _vehicleCategory == 'car' || _vehicleCategory == 'construction_equipment') ...[
        Text(l10n.listingBodyType, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _modalChipRow(
          options: [
            (l10n.searchFilterAny, null, _bodyType == null),
            ..._bodyTypeOptions.map((bt) => (bodyTypeLabel(bt, l10n), bt, _bodyType == bt)),
          ],
          onSelected: (v) => setState(() => _bodyType = v as String?),
        ),
        const SizedBox(height: 16),
      ],

      if (_vehicleCategory == null || _vehicleCategory != 'bicycle') ...[
        Text(l10n.listingMileageMax, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextField(
          controller: _mileageController,
          decoration: _inputDecoration('e.g. 100000'),
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 16),
      ],

      _buildPriceSection(l10n),
      _buildSortSection(l10n, isVehicle: true),
    ];
  }

  Widget _buildPriceSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildSortSection(AppLocalizations l10n, {required bool isVehicle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.searchSortBy, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _modalChipRow(
          options: _sortOptions.where((opt) {
            if (isVehicle) return true;
            return opt.$1 != 'year_desc' && opt.$1 != 'year_asc' &&
                   opt.$1 != 'mileage_low' && opt.$1 != 'mileage_high';
          }).map((opt) {
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
        const SizedBox(height: 16),
      ],
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
