import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/car_form_data.dart';
import '../../../data/car_data.dart';
import '../../../data/services/address_service.dart';
import '../../../data/services/listing_media_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../../providers/car_providers.dart';
import '../../providers/app_providers.dart';
import '../../../core/utils/ethiopian_date_helper.dart';


class CreateCarScreen extends ConsumerStatefulWidget {
  const CreateCarScreen({super.key});

  @override
  ConsumerState<CreateCarScreen> createState() => _CreateCarScreenState();
}

class _CreateCarScreenState extends ConsumerState<CreateCarScreen> {
  final _pageController = PageController();
  late CarFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;
  final Map<int, List<String>> _stepErrors = {};

  AppLocalizations get l10n => AppLocalizations.of(context);

  bool _isCustomMake = false;
  bool _isCustomModel = false;

  List<String> get _availableModels => modelsForCategoryMake(_formData.vehicleCategory, _formData.make);

  AddressService get _addressService => ref.read(addressServiceProvider);
  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  final Map<String, int?> _kebeleIds = {};
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;
  int? _addressId;
  late TextEditingController _specificLocationController;

  @override
  void initState() {
    super.initState();
    _formData = CarFormData();
    _specificLocationController = TextEditingController();
    _loadRegions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _specificLocationController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _nextStep() {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      return;
    }
    setState(() => _stepErrors.remove(_currentStep));
    if (_currentStep < 2) _goToStep(_currentStep + 1);
  }

  void _prevStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  List<String> _validateCurrentStep() {
    final errors = <String>[];
    switch (_currentStep) {
      case 0:
        if (_formData.make.isEmpty) errors.add('${l10n.listingMake} ${l10n.commonIsRequired}');
        if (_formData.model.isEmpty) errors.add('${l10n.listingModel} ${l10n.commonIsRequired}');
        if (_formData.vehicleCategory != 'bicycle' && _formData.year.isEmpty) errors.add('${l10n.listingYear} ${l10n.commonIsRequired}');
        break;
      case 1:
        if (!_formData.isForRent && _formData.priceFixed.isEmpty) errors.add('${l10n.listingPriceEtb} ${l10n.commonIsRequired}');
        if (_formData.addressId == null) errors.add(l10n.carLocationRequired);
        break;
      case 2:
        if (_formData.images.isEmpty) errors.add(l10n.listingErrorImageRequired);
        if (!_formData.termsAccepted) errors.add(l10n.carTermsRequired);
        break;
    }
    return errors;
  }

  Future<void> _loadRegions() async {
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getRegions(locale: locale);
      if (mounted && response.success) {
        setState(() => _regions = response.regions.map((r) => r.region ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _regions = []);
    }
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null; _selectedWoreda = null; _selectedKebele = null; _addressId = null;
      _zones = []; _woredas = []; _kebeles = [];
    });
    if (region == null) return;
    setState(() => _loadingZones = true);
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getZones(region: region, locale: locale);
      if (mounted && response.success) {
        setState(() => _zones = response.zones.map((z) => z.zone ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _zones = []);
    } finally {
      if (mounted) setState(() => _loadingZones = false);
    }
    _syncAddress();
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone; _selectedWoreda = null; _selectedKebele = null; _addressId = null;
      _woredas = []; _kebeles = [];
    });
    if (zone == null || _selectedRegion == null) return;
    setState(() => _loadingWoredas = true);
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getWoredas(region: _selectedRegion!, zone: zone, locale: locale);
      if (mounted && response.success) {
        setState(() => _woredas = response.woredas.map((w) => w.woreda ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _woredas = []);
    } finally {
      if (mounted) setState(() => _loadingWoredas = false);
    }
    _syncAddress();
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda; _selectedKebele = null; _addressId = null;
      _kebeles = [];
    });
    if (woreda == null || _selectedRegion == null || _selectedZone == null) return;
    setState(() => _loadingKebeles = true);
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getKebeles(region: _selectedRegion!, zone: _selectedZone!, woreda: woreda, locale: locale);
      if (mounted && response.success) {
        _kebeleIds.clear();
        final kebeles = response.kebeles.map((k) => k.kebele).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        for (final k in response.kebeles) {
          if (k.kebele != null && k.kebele!.isNotEmpty) _kebeleIds[k.kebele!] = k.id;
        }
        setState(() => _kebeles = kebeles);
      }
    } catch (_) {
      if (mounted) setState(() => _kebeles = []);
    } finally {
      if (mounted) setState(() => _loadingKebeles = false);
    }
    _syncAddress();
  }

  void _onKebeleSelected(String? kebele) {
    setState(() {
      _selectedKebele = kebele;
      _addressId = kebele != null ? _kebeleIds[kebele] : null;
    });
    _syncAddress();
  }

  void _syncAddress() {
    setState(() {
      _formData = _formData.copyWith(
        addressRegion: _selectedRegion ?? '',
        addressZone: _selectedZone ?? '',
        addressWoreda: _selectedWoreda ?? '',
        addressKebele: _selectedKebele ?? '',
        addressId: _addressId,
        specificLocation: _specificLocationController.text,
      );
    });
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 1920);
    if (files.isEmpty) return;
    for (final f in files) {
      if (await f.length() > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.carFileTooLarge(f.name)),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }
    }
    final persisted = await ListingMediaManager.persistFiles(files);
    setState(() => _formData = _formData.copyWith(images: [..._formData.images, ...persisted]));
  }

  Future<void> _cleanupImages() async {
    for (final file in _formData.images) {
      try {
        final f = File(file.path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<void> _submit() async {
    if (!_formData.termsAccepted) return;
    setState(() => _isSubmitting = true);
    final response = await ref.read(carServiceProvider).createListing(formData: _formData);
    setState(() => _isSubmitting = false);
    if (response.success && mounted) {
      await _cleanupImages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.listingCreated)));
        context.pop();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);
    final subState = ref.watch(subscriptionProvider);
    final kycState = ref.watch(kycStatusProvider);
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => false,
    );
    if (subState.isLoading || kycState.isLoading || settingsAsync.isLoading) {
      return _buildSkeleton();
    }

    if (kycState.hasError) {
      return WaveMessageScreen.error(
        title: l10n.kycConnectionErrorTitle,
        subtitle: kycState.errorMessage ?? l10n.kycConnectionErrorSubtitle,
        onRetry: () => ref.read(kycStatusProvider.notifier).loadKycStatus(),
      );
    }

    if (subState.hasError) {
      return WaveMessageScreen.error(
        title: l10n.errorSubscription,
        subtitle: subState.errorMessage!,
        onRetry: () => ref.read(subscriptionProvider.notifier).refresh(),
      );
    }

    if (!kycState.isVerified && !kycState.isApproved) {
      return WaveFullPageUpgrade(
        appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
        icon: Icons.verified_outlined,
        iconColor: AppColors.accent500,
        title: kycState.isPending
            ? l10n.kycPendingTitle
            : l10n.kycRequiredTitle,
        subtitle: kycState.isPending
            ? l10n.kycPendingSubtitleReview
            : l10n.kycRequiredSubtitlePost,
        buttonLabel: kycState.isPending ? '' : l10n.kycVerifyNow,
        onButtonTap: kycState.isPending
            ? null
            : () => context.push('/kyc'),
      );
    }

    if (subscriptionEnabled && !subState.canCreateListing) {
      final (:title, :subtitle) = _listingGateMessage(subState, l10n);
      return WaveFullPageUpgrade(
        appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
        icon: Icons.add_home_work_outlined,
        iconColor: AppColors.accent500,
        title: title,
        subtitle: subtitle,
      );
    }

    final stepLabels = [l10n.listingStepDetails, l10n.listingPricing, l10n.listingDescriptionLabel];
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _prevStep,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
                )
              : null,
          title: Text(l10n.listingsCreate),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: Text(_currentStep == 2 ? l10n.listingSubmit : l10n.listingNext),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStepIndicator(stepLabels),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Details(l10n),
                  _buildStep2Pricing(l10n),
                  _buildStep3Publish(l10n),
                ],
              ),
            ),
            if (_stepErrors[_currentStep] != null && _stepErrors[_currentStep]!.isNotEmpty)
              _buildErrorBanner(_stepErrors[_currentStep]!),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(List<String> steps) {
    return Container(
      color: context.scaffoldBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: context.divider,
            valueColor: AlwaysStoppedAnimation<Color>(context.isDarkMode ? AppColors.accent400 : AppColors.primary950),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              final isCompleted = i < _currentStep;
              final isCurrent = i == _currentStep;
              return Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent ? Theme.of(context).colorScheme.primary : context.divider,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text('${i + 1}', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: isCurrent ? Colors.white : context.theme.textMuted)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(steps[i], style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                        color: isCurrent ? Theme.of(context).colorScheme.primary : context.theme.textMuted,
                      ), overflow: TextOverflow.ellipsis),
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

  Widget _buildMakeDropdown() {
    final makes = makesForCategory(_formData.vehicleCategory).toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${l10n.listingMake} *', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
        const SizedBox(height: 4),
        if (_isCustomMake)
          TextFormField(
            autofocus: true,
            style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.carEnterMakeName,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onChanged: (v) => _formData = _formData.copyWith(make: v),
          )
        else
          DropdownButtonFormField<String>(
            key: ValueKey('make_dropdown_${_formData.vehicleCategory}'),
            initialValue: vehicleModelsByCategoryMake[_formData.vehicleCategory]?.containsKey(_formData.make) == true ? _formData.make : null,
            style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            dropdownColor: context.sheetBg,
            items: [
              ...makes.map((m) => DropdownMenuItem(value: m, child: Text(m))),
              DropdownMenuItem(value: '__other__', child: Text(l10n.listingOther)),
            ],
            onChanged: (v) {
              if (v == '__other__') {
                setState(() {
                  _isCustomMake = true;
                  _isCustomModel = true;
                  _formData = _formData.copyWith(make: '', model: '');
                });
              } else {
                setState(() {
                  _isCustomMake = false;
                  _isCustomModel = false;
                  _formData = _formData.copyWith(make: v!, model: '');
                });
              }
            },
            isExpanded: true,
          ),
      ],
    );
  }

  Widget _buildModelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${l10n.listingModel} *', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
        const SizedBox(height: 4),
        if (_isCustomModel)
          TextFormField(
            autofocus: true,
            style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.carEnterModelName,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onChanged: (v) => _formData = _formData.copyWith(model: v),
          )
        else
          DropdownButtonFormField<String>(
            key: ValueKey('model_dropdown_${_formData.vehicleCategory}_${_formData.make}'),
            initialValue: _availableModels.contains(_formData.model) ? _formData.model : null,
            style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            dropdownColor: context.sheetBg,
            items: [
              ..._availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))),
              if (_formData.make.isNotEmpty)
                DropdownMenuItem(value: '__other__', child: Text(l10n.listingOther)),
            ],
            onChanged: (v) {
              if (v == '__other__') {
                setState(() {
                  _isCustomModel = true;
                  _formData = _formData.copyWith(model: '');
                });
              } else {
                setState(() {
                  _isCustomModel = false;
                  _formData = _formData.copyWith(model: v!);
                });
              }
            },
            isExpanded: true,
          ),
      ],
    );
  }

  Widget _buildStep1Details(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          _sectionCard(
            title: l10n.listingVehicleCategory,
            child: Column(
              children: [
                _buildCompactDropdown(label: l10n.listingVehicleCategory, value: _formData.vehicleCategory, options: vehicleCategories, onChanged: (v) => _formData = _formData.copyWith(vehicleCategory: v, bodyType: ''), displayBuilder: (c) => vehicleCategoryLabel(c, l10n)),
                if (_formData.vehicleCategory == 'car' || _formData.vehicleCategory == 'construction_equipment') ...[
                  const SizedBox(height: 12),
                  _buildCompactDropdown(label: l10n.listingBodyType, value: _formData.bodyType, options: bodyTypesByCategory[_formData.vehicleCategory] ?? [], onChanged: (v) => _formData = _formData.copyWith(bodyType: v), displayBuilder: (bt) => bodyTypeLabel(bt, l10n)),
                ],
                if (_formData.vehicleCategory == 'car' || _formData.vehicleCategory == 'construction_equipment') ...[
                  const SizedBox(height: 12),
                  _buildCompactField(label: l10n.listingVin, value: _formData.vin, onChanged: (v) => _formData = _formData.copyWith(vin: v)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingMakeModel,
            child: Column(
              children: [
                _buildMakeDropdown(),
                const SizedBox(height: 12),
                _buildModelDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingSpecifications,
            child: Column(
              children: [
                if (_formData.vehicleCategory != 'bicycle') ...[
                  Row(
                    children: [
                      Expanded(child: _buildYearField(l10n)),
                      if (_formData.vehicleCategory != 'bicycle') ...[
                        const SizedBox(width: 12),
                        Expanded(child: _buildCompactField(label: '${l10n.listingMileage} (${mileageUnitByCategory[_formData.vehicleCategory] ?? 'km'})', value: _formData.mileageKm, onChanged: (v) => _formData = _formData.copyWith(mileageKm: v), keyboardType: TextInputType.number)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(child: _buildCompactField(label: l10n.listingColor, value: _formData.color, onChanged: (v) => _formData = _formData.copyWith(color: v))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCompactDropdown(label: l10n.listingCondition, value: _formData.condition, options: carConditions, onChanged: (v) => _formData = _formData.copyWith(condition: v), displayBuilder: (c) => conditionLabel(c, l10n))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep2Pricing(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          _sectionCard(
            title: l10n.listingListingType,
            child: Row(
              children: [
                _typeChoiceChip(selected: !_formData.isForRent, label: l10n.listingForSale, icon: Icons.sell_outlined, onTap: () => setState(() => _formData = _formData.copyWith(isForRent: false))),
                const SizedBox(width: 12),
                _typeChoiceChip(selected: _formData.isForRent, label: l10n.listingForRent, icon: Icons.key, onTap: () => setState(() => _formData = _formData.copyWith(isForRent: true))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingPricing,
            child: _formData.isForRent
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: context.theme.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(l10n.carRentalPriceNegotiable, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                        ),
                      ],
                    ),
                  )
                : _buildCompactField(label: '${l10n.listingPriceEtb} (ETB) *', value: _formData.priceFixed, onChanged: (v) => _formData = _formData.copyWith(priceFixed: v), keyboardType: TextInputType.number),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingLocation,
            subtitle: '${l10n.listingKebele}, ${l10n.listingWoreda}, ${l10n.listingZone}, ${l10n.listingRegion}',
            child: _buildAddressDropdowns(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep3Publish(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          _sectionCard(
            title: l10n.listingDescriptionLabel,
            child: TextFormField(
              initialValue: _formData.description,
              style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.listingDescriptionLabel,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              maxLines: 4,
              onChanged: (v) => _formData = _formData.copyWith(description: v),
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingsKeyFeatures,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: carFeatureOptions.map((f) => FilterChip(
                    label: Text(f, style: AppTextStyles.labelSmall),
                    selected: _formData.features.contains(f),
                    onSelected: (selected) {
                      setState(() {
                        final updated = List<String>.from(_formData.features);
                        if (selected) { updated.add(f); } else { updated.remove(f); }
                        _formData = _formData.copyWith(features: updated);
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _formData.customFeatures,
                  style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.carCustomFeatures,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onChanged: (v) => _formData = _formData.copyWith(customFeatures: v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.photos,
            child: _buildImageUploader(),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingOptions,
            child: Row(
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: _formData.isVip,
                    onChanged: (v) => setState(() => _formData = _formData.copyWith(isVip: v ?? false)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _formData = _formData.copyWith(isVip: !_formData.isVip)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.diamond, size: 16, color: AppColors.vip),
                            const SizedBox(width: 4),
                            Text(l10n.markAsVip, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.vip, letterSpacing: 0.3)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(l10n.carVipSubtitle, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 24, height: 24,
                child: Checkbox(
                  value: _formData.termsAccepted,
                  onChanged: (v) => setState(() => _formData = _formData.copyWith(termsAccepted: v ?? false)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _formData = _formData.copyWith(termsAccepted: !_formData.termsAccepted)),
                  child: Text(l10n.listingAcceptTerms, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: context.theme.textSecondary, letterSpacing: 0.3)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WaveButton(
            text: l10n.listingSubmit,
            icon: Icons.add,
            variant: ButtonVariant.success,
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
            isFullWidth: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    final images = _formData.images;
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: LiquidGlass(
            borderRadius: AppSpacing.borderRadiusMd,
            blur: 20,
            interactive: true,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 36, color: context.theme.iconSecondary),
                const SizedBox(height: 10),
                Text(l10n.carAddPhoto, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary)),
                const SizedBox(height: 4),
                Text(l10n.carPhotoFormatHint, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
              ],
            ),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...images.map((file) => _ImageThumb(
                  file: File(file.path),
                  onRemove: () {
                    final updated = List<XFile>.from(images)..remove(file);
                    setState(() => _formData = _formData.copyWith(images: updated));
                  },
                )),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100, height: 100,
                  child: LiquidGlass(
                    borderRadius: AppSpacing.borderRadiusMd, blur: 20,
                    interactive: true,
                    onTap: _pickImages,
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 28, color: context.theme.iconSecondary),
                        const SizedBox(height: 4),
                        Text(l10n.carAddPhoto, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l10n.listingImagesSelected(images.length), style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
          ),
        ],
      ],
    );
  }

  Widget _sectionCard({required String title, String? subtitle, required Widget child}) {
    return WaveCard(
      useLiquidGlass: true, isGlass: true, padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: context.theme.textSecondary, letterSpacing: 0.3)),
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

  Widget _buildYearField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompactField(label: '${l10n.listingYear} *', value: _formData.year, onChanged: (v) => _formData = _formData.copyWith(year: v), keyboardType: TextInputType.number),
        _buildEthiopianYearSuffix(_formData.year),
      ],
    );
  }

  Widget _buildEthiopianYearSuffix(String yearStr) {
    final year = int.tryParse(yearStr);
    if (year == null || year < 1900) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 4),
      child: Text(
        EthiopianDateHelper.toEthiopianYearSuffix(year),
        style: AppTextStyles.bodySmall.copyWith(fontSize: 9, color: AppColors.accent600),
      ),
    );
  }

  Widget _buildCompactField({required String label, required String value, required ValueChanged<String> onChanged, TextInputType? keyboardType}) {
    return TextFormField(
      key: ValueKey('compact_field_${label}_$value'),
      initialValue: value,
      style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildCompactDropdown({required String label, required String value, required List<String> options, required ValueChanged<String> onChanged, String Function(String)? displayBuilder}) {
    return DropdownButtonFormField<String>(
      key: ValueKey('compact_dropdown_${label}_$value'),
      initialValue: value.isEmpty ? null : value,
      style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dropdownColor: context.sheetBg,
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(displayBuilder != null ? displayBuilder(o) : o, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary)))).toList(),
      onChanged: (v) { if (v != null) setState(() => onChanged(v)); },
      isExpanded: true,
    );
  }

  Widget _compactDropdownField({String? value, required List<String> items, required String label, required Function(String?) onChanged, bool isLoading = false}) {
    final loc = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        suffixIcon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      ),
      dropdownColor: context.sheetBg,
      items: items.isEmpty
          ? [DropdownMenuItem(value: null, child: Text(loc.listingNoOptions, style: AppTextStyles.bodySmall.copyWith(color: context.textMuted)))]
          : items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodySmall))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }

  Widget _buildAddressDropdowns() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _compactDropdownField(value: _selectedRegion, items: _regions, label: l10n.listingRegion, onChanged: _onRegionSelected)),
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
        TextFormField(
          controller: _specificLocationController,
          style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.listingSpecificLocation,
            labelStyle: AppTextStyles.bodySmall,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          onChanged: (_) => _syncAddress(),
        ),
      ],
    );
  }

  Widget _typeChoiceChip({required bool selected, required String label, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: LiquidGlass(
        borderRadius: 4, blur: selected ? 20 : 16,
        variant: selected ? LiquidGlassVariant.prominent : LiquidGlassVariant.regular,
        tint: selected ? AppColors.accent500 : null,
        interactive: true, onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? AppColors.accent500 : context.theme.textMuted),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? AppColors.accent500 : context.theme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(List<String> errors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.errorLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: errors.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(child: Text(e, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  ({String title, String subtitle}) _listingGateMessage(
      SubscriptionState subState, AppLocalizations l10n) {
    if (!subState.hasPaidSubscription) {
      return (
        title: l10n.subscriptionRequiredTitle,
        subtitle: l10n.subscriptionRequiredListingSubtitle,
      );
    }
    final plan = subState.subscription?.plan;
    if (plan == null || plan.maxListings == 0) {
      return (
        title: l10n.subscriptionPlanNotSupportedListing,
        subtitle: l10n.subscriptionPlanNotSupportedListingSubtitle,
      );
    }
    return (
      title: l10n.subscriptionLimitReachedTitle,
      subtitle: l10n.subscriptionLimitReached,
    );
  }

  Widget _buildSkeleton() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(title: Text(l10n.listingsCreate)),
      body: Shimmer.fromColors(
        baseColor: context.shimmerBase,
        highlightColor: context.shimmerHighlight,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 3; i++) ...[
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: context.shimmerHighlight,
                    borderRadius: BorderRadius.circular(4),
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
              const SizedBox(height: 12),
              Container(
                height: 14,
                width: 140,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(4),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImageThumb({required this.file, required this.onRemove});

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          Center(child: InteractiveViewer(
            child: Image.file(file, fit: BoxFit.contain),
          )),
          Positioned(
            top: 40, right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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
            SizedBox(
              width: 100, height: 100,
              child: LiquidGlass(
                borderRadius: 10, blur: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
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
