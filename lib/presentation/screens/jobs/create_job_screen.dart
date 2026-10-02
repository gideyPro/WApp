import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/job_form_data.dart';
import '../../../data/job_data.dart';
import '../../../data/services/address_service.dart';
import '../../../data/services/listing_media_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../../providers/job_providers.dart';
import '../../providers/app_providers.dart';
import '../../../core/utils/format_utils.dart';
import '../listing/widgets/submission_overlay.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _pageController = PageController();
  late JobFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;
  final Map<int, List<String>> _stepErrors = {};
  String? _currentSubmissionKey;
  ValueNotifier<SubmissionState>? _submissionNotifier;
  Future<bool?>? _submissionDismissed;

  AppLocalizations get l10n => AppLocalizations.of(context);

  AddressService get _addressService => ref.read(addressServiceProvider);
  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  final Map<String, int?> _kebeleIds = {};
  int? _addressId;

  late TextEditingController _companyController;
  late TextEditingController _positionsController;
  late TextEditingController _experienceController;
  late TextEditingController _salaryMinController;
  late TextEditingController _salaryMaxController;
  late TextEditingController _descriptionController;
  late TextEditingController _specificLocationController;

  @override
  void initState() {
    super.initState();
    _formData = JobFormData();
    _companyController = TextEditingController()
      ..addListener(() => _formData = _formData.copyWith(companyName: _companyController.text));
    _positionsController = TextEditingController(text: '1')
      ..addListener(() => _formData = _formData.copyWith(positionsCount: int.tryParse(_positionsController.text) ?? 1));
    _experienceController = TextEditingController()
      ..addListener(() => _formData = _formData.copyWith(reqExperience: _experienceController.text));
    _salaryMinController = TextEditingController()
      ..addListener(() => _formData = _formData.copyWith(salaryMin: double.tryParse(_salaryMinController.text.replaceAll(',', ''))));
    _salaryMaxController = TextEditingController()
      ..addListener(() => _formData = _formData.copyWith(salaryMax: double.tryParse(_salaryMaxController.text.replaceAll(',', ''))));
    _descriptionController = TextEditingController()
      ..addListener(() => _formData = _formData.copyWith(description: _descriptionController.text));
    _specificLocationController = TextEditingController()
      ..addListener(() => _formData = _formData.copyWith(specificLocation: _specificLocationController.text));
      
    _loadRegions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _companyController.dispose();
    _positionsController.dispose();
    _experienceController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _descriptionController.dispose();
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
        if (_formData.jobCategory.isEmpty) errors.add('${'Category'} ${l10n.commonIsRequired}');
        if (_formData.jobType.isEmpty) errors.add('Job Type is required');
        break;
      case 1:
        if (_formData.salaryType == 'fixed' && _formData.salaryMin == null) errors.add('Salary is required');
        if (_formData.addressId == null) errors.add('Location is required');
        break;
      case 2:
        if (_formData.description == null || _formData.description!.isEmpty) errors.add('${l10n.listingDescriptionLabel} ${l10n.commonIsRequired}');
        if (!_formData.termsAccepted) errors.add('Terms must be accepted');
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
    } catch (_) {}
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null; _selectedWoreda = null; _selectedKebele = null; _addressId = null;
      _zones = []; _woredas = []; _kebeles = [];
    });
    if (region == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getZones(region: region, locale: locale);
      if (mounted && response.success) setState(() => _zones = response.zones.map((z) => z.zone ?? '').where((s) => s.isNotEmpty).toList());
    } catch (_) {}
    _syncAddress();
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone; _selectedWoreda = null; _selectedKebele = null; _addressId = null;
      _woredas = []; _kebeles = [];
    });
    if (zone == null || _selectedRegion == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getWoredas(region: _selectedRegion!, zone: zone, locale: locale);
      if (mounted && response.success) setState(() => _woredas = response.woredas.map((w) => w.woreda ?? '').where((s) => s.isNotEmpty).toList());
    } catch (_) {}
    _syncAddress();
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda; _selectedKebele = null; _addressId = null;
      _kebeles = [];
    });
    if (woreda == null || _selectedRegion == null || _selectedZone == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getKebeles(region: _selectedRegion!, zone: _selectedZone!, woreda: woreda, locale: locale);
      if (mounted && response.success) {
        _kebeleIds.clear();
        final kebeles = response.kebeles.map((k) => k.kebele).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        for (final k in response.kebeles) if (k.kebele != null && k.kebele!.isNotEmpty) _kebeleIds[k.kebele!] = k.id;
        setState(() => _kebeles = kebeles);
      }
    } catch (_) {}
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
        addressRegion: _selectedRegion != null ? 1 : null, // Backend uses IDs, but this is mockup
        addressZone: _selectedZone != null ? 1 : null,
        addressWoreda: _selectedWoreda != null ? 1 : null,
        addressKebele: _selectedKebele != null ? 1 : null,
        addressId: _addressId,
      );
    });
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 1920);
    if (files.isEmpty) return;
    final persisted = await ListingMediaManager.persistFiles(files);
    setState(() => _formData = _formData.copyWith(images: [..._formData.images, ...persisted]));
  }

  Future<void> _submit() async {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      return;
    }
    if (!_formData.termsAccepted) return;
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    _currentSubmissionKey = 'sub_${DateTime.now().microsecondsSinceEpoch}';
    final result = SubmissionOverlay.show(context);
    _submissionNotifier = result.notifier;
    _submissionDismissed = result.dismissed;

    _submissionNotifier!.value = SubmissionState.submitting(
      phase: SubmissionPhase.uploading,
      label: l10n.submissionUploading,
    );

    try {
      final response = await ref.read(jobServiceProvider).createListing(
        formData: _formData,
        submissionKey: _currentSubmissionKey,
        onProgress: (p) {},
      );

      if (!mounted) return;
      if (response.success) {
        _submissionNotifier!.value = SubmissionState.success(message: l10n.submissionCreatedMessage);
        final dim = await _submissionDismissed;
        if (mounted && dim == true) Navigator.of(context).pop(true);
      } else {
        _submissionNotifier!.value = SubmissionState.error(message: response.message, onRetry: _submit, onSaveDraft: () => Navigator.of(context).pop(false));
      }
    } catch (e) {
      if (!mounted) return;
      _submissionNotifier!.value = SubmissionState.error(message: e.toString(), onRetry: _submit, onSaveDraft: () => Navigator.of(context).pop(false));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepLabels = [l10n.listingStepDetails, 'Salary & Location', l10n.listingDescriptionLabel];
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _prevStep)
            : null,
        title: Text('Create Job'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : (_currentStep == 2 ? _submit : _nextStep),
            child: Text(_currentStep == 2 ? l10n.listingSubmit : l10n.listingNext),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LinearProgressIndicator(value: (_currentStep + 1) / 3),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          if (_stepErrors[_currentStep] != null && _stepErrors[_currentStep]!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Text(_stepErrors[_currentStep]!.join('\n'), style: TextStyle(color: AppColors.error)),
            )
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _formData.jobCategory.isEmpty ? null : _formData.jobCategory,
            decoration: const InputDecoration(labelText: 'Job Category *'),
            items: jobCategories.map((c) => DropdownMenuItem(value: c, child: Text(jobCategoryLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(jobCategory: v ?? '')),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _formData.jobType.isEmpty ? null : _formData.jobType,
            decoration: const InputDecoration(labelText: 'Job Type *'),
            items: jobTypes.map((c) => DropdownMenuItem(value: c, child: Text(jobTypeLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(jobType: v ?? '')),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyController,
            decoration: const InputDecoration(labelText: 'Company Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _positionsController,
            decoration: const InputDecoration(labelText: 'Number of Positions'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _formData.reqEducation,
            decoration: const InputDecoration(labelText: 'Required Education'),
            items: educationLevels.map((c) => DropdownMenuItem(value: c, child: Text(educationLevelLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(reqEducation: v)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _formData.reqGender,
            decoration: const InputDecoration(labelText: 'Required Gender'),
            items: genderOptions.map((c) => DropdownMenuItem(value: c, child: Text(genderOptionLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(reqGender: v ?? 'any')),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _formData.salaryType,
            decoration: const InputDecoration(labelText: 'Salary Type *'),
            items: salaryTypes.map((c) => DropdownMenuItem(value: c, child: Text(salaryTypeLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(salaryType: v ?? 'per_agreement')),
          ),
          if (_formData.salaryType != 'per_agreement') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _salaryMinController, decoration: const InputDecoration(labelText: 'Min Salary'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                if (_formData.salaryType == 'range')
                  Expanded(child: TextFormField(controller: _salaryMaxController, decoration: const InputDecoration(labelText: 'Max Salary'), keyboardType: TextInputType.number)),
              ],
            ),
          ],
          const SizedBox(height: 32),
          Text('Location', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(labelText: 'Region *'),
            items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: _onRegionSelected,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedZone,
            decoration: const InputDecoration(labelText: 'Zone'),
            items: _zones.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: _onZoneSelected,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedWoreda,
            decoration: const InputDecoration(labelText: 'Woreda'),
            items: _woredas.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: _onWoredaSelected,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedKebele,
            decoration: const InputDecoration(labelText: 'Kebele'),
            items: _kebeles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: _onKebeleSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text('Add Images (${_formData.images.length})'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Job Description *', alignLabelWithHint: true),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('I accept the terms and conditions'),
            value: _formData.termsAccepted,
            onChanged: (v) => setState(() => _formData = _formData.copyWith(termsAccepted: v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
