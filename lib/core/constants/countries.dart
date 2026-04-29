import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../theme/text_styles.dart';

class CountryCode {
  final String code;
  final String name;
  final String flag;
  final int minDigits;
  final int maxDigits;
  final String example;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
    required this.minDigits,
    required this.maxDigits,
    required this.example,
  });

  String get display => '$flag $name ($code)';
}

class Countries {
  Countries._();

  static const CountryCode ethiopia = CountryCode(
    code: '+251',
    name: 'Ethiopia',
    flag: '🇪🇹',
    minDigits: 9,
    maxDigits: 9,
    example: '912 345 678',
  );

  static const List<CountryCode> all = [
    ethiopia,
    CountryCode(code: '+249', name: 'Sudan', flag: '🇸🇩', minDigits: 9, maxDigits: 9, example: '91 234 5678'),
    CountryCode(code: '+254', name: 'Kenya', flag: '🇰🇪', minDigits: 9, maxDigits: 9, example: '712 345 678'),
    CountryCode(code: '+252', name: 'Somalia', flag: '🇸🇴', minDigits: 9, maxDigits: 9, example: '61 234 5678'),
    CountryCode(code: '+253', name: 'Djibouti', flag: '🇩🇯', minDigits: 8, maxDigits: 8, example: '21 234 56'),
    CountryCode(code: '+20', name: 'Egypt', flag: '🇪🇬', minDigits: 10, maxDigits: 10, example: '100 123 4567'),
    CountryCode(code: '+1', name: 'United States', flag: '🇺🇸', minDigits: 10, maxDigits: 10, example: '(555) 123-4567'),
    CountryCode(code: '+44', name: 'United Kingdom', flag: '🇬🇧', minDigits: 10, maxDigits: 10, example: '7700 900000'),
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳', minDigits: 10, maxDigits: 10, example: '98765 43210'),
    CountryCode(code: '+86', name: 'China', flag: '🇨🇳', minDigits: 11, maxDigits: 11, example: '138 1234 5678'),
  ];

  static List<CountryCode> get sorted {
    final eth = all.where((c) => c.code == '+251').toList();
    final others = all.where((c) => c.code != '+251').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return [...eth, ...others];
  }

  static CountryCode get defaultCountry => ethiopia;
}

class CountrySelectorDropdown extends StatelessWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountrySelected;

  const CountrySelectorDropdown({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(
              selectedCountry.code,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.navy900,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark ? AppColors.zinc400 : AppColors.navy600,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        selectedCountry: selectedCountry,
        onCountrySelected: (country) {
          onCountrySelected(country);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountrySelected;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filtered = Countries.sorted;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = Countries.sorted;
      } else {
        _filtered = Countries.sorted.where((c) =>
          c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.code.contains(query)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc700 : AppColors.zinc300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Country',
                  style: AppTextStyles.title.copyWith(
                    color: isDark ? Colors.white : AppColors.navy900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filter,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.zinc500 : AppColors.zinc400,
                      ),
                      icon: Icon(
                        Icons.search,
                        color: isDark ? AppColors.zinc500 : AppColors.zinc400,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.navy900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final country = _filtered[index];
                final isSelected = country.code == widget.selectedCountry.code;

                return ListTile(
                  onTap: () => widget.onCountrySelected(country),
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.navy900,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    country.example,
                    style: TextStyle(
                      color: isDark ? AppColors.zinc400 : AppColors.zinc500,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.wave500)
                      : Text(
                          country.code,
                          style: TextStyle(
                            color: isDark ? AppColors.zinc400 : AppColors.zinc500,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}