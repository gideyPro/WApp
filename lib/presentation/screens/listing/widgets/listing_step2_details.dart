import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/ethiopian_date_helper.dart';

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
                              EthiopianDateHelper.toEthiopianYearSuffix(year),
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
