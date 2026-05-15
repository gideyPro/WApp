import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';

/// Edit Profile Screen
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String? _selectedGender;
  bool _isSaving = false;
  
  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedGender = user?.gender?.toLowerCase();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
    };

    if (_emailController.text.trim().isNotEmpty) {
      data['email'] = _emailController.text.trim();
    }

    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      // Backend expects: 'Male' or 'Female'
      final genderValue = _selectedGender![0].toUpperCase() + _selectedGender!.substring(1);
      data['gender'] = genderValue;
    }

    final success = await ref.read(profileProvider.notifier).updateProfile(data);

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdated),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final state = ref.read(profileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? l10n.profileUpdateError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary900 : AppColors.primary50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.primary900 : Colors.white,
        title: Text(l10n.profileEdit),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar section
                  _buildAvatarSection(user),
                  const SizedBox(height: 32),

                  // Form fields
                  _buildTextField(
                    controller: _firstNameController,
                    label: l10n.profileFirstName,
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.profileFirstNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: l10n.profileLastName,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: l10n.profileEmail,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!value.contains('@')) {
                          return l10n.profileEmailInvalid;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone (read-only)
                  _buildReadOnlyField(
                    label: l10n.authPhoneNumber,
                    value: user.phoneNumber,
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  _buildGenderDropdown(),
                  const SizedBox(height: 32),

                  // Save button
                  WaveButton(
                    text: l10n.profileSaveChanges,
                    icon: Icons.check,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _saveProfile,
                    isFullWidth: true,
                    variant: ButtonVariant.success,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarSection(dynamic user) {
    final initials = user.initials.isNotEmpty ? user.initials : '?';

    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent500, AppColors.accent600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent500.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        filled: true,
        fillColor: AppColors.zinc50,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      value: _selectedGender?.isEmpty ?? true ? null : _selectedGender,
      decoration: InputDecoration(
        labelText: l10n.profileGender,
        prefixIcon: const Icon(Icons.wc_outlined, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      items: [
        DropdownMenuItem(value: 'male', child: Text(l10n.profileMale)),
        DropdownMenuItem(value: 'female', child: Text(l10n.profileFemale)),
      ],
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    );
  }
}
