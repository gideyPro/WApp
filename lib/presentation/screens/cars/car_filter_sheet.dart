import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import 'car_strings.dart';

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
  final String? location;
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
    this.location,
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
      location: key == 'location' ? null : location,
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
      priceMax != null ||
      (location != null && location!.isNotEmpty);

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
    if (location != null && location!.isNotEmpty) params['location'] = location;
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

const _makes = [
  'Toyota', 'Nissan', 'Honda', 'Mitsubishi', 'Hyundai',
  'Suzuki', 'Kia', 'Mazda', 'Isuzu', 'Mercedes-Benz',
  'BMW', 'Volkswagen', 'Ford', 'Chevrolet', 'Land Rover',
  'Jeep', 'Lexus', 'Audi', 'Volvo', 'Range Rover',
  'Daihatsu', 'Subaru', 'Fiat', 'Peugeot', 'Renault',
  'Maruti', 'Tata', 'Mahindra',
];

const _transmissions = ['Automatic', 'Manual'];
const _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
const _bodyTypes = [
  'Sedan', 'SUV', 'Hatchback', 'Pickup', 'Minivan',
  'Coupe', 'Convertible', 'Wagon', 'Van', 'Truck',
];

const _sortOptions = [
  ('Newest', 'newest'),
  ('Oldest', 'oldest'),
  ('Price: Low to High', 'price_low'),
  ('Price: High to Low', 'price_high'),
  ('Year: Newest', 'year_desc'),
  ('Year: Oldest', 'year_asc'),
  ('Mileage: Low', 'mileage_low'),
  ('Mileage: High', 'mileage_high'),
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
  late String? _location;
  late String _sort;

  final _locationController = TextEditingController();
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

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
    _location = widget.initialValues.location;
    _sort = widget.initialValues.sort;

    _locationController.text = _location ?? '';
    _modelController.text = _model ?? '';
    _mileageController.text = _mileageMax?.toString() ?? '';
    _priceMinController.text = _priceMin?.toString() ?? '';
    _priceMaxController.text = _priceMax?.toString() ?? '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
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
      _location = null;
      _sort = 'newest';
      _locationController.clear();
      _modelController.clear();
      _mileageController.clear();
      _priceMinController.clear();
      _priceMaxController.clear();
    });
  }

  void _apply() {
    _location = _locationController.text.isNotEmpty ? _locationController.text : null;
    _model = _modelController.text.isNotEmpty ? _modelController.text : null;
    _mileageMax = int.tryParse(_mileageController.text);
    _priceMin = int.tryParse(_priceMinController.text);
    _priceMax = int.tryParse(_priceMaxController.text);

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
      location: _location,
      sort: _sort,
    ));
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(CarStrings.filters, style: AppTextStyles.title.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _reset,
                    child: Text(CarStrings.reset, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary500)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location
              _sectionHeader(CarStrings.searchLocation),
              TextField(
                controller: _locationController,
                decoration: _inputDecoration(CarStrings.searchLocation),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Make
              _sectionHeader(CarStrings.listingMake),
              const SizedBox(height: 8),
              _chipSelector(_makes, _make, (v) => setState(() => _make = v)),
              const SizedBox(height: 16),

              // Model
              _sectionHeader(CarStrings.listingModel),
              TextField(
                controller: _modelController,
                decoration: _inputDecoration(CarStrings.listingModel),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Year
              _sectionHeader(CarStrings.listingYear),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _yearDropdown(CarStrings.yearFrom, _yearMin, (v) => setState(() => _yearMin = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _yearDropdown(CarStrings.yearTo, _yearMax, (v) => setState(() => _yearMax = v))),
                ],
              ),
              const SizedBox(height: 16),

              // Transmission
              _sectionHeader(CarStrings.listingTransmission),
              const SizedBox(height: 8),
              _chipSelector(_transmissions, _transmission, (v) => setState(() => _transmission = v)),
              const SizedBox(height: 16),

              // Fuel Type
              _sectionHeader(CarStrings.listingFuelType),
              const SizedBox(height: 8),
              _chipSelector(_fuelTypes, _fuelType, (v) => setState(() => _fuelType = v)),
              const SizedBox(height: 16),

              // Body Type
              _sectionHeader(CarStrings.listingBodyType),
              const SizedBox(height: 8),
              _chipSelector(_bodyTypes, _bodyType, (v) => setState(() => _bodyType = v)),
              const SizedBox(height: 16),

              // Mileage
              _sectionHeader(CarStrings.mileageMax),
              TextField(
                controller: _mileageController,
                decoration: _inputDecoration('e.g. 100000'),
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Price
              _sectionHeader(CarStrings.price),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: _priceMinController,
                    decoration: _inputDecoration(CarStrings.minimum),
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: _priceMaxController,
                    decoration: _inputDecoration(CarStrings.maximum),
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium,
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Sort
              _sectionHeader(CarStrings.sortBy),
              const SizedBox(height: 8),
              _chipSelector(
                _sortOptions.map((e) => e.$1).toList(),
                _sortOptions.firstWhere((e) => e.$2 == _sort, orElse: () => _sortOptions[0]).$1,
                (v) {
                  final idx = _sortOptions.indexWhere((e) => e.$1 == v);
                  if (idx >= 0) setState(() => _sort = _sortOptions[idx].$2);
                },
                valueToString: (v) => v,
                toString: (v) => v,
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
                  child: Text(CarStrings.apply, style: AppTextStyles.bodyLargePlus.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600));
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

  Widget _chipSelector<T>(List<T> options, T? selected, void Function(T) onSelected, {String Function(T)? valueToString, String Function(T)? toString}) {
    final display = toString ?? ((T v) => v.toString());
    final toValue = valueToString ?? ((T v) => v.toString());
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected != null && (toValue(opt) == (selected is String ? selected : toValue(selected)));
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent500.withValues(alpha: 0.15) : context.cardBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppColors.accent500 : context.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              display(opt),
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

  Widget _yearDropdown(String label, int? value, void Function(int?) onChanged) {
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
          hint: Text(label, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary.withValues(alpha: 0.5))),
          items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: AppTextStyles.bodyMedium))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
