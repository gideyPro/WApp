import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/job_data.dart';
import '../../providers/job_seeker_providers.dart';
import '../../../data/models/job_seeker_profile.dart';
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

  String? _category;
  String? _education;
  bool _isPublic = true;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _titleController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _populateForm(JobSeekerProfile profile) {
    _fullNameController.text = profile.fullName;
    _titleController.text = profile.professionalTitle;
    _category = profile.jobCategory;
    _education = profile.educationLevel;
    _experienceController.text = profile.experience ?? '';
    _descriptionController.text = profile.description ?? '';
    _isPublic = profile.isPublic;
  }

  Future<void> _submit(JobSeekerProfile? existing) async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _isSubmitting = true);

    final data = {
      'full_name': _fullNameController.text.trim(),
      'professional_title': _titleController.text.trim(),
      'job_category': _category?.trim() ?? '',
      'education_level': _education ?? '',
      'experience': _experienceController.text.trim(),
      'description': _descriptionController.text.trim(),
      'is_public': _isPublic ? '1' : '0',
    };

    final response = await ref.read(jobSeekerServiceProvider).createOrUpdateProfile(
      data: data,
      photo: _selectedImage,
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
          if (profile != null && _fullNameController.text.isEmpty && _titleController.text.isEmpty) {
            _populateForm(profile);
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.stone200,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : (profile?.photo != null
                                ? NetworkImage(profile!.photo!)
                                : null),
                        child: _selectedImage == null && profile?.photo == null
                            ? const Icon(Icons.add_a_photo, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(l10n.seekerFullName, _fullNameController, required: true),
                  _buildTextField(l10n.seekerProfessionalTitle, _titleController, required: true),
                  _buildDropdown(
                    label: l10n.jobJobCategory,
                    value: _category,
                    items: _withExisting(_category, jobCategories),
                    labelFor: (v) => jobCategoryLabel(v, l10n),
                    onChanged: (v) => setState(() => _category = v),
                    required: true,
                  ),
                  _buildDropdown(
                    label: l10n.jobEducationLevel,
                    value: _education,
                    items: _withExisting(_education, educationLevels),
                    labelFor: (v) => educationLevelLabel(v, l10n),
                    onChanged: (v) => setState(() => _education = v),
                    required: true,
                  ),
                  _buildTextField(l10n.seekerExperience, _experienceController, maxLines: 3),
                  _buildTextField(l10n.jobDescription, _descriptionController, maxLines: 5),
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
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (val) => val == null || val.isEmpty ? '$label ${l10n.commonIsRequired}' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String Function(String) labelFor,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(labelFor(e))))
            .toList(),
        onChanged: onChanged,
        validator: required
            ? (val) => val == null || val.isEmpty ? '$label ${l10n.commonIsRequired}' : null
            : null,
      ),
    );
  }
}
