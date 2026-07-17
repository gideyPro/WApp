import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/listing.dart';
import '../../../data/models/car_form_data.dart';
import '../../../data/services/address_service.dart';
import '../../../data/services/listing_media_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../providers/car_providers.dart';
import '../../providers/app_providers.dart';
import 'car_strings.dart';

class EditCarScreen extends ConsumerStatefulWidget {
  final Listing listing;
  const EditCarScreen({super.key, required this.listing});

  @override
  ConsumerState<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends ConsumerState<EditCarScreen> {
  final _pageController = PageController();
  late CarFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;
  final Map<int, List<String>> _stepErrors = {};

  static const _transmissions = ['manual', 'automatic', 'semi-automatic'];
  static const _bodyTypes = ['sedan', 'SUV', 'hatchback', 'pickup', 'coupe', 'convertible', 'van', 'minibus', 'truck', 'bus', 'other'];
  static const _fuelTypes = ['gasoline', 'diesel', 'electric', 'hybrid', 'CNG', 'other'];
  static const _conditions = ['new', 'used'];
  static const _rentalPeriods = ['day', 'month', 'year'];
  static const _featureOptions = ['AC', 'Power Steering', 'Central Locking', 'Power Windows', 'ABS', 'Airbag', 'Sunroof', 'Bluetooth', 'Backup Camera', 'Navigation', 'Cruise Control', 'Leather Seats', 'Alloy Wheels', 'Fog Lights', 'Roof Rack', 'Tow Bar'];

  static const _modelsByMake = {
    'Toyota': ['Corolla', 'Camry', 'Yaris', 'Hilux', 'Land Cruiser', 'RAV4', 'Vitz', 'Premio', 'Noah', 'Hiace', 'Prado', 'Fortuner'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Fit', 'City', 'Odyssey', 'Stepwgn'],
    'Nissan': ['Sunny', 'Altima', 'Patrol', 'X-Trail', 'Pathfinder', 'Navara', 'Juke'],
    'Mitsubishi': ['Pajero', 'Lancer', 'Montero', 'Outlander', 'Delica', 'Mirage'],
    'Suzuki': ['Swift', 'Alto', 'Vitara', 'Jimny', 'S-Cross', 'Celerio', 'Ertiga'],
    'Hyundai': ['Elantra', 'Tucson', 'Sonata', 'Santa Fe', 'i10', 'i20', 'Grand i10'],
    'Kia': ['Sportage', 'Sorento', 'Rio', 'Optima', 'Cerato', 'Picanto'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo', 'Beetle', 'Jetta'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'A-Class', 'G-Class'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', '7 Series', 'X1', 'X6'],
    'Ford': ['Escape', 'Explorer', 'Focus', 'Ranger', 'Mustang', 'F-150'],
    'Chevrolet': ['Cruze', 'Malibu', 'Tahoe', 'Trailblazer', 'Camaro'],
    'Isuzu': ['D-Max', 'MU-X', 'Forward', 'Elf'],
    'Mazda': ['CX-5', 'Mazda3', 'Mazda6', 'BT-50', 'CX-9'],
    'Subaru': ['Forester', 'Outback', 'Impreza', 'Legacy', 'XV'],
    'Lexus': ['RX', 'ES', 'NX', 'LX', 'GX'],
    'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Evoque', 'Velar'],
    'Peugeot': ['205', '206', '307', '308', 'Partner', '3008'],
    'Renault': ['Clio', 'Megane', 'Logan', 'Duster', 'Sandero', 'Fluence'],
    'Fiat': ['500', 'Punto', 'Doblo', 'Panda', 'Uno'],
  };

  bool _isCustomMake = false;
  bool _isCustomModel = false;

  List<String> get _availableModels => _modelsByMake[_formData.make] ?? [];

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
    final l = widget.listing;
    final makeInList = _modelsByMake.containsKey(l.carMake);
    final modelInList = makeInList && (_modelsByMake[l.carMake]?.contains(l.carModel) ?? false);

    _formData = CarFormData(
      make: l.carMake ?? '',
      model: l.carModel ?? '',
      year: l.carYear?.toString() ?? '',
      mileageKm: l.carMileageKm?.toString() ?? '',
      transmission: l.carTransmission ?? '',
      bodyType: l.carBodyType ?? '',
      fuelType: l.carFuelType ?? '',
      engineSize: l.carEngineSize?.toString() ?? '',
      color: l.carColor ?? '',
      condition: l.carCondition ?? '',
      vin: l.carVin ?? '',
      doors: l.carDoors?.toString() ?? '',
      seats: l.carSeats?.toString() ?? '',
      features: l.carFeatures ?? [],
      isForRent: l.listingType == ListingType.rental,
      rentalPeriodUnit: l.rentalPeriodUnit?.toString().split('.').last ?? '',
      priceFixed: l.priceFixed?.toString() ?? '',
      addressId: l.addressId,
      specificLocation: l.specificLocation ?? '',
      description: l.description ?? '',
      existingImages: l.images,
      isVip: l.isVip,
      termsAccepted: true,
    );

    _isCustomMake = !makeInList && (l.carMake?.isNotEmpty ?? false);
    _isCustomModel = !modelInList && (l.carModel?.isNotEmpty ?? false);

    _specificLocationController = TextEditingController(text: l.specificLocation ?? '');
    _selectedRegion = l.address?.region;
    _selectedZone = l.address?.zone;
    _selectedWoreda = l.address?.woreda;
    _selectedKebele = l.address?.kebele;
    _addressId = l.address?.id ?? l.addressId;

    _loadRegions().then((_) {
      if (_selectedRegion != null) _loadZones();
      if (_selectedZone != null) _loadWoredas();
      if (_selectedWoreda != null) _loadKebeles();
    });
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
        if (_formData.make.isEmpty) errors.add('Make is required');
        if (_formData.model.isEmpty) errors.add('Model is required');
        if (_formData.year.isEmpty) errors.add('Year is required');
        break;
      case 1:
        if (_formData.priceFixed.isEmpty) errors.add('Price is required');
        if (_formData.addressId == null) errors.add('Please select a location (Kebele)');
        break;
      case 2:
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

  Future<void> _loadZones() async {
    if (_selectedRegion == null) return;
    setState(() => _loadingZones = true);
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getZones(region: _selectedRegion!, locale: locale);
      if (mounted && response.success) {
        setState(() => _zones = response.zones.map((z) => z.zone ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _zones = []);
    } finally {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  Future<void> _loadWoredas() async {
    if (_selectedRegion == null || _selectedZone == null) return;
    setState(() => _loadingWoredas = true);
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getWoredas(region: _selectedRegion!, zone: _selectedZone!, locale: locale);
      if (mounted && response.success) {
        setState(() => _woredas = response.woredas.map((w) => w.woreda ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _woredas = []);
    } finally {
      if (mounted) setState(() => _loadingWoredas = false);
    }
  }

  Future<void> _loadKebeles() async {
    if (_selectedRegion == null || _selectedZone == null || _selectedWoreda == null) return;
    setState(() => _loadingKebeles = true);
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getKebeles(region: _selectedRegion!, zone: _selectedZone!, woreda: _selectedWoreda!, locale: locale);
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
            content: Text('${f.name} exceeds 10MB limit'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }
    }
    final persisted = await ListingMediaManager.persistFiles(files);
    setState(() => _formData = _formData.copyWith(images: [..._formData.images, ...persisted]));
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final response = await ref.read(carServiceProvider).updateListing(
      listingId: widget.listing.id,
      formData: _formData,
    );
    setState(() => _isSubmitting = false);
    if (response.success && mounted) {
      ref.read(carDetailProvider.notifier).refreshListing(widget.listing.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(CarStrings.listingUpdated)));
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);
    final rentalEnabled = settingsAsync.maybeWhen(
      data: (data) => data['rental_enabled'] == true,
      orElse: () => false,
    );
    final stepLabels = [CarStrings.listingDetail, CarStrings.listingPricing, CarStrings.listingDescription];
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
          title: Text(CarStrings.editListing),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: Text(_currentStep == 2 ? 'Update' : 'Next'),
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
                  _buildStep2Pricing(l10n, rentalEnabled),
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
    final makes = _modelsByMake.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${CarStrings.listingMake} *', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _isCustomMake ? null : (_modelsByMake.containsKey(_formData.make) ? _formData.make : null),
          style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
          dropdownColor: context.sheetBg,
          items: [
            ...makes.map((m) => DropdownMenuItem(value: m, child: Text(m))),
            const DropdownMenuItem(value: '__other__', child: Text('Other')),
          ],
          onChanged: (v) {
            if (v == '__other__') {
              setState(() {
                _isCustomMake = true;
                _isCustomModel = false;
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
        if (_isCustomMake) ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _formData.make,
            autofocus: true,
            style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Enter make name',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onChanged: (v) => _formData = _formData.copyWith(make: v),
          ),
        ],
      ],
    );
  }

  Widget _buildModelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${CarStrings.listingModel} *', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _isCustomModel ? null : (_availableModels.contains(_formData.model) ? _formData.model : null),
          style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
          dropdownColor: context.sheetBg,
          items: [
            ..._availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))),
            if (_formData.make.isNotEmpty && !_isCustomMake)
              const DropdownMenuItem(value: '__other__', child: Text('Other')),
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
        if (_isCustomModel) ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _formData.model,
            autofocus: true,
            style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Enter model name',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onChanged: (v) => _formData = _formData.copyWith(model: v),
          ),
        ],
      ],
    );
  }

  Widget _buildStep1Details(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          _sectionCard(
            title: CarStrings.listingDetail,
            child: Column(
              children: [
                _buildMakeDropdown(),
                const SizedBox(height: 12),
                _buildModelDropdown(),
                const SizedBox(height: 12),
                _buildCompactField(label: '${CarStrings.listingYear} *', value: _formData.year, onChanged: (v) => _formData = _formData.copyWith(year: v), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildCompactDropdown(label: CarStrings.listingTransmission, value: _formData.transmission, options: _transmissions, onChanged: (v) => _formData = _formData.copyWith(transmission: v)),
                const SizedBox(height: 12),
                _buildCompactDropdown(label: CarStrings.listingBodyType, value: _formData.bodyType, options: _bodyTypes, onChanged: (v) => _formData = _formData.copyWith(bodyType: v)),
                const SizedBox(height: 12),
                _buildCompactDropdown(label: CarStrings.listingFuelType, value: _formData.fuelType, options: _fuelTypes, onChanged: (v) => _formData = _formData.copyWith(fuelType: v)),
                const SizedBox(height: 12),
                _buildCompactField(label: '${CarStrings.listingMileage} (km)', value: _formData.mileageKm, onChanged: (v) => _formData = _formData.copyWith(mileageKm: v), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildCompactField(label: '${CarStrings.listingEngineSize} (L)', value: _formData.engineSize, onChanged: (v) => _formData = _formData.copyWith(engineSize: v), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildCompactField(label: CarStrings.listingColor, value: _formData.color, onChanged: (v) => _formData = _formData.copyWith(color: v)),
                const SizedBox(height: 12),
                _buildCompactDropdown(label: CarStrings.listingCondition, value: _formData.condition, options: _conditions, onChanged: (v) => _formData = _formData.copyWith(condition: v)),
                const SizedBox(height: 12),
                _buildCompactField(label: 'VIN', value: _formData.vin, onChanged: (v) => _formData = _formData.copyWith(vin: v)),
                const SizedBox(height: 12),
                _buildCompactField(label: CarStrings.listingDoors, value: _formData.doors, onChanged: (v) => _formData = _formData.copyWith(doors: v), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildCompactField(label: CarStrings.listingSeats, value: _formData.seats, onChanged: (v) => _formData = _formData.copyWith(seats: v), keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: WaveButton(
              text: 'Next', icon: Icons.arrow_forward,
              variant: ButtonVariant.primary,
              onPressed: _nextStep, isFullWidth: true,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep2Pricing(AppLocalizations l10n, bool rentalEnabled) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          if (rentalEnabled)
            _sectionCard(
              title: CarStrings.listingType,
              child: Row(
                children: [
                  _typeChoiceChip(selected: !_formData.isForRent, label: CarStrings.forSale, icon: Icons.sell_outlined, onTap: () => setState(() => _formData = _formData.copyWith(isForRent: false))),
                  const SizedBox(width: 12),
                  _typeChoiceChip(selected: _formData.isForRent, label: CarStrings.forRent, icon: Icons.key, onTap: () => setState(() => _formData = _formData.copyWith(isForRent: true))),
                ],
              ),
            ),
          if (rentalEnabled) const SizedBox(height: 16),
          _sectionCard(
            title: CarStrings.listingPricing,
            child: Column(
              children: [
                _buildCompactField(label: _formData.isForRent ? '${CarStrings.monthlyRent} *' : '${CarStrings.price} (ETB) *', value: _formData.priceFixed, onChanged: (v) => _formData = _formData.copyWith(priceFixed: v), keyboardType: TextInputType.number),
                if (_formData.isForRent) ...[
                  const SizedBox(height: 12),
                  _buildCompactDropdown(label: CarStrings.rentalPeriodUnit, value: _formData.rentalPeriodUnit, options: _rentalPeriods, onChanged: (v) => _formData = _formData.copyWith(rentalPeriodUnit: v)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: l10n.listingLocation,
            subtitle: '${l10n.listingKebele}, ${l10n.listingWoreda}, ${l10n.listingZone}, ${l10n.listingRegion}',
            child: _buildAddressDropdowns(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: WaveButton(
              text: 'Next', icon: Icons.arrow_forward,
              variant: ButtonVariant.primary,
              onPressed: _nextStep, isFullWidth: true,
            ),
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
            title: CarStrings.listingDescription,
            child: TextFormField(
              initialValue: _formData.description,
              style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
              decoration: const InputDecoration(
                hintText: CarStrings.listingDescription,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              maxLines: 4,
              onChanged: (v) => _formData = _formData.copyWith(description: v),
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: CarStrings.listingFeatures,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: _featureOptions.map((f) => FilterChip(
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
                  decoration: const InputDecoration(
                    hintText: CarStrings.customFeatures,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onChanged: (v) => _formData = _formData.copyWith(customFeatures: v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildImagesSection(),
          const SizedBox(height: 16),
          _sectionCard(
            title: CarStrings.listingOptions,
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
                            Text('Mark as VIP', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.vip, letterSpacing: 0.3)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Get a VIP badge for premium visibility', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WaveButton(
            text: CarStrings.updateListing,
            icon: Icons.check,
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

  Widget _buildImagesSection() {
    final newImages = _formData.images;
    final existingImages = _formData.existingImages;
    final totalCount = existingImages.length - _formData.removedImageIds.length + newImages.length;

    return _sectionCard(
      title: CarStrings.photos,
      child: Column(
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
                  Text(CarStrings.addPhotos, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary)),
                  const SizedBox(height: 4),
                  Text('JPEG, PNG, WebP — Max 10MB each', style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
                ],
              ),
            ),
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...existingImages
                      .where((img) => !_formData.removedImageIds.contains(img.id))
                      .map((img) => _ImageThumb(
                        url: img.imageUrl,
                        onRemove: () {
                          final removedIds = List<int>.from(_formData.removedImageIds)..add(img.id);
                          setState(() => _formData = _formData.copyWith(removedImageIds: removedIds));
                        },
                      )),
                  ...newImages.map((file) => _ImageThumb(
                    file: File(file.path),
                    onRemove: () {
                      final updated = List<XFile>.from(newImages)..remove(file);
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
                          Text('Add', style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('$totalCount image(s)', style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
            ),
          ],
        ],
      ),
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

  Widget _buildCompactField({required String label, required String value, required ValueChanged<String> onChanged, TextInputType? keyboardType}) {
    return TextFormField(
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

  Widget _buildCompactDropdown({required String label, required String value, required List<String> options, required ValueChanged<String> onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dropdownColor: context.sheetBg,
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textPrimary)))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
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
}

class _ImageThumb extends StatelessWidget {
  final String? url;
  final File? file;
  final VoidCallback onRemove;

  const _ImageThumb({this.url, this.file, required this.onRemove});

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          Center(child: InteractiveViewer(
            child: url != null ? Image.network(url!, fit: BoxFit.contain) : Image.file(file!, fit: BoxFit.contain),
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
                  child: url != null
                      ? Image.network(url!, width: 100, height: 100, fit: BoxFit.cover)
                      : Image.file(file!, width: 100, height: 100, fit: BoxFit.cover),
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
