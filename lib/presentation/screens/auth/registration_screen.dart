import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/otp_input_field.dart';
import '../navigation/main_navigation_shell.dart';
import '../../widgets/common/auth_background.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_dialog.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<OtpInputFieldState> _otpKey = GlobalKey();
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
    _emailController.addListener(_markDataEntered);
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
    _emailController.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelDialog();
      },
      child: Scaffold(
        body: WaveAuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showCancelDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Logo
                  const GlassLogoContainer(size: 72, logoSize: 52),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      text: 'Wave',
                      style: AppTextStyles.headline2.copyWith(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Mart',
                          style: AppTextStyles.headline2.copyWith(color: AppColors.accent400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    AppLocalizations.of(context).authCreateAccount,
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).authJoinMarketplace,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Card container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.stone200,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Step 1: Registration Form
                        if (!_isOtpSent) ...[
                          _buildSectionTitle(l10n.authPersonalInfo),
                          const SizedBox(height: 20),
                          _buildNameInputs(),
                          const SizedBox(height: 16),
                          _buildEmailInput(),
                          const SizedBox(height: 16),
                          _buildPhoneInput(),
                          const SizedBox(height: 16),
                          _buildGenderSelection(),
                          const SizedBox(height: 24),
                          WaveButton(
                            text: l10n.listingContinue,
                            icon: Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            onPressed: _isLoading ? null : _sendRegistrationOtp,
                          ),
                          const SizedBox(height: 16),
                          _buildLoginLink(),
                        ],

                        // Step 2: OTP Verification
                        if (_isOtpSent) ...[
                          _buildSectionTitle(l10n.authVerifyPhone),
                          const SizedBox(height: 8),
                          _buildOtpInfoBanner(),
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
                          const SizedBox(height: 16),
                          _buildResendOtp(),
                        ],

                        // Error Message
                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _buildInlineError(authState.errorMessage!),
                        ],

                        // Language switcher at bottom
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.primary200.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          child: _buildLanguageSwitcher(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    if (!_hasUserData && !_isOtpSent) {
      Navigator.pop(context);
      return;
    }

    WaveDialog.show(
      context: context,
      message: l10n.authCancelRegistration,
      type: DialogType.confirm,
      actions: [
        WaveButton(
          text: l10n.commonNo,
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
        ),
        WaveButton(
          text: l10n.commonOk,
          variant: ButtonVariant.danger,
          onPressed: () {
            _countdownTimer?.cancel();
            ref.read(authStateProvider.notifier).resetState();
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  String _maskDestination(String destination) {
    if (destination.contains('@')) {
      final parts = destination.split('@');
      final local = parts[0];
      final domain = parts[1];
      if (local.length <= 1) return '***@$domain';
      final maskedLocal = '${local[0]}${'*' * (local.length - 1)}';
      return '$maskedLocal@$domain';
    }
    if (destination.length <= 4) return destination;
    return '${destination.substring(0, 4)}****${destination.substring(destination.length - 3)}';
  }

  Widget _buildOtpInfoBanner() {
    final authState = ref.watch(authStateProvider);
    final isEthiopia = _selectedCountry.code == '+251';
    final dest = authState.destination;
    final displayDestination = dest != null ? _maskDestination(dest) : null;

    final effectiveMessage = authState.otpMessage != null
        ? authState.otpMessage!
        : isEthiopia
            ? l10n.authOtpSentMessage(_phoneController.text)
            : l10n.authOtpSentEmailMessage(displayDestination ?? _emailController.text);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary200,
        ),
        boxShadow: [
          BoxShadow(
            color: (context.theme.isDark ? AppColors.accent500 : AppColors.primary500)
                .withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isEthiopia
                      ? [AppColors.emerald500, AppColors.emerald400]
                      : [AppColors.accent500, AppColors.accent400],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (isEthiopia ? AppColors.emerald500 : AppColors.accent500)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isEthiopia ? Icons.phone_android_rounded : Icons.email_rounded,
                            size: 16,
                            color: isEthiopia ? AppColors.emerald600 : AppColors.accent600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            effectiveMessage,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (displayDestination != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.theme.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppColors.primary50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.theme.isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : AppColors.primary200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isEthiopia ? Icons.phone_outlined : Icons.email_outlined,
                              size: 14,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayDestination,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!isEthiopia) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 12,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.authSpamFolderHint,
                            style: AppTextStyles.caption.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.primary900,
      ),
    );
  }

  Widget _buildNameInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            controller: _firstNameController,
            hint: AppLocalizations.of(context).profileFirstName,
            icon: Icons.person_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInputField(
            controller: _lastNameController,
            hint: AppLocalizations.of(context).profileLastName,
            icon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    final isEthiopia = _selectedCountry.code == '+251';
    return _buildInputField(
      controller: _emailController,
      hint: isEthiopia ? l10n.profileEmail : '${l10n.profileEmail} (${l10n.orderRequired})',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPhoneInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary800 : AppColors.primary50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? AppColors.primary700 : AppColors.primary200),
      ),
      child: Row(
        children: [
          CountrySelectorDropdown(
            selectedCountry: _selectedCountry,
            onCountrySelected: (country) {
              setState(() => _selectedCountry = country);
            },
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: _selectedCountry.example,
                hintStyle: AppTextStyles.bodySmall,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodySmall.copyWith(
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary200),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
          prefixIcon: Icon(icon, color: context.theme.iconSecondary, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        keyboardType: keyboardType,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary900),
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
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(l10n.profileMale, Icons.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(l10n.profileFemale, Icons.female),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent50 : AppColors.primary50.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.accent500 : AppColors.primary200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accent600 : ThemeColors(context).inputBg,
            ),
            const SizedBox(width: 6),
            Text(
              gender,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.accent700 : ThemeColors(context).textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return OtpInputField(
      key: _otpKey,
      onChanged: (value) => _otpCode = value,
      hasError: ref.watch(authStateProvider).errorMessage != null,
      autofocus: true,
    );
  }

  Widget _buildResendOtp() {
    if (_resendCountdown > 0) {
      return Text(
        'Resend code in ${_resendCountdown}s',
        style: AppTextStyles.bodyMedium.copyWith(
          color: ThemeColors(context).textSecondary,
        ),
      );
    }

    return TextButton(
      onPressed: _sendRegistrationOtp,
      child: Text(
        'Resend Code',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.accent600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authAlreadyHaveAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: ThemeColors(context).textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OtpLoginScreen(),
              ),
            );
          },
          child: Text(
            l10n.authLogin,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.accent600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSwitcher() {
    final currentLocale = ref.watch(localeProvider).locale?.languageCode ?? 'en';
    const supportedLocales = [
      {'code': 'en', 'label': 'EN'},
      {'code': 'am', 'label': 'AM'},
      {'code': 'ti', 'label': 'TI'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: supportedLocales.map((lang) {
        final isActive = currentLocale == lang['code'];
        return GestureDetector(
          onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(lang['code']!)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary600 : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              lang['label']!,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? Colors.white : AppColors.primary400,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlineError(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(authStateProvider.notifier).clearError();
            },
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRegistrationOtp() async {
    if (_isOtpSent) {
      _otpKey.currentState?.clear();
      _otpCode = '';
    }

    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final fullPhone = '${_selectedCountry.code}${_phoneController.text.trim()}';
      final response = await ref.read(authStateProvider.notifier).register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: fullPhone,
            gender: _selectedGender!,
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
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
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
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
    final email = _emailController.text.trim();
    final l10n = AppLocalizations.of(context);
    final isEthiopia = _selectedCountry.code == '+251';

    if (firstName.isEmpty) {
      _showErrorSnackBar(l10n.authFirstNameRequired);
      return false;
    }

    if (lastName.isEmpty) {
      _showErrorSnackBar(l10n.authLastNameRequired);
      return false;
    }

    if (!isEthiopia && email.isEmpty) {
      _showErrorSnackBar(l10n.profileEmailRequired); // Assuming this key exists or should be used
      return false;
    }

    if (email.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackBar(l10n.profileEmailInvalid);
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
    WaveToast.showError(context, message);
  }
}
