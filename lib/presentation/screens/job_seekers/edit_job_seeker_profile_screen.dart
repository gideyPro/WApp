import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/job_data.dart';
import '../../providers/job_seeker_providers.dart';
import '../../../data/models/job_seeker_profile.dart';
import '../../../data/models/job_requirement_item.dart';
import '../../../l10n/app_localizations.dart';

class EditJobSeekerProfileScreen extends ConsumerStatefulWidget {
  const EditJobSeekerProfileScreen({super.key});

  @override
  ConsumerState<EditJobSeekerProfileScreen> createState() => _EditJobSeekerProfileScreenState();
}

class _EditJobSeekerProfileScreenState extends ConsumerState<EditJobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _educationCustomController = TextEditingController();

  String? _category;
  String? _education;
  bool _isPublic = true;
  File? _selectedImage;
  File? _selectedCv;
  bool _isSubmitting = false;
  bool _formPopulated = false;

  List<EducationItem> _educations = [];
  List<ExperienceItem> _experiences = [];

  @override
  void dispose() {
    _fullNameController.dispose();
    _titleController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _educationCustomController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path != null) {
      setState(() {
        _selectedCv = File(path);
      });
    }
  }

  void _populateForm(JobSeekerProfile profile) {
    if (_formPopulated) return;
    _formPopulated = true;

    _fullNameController.text = profile.fullName;
    _titleController.text = profile.professionalTitle;
    _category = profile.jobCategory;

    final edu = profile.educationLevel;
    if (edu.isNotEmpty && edu != 'other' && !educationLevels.contains(edu)) {
      _education = 'other';
      _educationCustomController.text = edu;
    } else {
      _education = edu;
    }
    _experienceController.text = profile.experience ?? '';
    _descriptionController.text = profile.description ?? '';
    _isPublic = profile.isPublic;

    if (profile.educations != null && profile.educations!.isNotEmpty) {
      _educations = List.from(profile.educations!);
    } else if (profile.educationLevel.isNotEmpty && profile.educationLevel != 'other') {
      _educations = [EducationItem(educationLevel: profile.educationLevel)];
    }

    if (profile.experiences != null && profile.experiences!.isNotEmpty) {
      _experiences = List.from(profile.experiences!);
    }
  }

  void _showAddEducationDialog() {
    final l10n = AppLocalizations.of(context);
    String selectedLevel = 'bachelors';
    final fieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.jobCategoryEducation),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedLevel,
                decoration: InputDecoration(labelText: l10n.jobEducationLevel),
                items: educationLevels.map((lvl) {
                  return DropdownMenuItem(
                    value: lvl,
                    child: Text(educationLevelLabel(lvl, l10n)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedLevel = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fieldController,
                decoration: const InputDecoration(
                  labelText: 'Field of Study (e.g. Accounting, CS)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                final field = fieldController.text.trim();
                setState(() {
                  _educations.add(EducationItem(
                    educationLevel: selectedLevel,
                    fieldOfStudy: field.isNotEmpty ? field : null,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExperienceDialog() {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final yearsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.seekerExperience),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: l10n.jobJobTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: companyController,
              decoration: InputDecoration(labelText: l10n.jobCompanyName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Years of Experience'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final comp = companyController.text.trim();
              final yrs = double.tryParse(yearsController.text.trim());
              if (title.isNotEmpty || comp.isNotEmpty) {
                setState(() {
                  _experiences.add(ExperienceItem(
                    jobTitle: title.isNotEmpty ? title : null,
                    company: comp.isNotEmpty ? comp : null,
                    years: yrs,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(JobSeekerProfile? existing) async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _isSubmitting = true);

    final customEdu = _educationCustomController.text.trim();
    final primaryEdu = _educations.isNotEmpty
        ? _educations.first.educationLevel
        : (_education == 'other' ? (customEdu.isEmpty ? 'other' : customEdu) : (_education ?? 'bachelors'));

    final data = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'professional_title': _titleController.text.trim(),
      'job_category': _category?.trim() ?? '',
      'education_level': primaryEdu,
      if (_educations.isNotEmpty)
        'educations': _educations.map((e) => e.toJson()).toList(),
      if (_experiences.isNotEmpty)
        'experiences': _experiences.map((e) => e.toJson()).toList(),
      'experience': _experienceController.text.trim(),
      'description': _descriptionController.text.trim(),
      'is_public': _isPublic ? '1' : '0',
    };

    final response = await ref.read(jobSeekerServiceProvider).createOrUpdateProfile(
      data: data,
      photo: _selectedImage,
      cv: _selectedCv,
      update: existing != null,
    );

    setState(() => _isSubmitting = false);

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.seekerProfileSaved)),
      );
      ref.invalidate(myJobSeekerProfileProvider);
      ref.invalidate(jobSeekerProfilesProvider);
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? l10n.commonError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myProfileAsync = ref.watch(myJobSeekerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(title: Text(l10n.seekerMyProfile)),
      body: myProfileAsync.when(
        data: (profile) {
          if (profile != null) _populateForm(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (profile?.photo != null ? NetworkImage(profile!.photo!) : null) as ImageProvider?,
                          child: (_selectedImage == null && profile?.photo == null)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.accent600,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(l10n.seekerFullName, _fullNameController, required: true),
                  _buildTextField(l10n.seekerProfessionalTitle, _titleController, required: true),
                  _buildDropdown(
                    label: l10n.jobJobCategory,
                    value: _category,
                    items: _withExisting(_category, jobCategories),
                    onChanged: (val) => setState(() => _category = val),
                    itemLabel: (cat) => jobCategoryLabel(cat, l10n),
                  ),

                  // Educations Section
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.jobCategoryEducation, style: AppTextStyles.labelLarge),
                      TextButton.icon(
                        onPressed: _showAddEducationDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Education'),
                      ),
                    ],
                  ),
                  if (_educations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No education credentials added yet.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.stone500),
                      ),
                    )
                  else
                    ..._educations.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final edu = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.school, size: 20, color: AppColors.accent600),
                          title: Text(edu.displayLabel(l10n)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            onPressed: () => setState(() => _educations.removeAt(idx)),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 16),
                  // Experiences Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.seekerExperience, style: AppTextStyles.labelLarge),
                      TextButton.icon(
                        onPressed: _showAddExperienceDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Experience'),
                      ),
                    ],
                  ),
                  if (_experiences.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No work history added yet.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.stone500),
                      ),
                    )
                  else
                    ..._experiences.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final exp = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.work, size: 20, color: AppColors.accent600),
                          title: Text(exp.displayLabel()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            onPressed: () => setState(() => _experiences.removeAt(idx)),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 12),
                  _buildTextField(l10n.seekerExperience, _experienceController, maxLines: 3),
                  _buildTextField(l10n.jobDescription, _descriptionController, maxLines: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickCv,
                          icon: const Icon(Icons.upload_file, size: 20),
                          label: Text(l10n.seekerUploadCv),
                        ),
                        if (_selectedCv != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedCv!.path.split('/').last,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => setState(() => _selectedCv = null),
                                ),
                              ],
                            ),
                          )
                        else if (profile?.cv != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  profile!.cv!.split('/').last,
                                  style: const TextStyle(fontSize: 13, color: AppColors.stone500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text(l10n.seekerMakePublic),
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submit(profile),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.seekerSaveProfile),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<String> _withExisting(String? existing, List<String> base) {
    if (existing == null || existing.isEmpty || base.contains(existing)) return base;
    return [...base, existing];
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
        ),
        validator: required
            ? (val) => val == null || val.trim().isEmpty ? '$label ${l10n.commonIsRequired}' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String Function(String) itemLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemLabel(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
