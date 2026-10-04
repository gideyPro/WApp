import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/listing.dart';
import '../../../data/models/job_form_data.dart';
import '../../../data/job_data.dart';
import '../../../data/services/address_service.dart';
import '../../../data/services/listing_media_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../providers/job_providers.dart';
import '../../providers/app_providers.dart';
import '../listing/widgets/submission_overlay.dart';

class EditJobScreen extends ConsumerStatefulWidget {
  final Listing listing;
  const EditJobScreen({super.key, required this.listing});

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends ConsumerState<EditJobScreen> {
  final _pageController = PageController();
  late JobFormData _formData;
  int _currentStep = 0;
  bool _isSubmitting = false;
  final Map<int, List<String>> _stepErrors = {};
  ValueNotifier<SubmissionState>? _submissionNotifier;
  Future<bool?>? _submissionDismissed;
  bool _postedAsCompany = false;

  AppLocalizations get l10n => AppLocalizations.of(context);

  AddressService get _addressService => ref.read(addressServiceProvider);
  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  final Map<String, int?> _kebeleIds = {};
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;
  int? _addressId;

  late TextEditingController _companyController;
  late TextEditingController _positionsController;
  late TextEditingController _experienceController;
  late TextEditingController _salaryMinController;
  late TextEditingController _salaryMaxController;
  late TextEditingController _descriptionController;
  late TextEditingController _specificLocationController;

  bool get _canModifyMedia => widget.listing.status == ListingStatus.rejected;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _formData = JobFormData(
      companyName: l.jobCompanyName,
      jobType: l.jobType ?? 'full_time',
      jobCategory: l.jobCategory ?? '',
      positionsCount: l.jobPositionsCount ?? 1,
      salaryType: l.jobSalaryType ?? 'per_agreement',
      salaryMin: l.jobSalaryMin,
      salaryMax: l.jobSalaryMax,
      salaryCurrency: l.jobSalaryCurrency ?? 'ETB',
      reqEducation: l.jobReqEducation,
      reqExperience: l.jobReqExperience,
      reqGender: l.jobReqGender ?? 'any',
      description: l.description,
      specificLocation: l.specificLocation,
      addressId: l.addressId,
      termsAccepted: true,
    );
    _postedAsCompany = l.jobCompanyName != null && l.jobCompanyName!.isNotEmpty;

    _companyController = TextEditingController(text: _formData.companyName)
      ..addListener(() => _formData = _formData.copyWith(companyName: _companyController.text));
    _positionsController = TextEditingController(text: _formData.positionsCount.toString())
      ..addListener(() => _formData = _formData.copyWith(positionsCount: int.tryParse(_positionsController.text) ?? 1));
    _experienceController = TextEditingController(text: _formData.reqExperience)
      ..addListener(() => _formData = _formData.copyWith(reqExperience: _experienceController.text));
    _salaryMinController = TextEditingController(text: _formData.salaryMin?.toString() ?? '')
      ..addListener(() => _formData = _formData.copyWith(salaryMin: double.tryParse(_salaryMinController.text.replaceAll(',', ''))));
    _salaryMaxController = TextEditingController(text: _formData.salaryMax?.toString() ?? '')
      ..addListener(() => _formData = _formData.copyWith(salaryMax: double.tryParse(_salaryMaxController.text.replaceAll(',', ''))));
    _descriptionController = TextEditingController(text: _formData.description)
      ..addListener(() => _formData = _formData.copyWith(description: _descriptionController.text));
    _specificLocationController = TextEditingController(text: _formData.specificLocation)
      ..addListener(() => _formData = _formData.copyWith(specificLocation: _specificLocationController.text));

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
        if (_formData.jobCategory.isEmpty) errors.add('${l10n.jobJobCategory} ${l10n.commonIsRequired}');
        if (_formData.jobType.isEmpty) errors.add('${l10n.jobJobType} ${l10n.commonIsRequired}');
        if (_postedAsCompany && _companyController.text.trim().isEmpty) {
          errors.add('${l10n.jobCompanyName} ${l10n.commonIsRequired}');
        }
        break;
      case 1:
        if (_formData.salaryType == 'fixed' && _formData.salaryMin == null) errors.add('${l10n.jobSalaryMin} ${l10n.commonIsRequired}');
        if (_formData.addressId == null) errors.add('${l10n.jobLocation} ${l10n.commonIsRequired}');
        break;
      case 2:
        if (_formData.description == null || _formData.description!.isEmpty) errors.add('${l10n.listingDescriptionLabel} ${l10n.commonIsRequired}');
        break;
    }
    return errors;
  }

  void _onPostedAsCompanyChanged(bool value) {
    setState(() {
      _postedAsCompany = value;
      if (!value) {
        _companyController.clear();
        _formData.companyName = null;
      }
      _stepErrors.remove(0);
    });
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

  Future<void> _loadZones() async {
    if (_selectedRegion == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getZones(region: _selectedRegion!, locale: locale);
      if (mounted && response.success) setState(() => _zones = response.zones.map((z) => z.zone ?? '').where((s) => s.isNotEmpty).toList());
    } catch (_) {}
  }

  Future<void> _loadWoredas() async {
    if (_selectedRegion == null || _selectedZone == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getWoredas(region: _selectedRegion!, zone: _selectedZone!, locale: locale);
      if (mounted && response.success) setState(() => _woredas = response.woredas.map((w) => w.woreda ?? '').where((s) => s.isNotEmpty).toList());
    } catch (_) {}
  }

  Future<void> _loadKebeles() async {
    if (_selectedRegion == null || _selectedZone == null || _selectedWoreda == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    try {
      final response = await _addressService.getKebeles(region: _selectedRegion!, zone: _selectedZone!, woreda: _selectedWoreda!, locale: locale);
      if (mounted && response.success) {
        _kebeleIds.clear();
        final kebeles = response.kebeles.map((k) => k.kebele).where((s) => s != null && s.isNotEmpty).cast<String>().toList();
        for (final k in response.kebeles) {
          if (k.kebele != null && k.kebele!.isNotEmpty) {
            _kebeleIds[k.kebele!] = k.id;
          }
        }
        setState(() => _kebeles = kebeles);
      }
    } catch (_) {}
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null; _selectedWoreda = null; _selectedKebele = null; _addressId = null;
      _zones = []; _woredas = []; _kebeles = [];
      if (region != null) _loadingZones = true;
    });
    if (region != null) await _loadZones();
    if (mounted) setState(() => _loadingZones = false);
    _syncAddress();
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone; _selectedWoreda = null; _selectedKebele = null; _addressId = null;
      _woredas = []; _kebeles = [];
      if (zone != null) _loadingWoredas = true;
    });
    if (zone != null) await _loadWoredas();
    if (mounted) setState(() => _loadingWoredas = false);
    _syncAddress();
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda; _selectedKebele = null; _addressId = null;
      _kebeles = [];
      if (woreda != null) _loadingKebeles = true;
    });
    if (woreda != null) await _loadKebeles();
    if (mounted) setState(() => _loadingKebeles = false);
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
        addressRegion: _selectedRegion != null ? 1 : null,
        addressZone: _selectedZone != null ? 1 : null,
        addressWoreda: _selectedWoreda != null ? 1 : null,
        addressKebele: _selectedKebele != null ? 1 : null,
        addressId: _addressId,
        specificLocation: _specificLocationController.text,
      );
    });
  }

  Future<void> _pickImages() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 1920);
    if (files.isEmpty) return;
    final valid = <XFile>[];
    String? oversized;
    for (final f in files) {
      if (await f.length() > 10 * 1024 * 1024) {
        oversized ??= f.name;
        continue;
      }
      valid.add(f);
    }
    if (oversized != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.mediaFileSizeError(oversized, '10MB')),
        backgroundColor: AppColors.error,
      ));
    }
    if (valid.isEmpty) return;
    final persisted = await ListingMediaManager.persistFiles(valid);
    setState(() => _formData = _formData.copyWith(images: [..._formData.images, ...persisted]));
  }

  Future<void> _submit() async {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    final result = SubmissionOverlay.show(context);
    _submissionNotifier = result.notifier;
    _submissionDismissed = result.dismissed;

    _submissionNotifier!.value = SubmissionState.submitting(
      phase: SubmissionPhase.uploading,
      label: l10n.submissionUploading,
    );

    try {
      final response = await ref.read(jobServiceProvider).updateListing(
        id: widget.listing.id,
        formData: _formData,
        onProgress: (p) {},
      );

      if (!mounted) return;
      if (response.success) {
        ref.read(jobDetailProvider.notifier).refreshListing(widget.listing.id);
        _submissionNotifier!.value = SubmissionState.success(message: l10n.submissionUpdatedMessage, isEdit: true);
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
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _prevStep)
            : null,
        title: Text(l10n.jobEditTitle),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : (_currentStep == 2 ? _submit : _nextStep),
            child: Text(_currentStep == 2 ? l10n.updateListing : l10n.listingNext),
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
              child: Text(_stepErrors[_currentStep]!.join('\n'), style: const TextStyle(color: AppColors.error)),
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
            initialValue: _formData.jobCategory.isEmpty ? null : _formData.jobCategory,
            decoration: InputDecoration(labelText: '${l10n.jobJobCategory} *'),
            items: jobCategories.map((c) => DropdownMenuItem(value: c, child: Text(jobCategoryLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(jobCategory: v ?? '')),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _formData.jobType.isEmpty ? null : _formData.jobType,
            decoration: InputDecoration(labelText: '${l10n.jobJobType} *'),
            items: jobTypes.map((c) => DropdownMenuItem(value: c, child: Text(jobTypeLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(jobType: v ?? '')),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              _postedAsCompany ? Icons.business_rounded : Icons.person_outline_rounded,
              color: _postedAsCompany ? AppColors.accent600 : context.theme.iconSecondary,
            ),
            title: Text(
              l10n.jobPostingAsCompany,
              style: AppTextStyles.labelLarge.copyWith(color: context.theme.textPrimary),
            ),
            value: _postedAsCompany,
            activeThumbColor: AppColors.accent600,
            onChanged: _onPostedAsCompanyChanged,
          ),
          if (_postedAsCompany) ...[
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(labelText: '${l10n.jobCompanyName} *'),
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _positionsController,
            decoration: InputDecoration(labelText: l10n.jobPositions),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _formData.reqEducation,
            decoration: InputDecoration(labelText: l10n.jobEducationLevel),
            items: educationLevels.map((c) => DropdownMenuItem(value: c, child: Text(educationLevelLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(reqEducation: v)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _formData.reqGender,
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
            initialValue: _formData.salaryType,
            decoration: InputDecoration(labelText: '${l10n.jobSalaryType} *'),
            items: salaryTypes.map((c) => DropdownMenuItem(value: c, child: Text(salaryTypeLabel(c, l10n)))).toList(),
            onChanged: (v) => setState(() => _formData = _formData.copyWith(salaryType: v ?? 'per_agreement')),
          ),
          if (_formData.salaryType != 'per_agreement') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _salaryMinController, decoration: InputDecoration(labelText: l10n.jobSalaryMin), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                if (_formData.salaryType == 'range')
                  Expanded(child: TextFormField(controller: _salaryMaxController, decoration: InputDecoration(labelText: l10n.jobSalaryMax), keyboardType: TextInputType.number)),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _sectionCard(
            title: l10n.jobLocation,
            subtitle: '${l10n.listingKebele}, ${l10n.listingWoreda}, ${l10n.listingZone}, ${l10n.listingRegion}',
            child: _buildAddressDropdowns(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          if (_canModifyMedia) ...[
            _sectionCard(
              title: l10n.jobImages,
              child: _buildImageUploader(),
            ),
            const SizedBox(height: 16),
          ] else ...[
            _sectionCard(
              title: l10n.jobImages,
              child: Text(
                l10n.mediaImagesLocked,
                style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: '${l10n.listingDescriptionLabel} *', alignLabelWithHint: true),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    final images = _formData.images;
    return Column(
      children: [
        LiquidGlass(
          borderRadius: AppSpacing.borderRadiusMd,
          blur: 20,
          interactive: true,
          onTap: _pickImages,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 36, color: context.theme.iconSecondary),
              const SizedBox(height: 10),
              Text(l10n.listingTapToAdd, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary)),
              const SizedBox(height: 4),
              Text(l10n.mediaImageFormatHint, style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
            ],
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

  Widget _buildAddressDropdowns() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _compactDropdownField(value: _selectedRegion, items: _regions, label: '${l10n.listingRegion} *', onChanged: _onRegionSelected)),
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
            labelText: l10n.jobSpecificLocation,
            labelStyle: AppTextStyles.bodySmall,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          onChanged: (_) => _syncAddress(),
        ),
      ],
    );
  }

  Widget _compactDropdownField({String? value, required List<String> items, required String label, required Function(String?) onChanged, bool isLoading = false}) {
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
          ? [DropdownMenuItem(value: null, child: Text(l10n.listingSelect, style: AppTextStyles.bodySmall.copyWith(color: context.textMuted)))]
          : items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodySmall))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
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
