import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/job_seeker_providers.dart';
import '../../../data/models/job_seeker_profile.dart';

class EditJobSeekerProfileScreen extends ConsumerStatefulWidget {
  const EditJobSeekerProfileScreen({super.key});

  @override
  ConsumerState<EditJobSeekerProfileScreen> createState() => _EditJobSeekerProfileScreenState();
}

class _EditJobSeekerProfileScreenState extends ConsumerState<EditJobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isPublic = true;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _educationController.dispose();
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
    _categoryController.text = profile.jobCategory ?? '';
    _educationController.text = profile.educationLevel;
    _experienceController.text = profile.experience ?? '';
    _descriptionController.text = profile.description ?? '';
    _isPublic = profile.isPublic;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final data = {
      'full_name': _fullNameController.text.trim(),
      'professional_title': _titleController.text.trim(),
      'job_category': _categoryController.text.trim(),
      'education_level': _educationController.text.trim(),
      'experience': _experienceController.text.trim(),
      'description': _descriptionController.text.trim(),
      'is_public': _isPublic ? '1' : '0',
    };
    
    final response = await ref.read(jobSeekerServiceProvider).createOrUpdateProfile(
      data: data,
      photo: _selectedImage,
    );
    
    setState(() => _isSubmitting = false);
    
    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      ref.invalidate(myJobSeekerProfileProvider);
      ref.invalidate(jobSeekerProfilesProvider);
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myJobSeekerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(title: const Text('My Job Profile')),
      body: myProfileAsync.when(
        data: (profile) {
          // Pre-populate if this is the first time we're seeing the data and controllers are empty
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
                  _buildTextField('Full Name', _fullNameController, required: true),
                  _buildTextField('Professional Title', _titleController, required: true),
                  _buildTextField('Job Category', _categoryController),
                  _buildTextField('Education Level', _educationController, required: true),
                  _buildTextField('Experience', _experienceController, maxLines: 3),
                  _buildTextField('Description / About', _descriptionController, maxLines: 5),
                  SwitchListTile(
                    title: const Text('Make Profile Public'),
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Profile'),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
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
            ? (val) => val == null || val.isEmpty ? 'This field is required' : null
            : null,
      ),
    );
  }
}
