import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/otp_input_field.dart';
import '../navigation/main_navigation_shell.dart';
import '../../widgets/common/auth_background.dart';
import 'otp_login_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _otpCode = '';

  String? _selectedGender = 'Male';
  CountryCode _selectedCountry = Countries.defaultCountry;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _hasUserData = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).clearError();
    });
    _firstNameController.addListener(_markDataEntered);
    _lastNameController.addListener(_markDataEntered);
    _phoneController.addListener(_markDataEntered);
  }

  void _markDataEntered() {
    if (!_hasUserData) {
      setState(() => _hasUserData = true);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelDialog();
      },
      child: Scaffold(
        body: WaveAuthBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Back button
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _showCancelDialog,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Logo
                          const GlassLogoContainer(size: 64, logoSize: 46),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            AppLocalizations.of(context).authCreateAccount,
                            style: AppTextStyles.headline3.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context).authJoinMarketplace,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          // Step indicator
                          if (!_isOtpSent) _buildStepIndicator(1, 2, 'Personal Info')
                          else _buildStepIndicator(2, 2, 'Verification'),
                          const SizedBox(height: 20),

                          // Main card
                          _buildAuthCard(authState),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep, int totalSteps, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 1; i <= totalSteps; i++) ...[
          Container(
            width: i <= currentStep ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= currentStep
                  ? AppColors.accent500
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (i < totalSteps) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildAuthCard(dynamic authState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Step 1: Registration Form
          if (!_isOtpSent) ...[
            _buildSectionHeader(
              icon: Icons.person_add_rounded,
              title: l10n.authPersonalInfo,
              subtitle: 'Fill in your details to get started',
            ),
            const SizedBox(height: 20),
            _buildNameInputs(),
            const SizedBox(height: 14),
            _buildPhoneInput(),
            const SizedBox(height: 14),
            _buildGenderSelection(),
            const SizedBox(height: 24),
            WaveButton(
              text: l10n.listingContinue,
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              isFullWidth: true,
              onPressed: _isLoading ? null : _sendRegistrationOtp,
            ),
          ],

          // Step 2: OTP Verification
          if (_isOtpSent) ...[
            _buildSectionHeader(
              icon: Icons.shield_rounded,
              title: l10n.authVerifyPhone,
              subtitle: l10n.authOtpSentMessage(_phoneController.text),
            ),
            const SizedBox(height: 24),
            _buildOtpInput(),
            const SizedBox(height: 24),
            WaveButton(
              text: l10n.authVerifyAndCreate,
              icon: Icons.check_circle_rounded,
              isLoading: _isLoading,
              isFullWidth: true,
              onPressed: _isLoading ? null : _verifyAndRegister,
            ),
            const SizedBox(height: 20),
            _buildResendOtp(),
          ],

          // Error Message
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildInlineError(authState.errorMessage!),
          ],

          // Login Link (only show before OTP is sent)
          if (!_isOtpSent) ...[
            const SizedBox(height: 20),
            _buildLoginLink(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: AppColors.accent600,
            size: 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.zinc500,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showCancelDialog() {
    if (!_hasUserData && !_isOtpSent) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          content: Text(
            l10n.authCancelRegistration,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonNo),
            ),
            TextButton(
              onPressed: () {
                _countdownTimer?.cancel();
                ref.read(authStateProvider.notifier).resetState();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNameInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            controller: _firstNameController,
            hint: AppLocalizations.of(context).profileFirstName,
            icon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInputField(
            controller: _lastNameController,
            hint: AppLocalizations.of(context).profileLastName,
            icon: Icons.person_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary800.withValues(alpha: 0.5)
            : AppColors.primary50.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.primary700 : AppColors.primary200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CountrySelectorDropdown(
            selectedCountry: _selectedCountry,
            onCountrySelected: (country) {
              setState(() => _selectedCountry = country);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: _selectedCountry.example,
                hintStyle: TextStyle(
                  color: AppColors.primary400,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              ),
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.primary900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary800.withValues(alpha: 0.5)
            : AppColors.primary50.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.primary700 : AppColors.primary200,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.primary400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary500, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.primary900,
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileGender,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.zinc600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(l10n.profileMale, Icons.male_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(l10n.profileFemale, Icons.female_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent50 : AppColors.primary50.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent500 : AppColors.primary200,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.accent600 : AppColors.primary400,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.accent700 : AppColors.primary500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return OtpInputField(
      onChanged: (value) => _otpCode = value,
      hasError: ref.watch(authStateProvider).errorMessage != null,
    );
  }

  Widget _buildResendOtp() {
    if (_resendCountdown > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Resend code in ${_resendCountdown}s',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary500,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: _sendRegistrationOtp,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: AppColors.accent50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Resend Code',
        style: TextStyle(
          color: AppColors.accent600,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authAlreadyHaveAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.zinc400 : AppColors.zinc500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OtpLoginScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              l10n.authLogin,
              style: const TextStyle(
                color: AppColors.accent600,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInlineError(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(authStateProvider.notifier).clearError();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRegistrationOtp() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final fullPhone = '${_selectedCountry.code}${_phoneController.text.trim()}';
      final response = await ref.read(authStateProvider.notifier).register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: fullPhone,
            gender: _selectedGender!,
          );

      if (response.success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        _startCountdown();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndRegister() async {
    final l10n = AppLocalizations.of(context);
    if (_otpCode.length != 6) {
      _showErrorSnackBar(l10n.authEnterOtpPrompt);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authStateProvider.notifier).register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: '${_selectedCountry.code}${_phoneController.text.trim()}',
            gender: _selectedGender!,
            otpCode: _otpCode,
          );

      if (response.success && mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showErrorSnackBar(l10n.authNetworkError);
      }
    }
  }

  bool _validateForm() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context);

    if (firstName.isEmpty) {
      _showErrorSnackBar(l10n.authFirstNameRequired);
      return false;
    }

    if (lastName.isEmpty) {
      _showErrorSnackBar(l10n.authLastNameRequired);
      return false;
    }

    if (phone.isEmpty || phone.length < 9) {
      _showErrorSnackBar(l10n.authPhoneRequired);
      return false;
    }

    if (_selectedGender == null) {
      _showErrorSnackBar(l10n.authSelectGender);
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
