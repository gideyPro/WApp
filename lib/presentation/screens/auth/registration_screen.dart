import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/otp_input_field.dart';
import '../../widgets/common/auth_top_bar.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final GlobalKey<OtpInputFieldState> _otpKey = GlobalKey();
  String _otpCode = '';

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _emailError;

  String? _selectedGender = 'male';
  CountryCode _selectedCountry = Countries.defaultCountry;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _hasUserData = false;
  bool _agreedToTerms = false;
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
    _firstNameFocus.addListener(() => _onFieldFocusLost(_firstNameFocus, _validateFirstName));
    _lastNameFocus.addListener(() => _onFieldFocusLost(_lastNameFocus, _validateLastName));
    _phoneFocus.addListener(() => _onFieldFocusLost(_phoneFocus, _validatePhone));
    _emailFocus.addListener(() => _onFieldFocusLost(_emailFocus, _validateEmail));
  }

  void _markDataEntered() {
    if (!_hasUserData) {
      setState(() => _hasUserData = true);
    }
  }

  void _onFieldFocusLost(FocusNode node, String? Function() validator) {
    if (!node.hasFocus) {
      final err = validator();
      if (err != null) {
        setState(() {
          if (node == _firstNameFocus) _firstNameError = err;
          if (node == _lastNameFocus) _lastNameError = err;
          if (node == _phoneFocus) _phoneError = err;
          if (node == _emailFocus) _emailError = err;
        });
      } else {
        setState(() {
          if (node == _firstNameFocus) _firstNameError = null;
          if (node == _lastNameFocus) _lastNameError = null;
          if (node == _phoneFocus) _phoneError = null;
          if (node == _emailFocus) _emailError = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
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
            child: Stack(
              children: [
                SingleChildScrollView(
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
                          _buildPhoneInput(),
                          const SizedBox(height: 16),
                          _buildEmailInput(),
                          const SizedBox(height: 16),
                          _buildGenderSelection(),
                          const SizedBox(height: 12),
                          _buildTermsCheckbox(),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
                ),
                const Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: AuthTopBar(),
                ),
              ],
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

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.authCancelRegistration),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () {
              _countdownTimer?.cancel();
              ref.read(authStateProvider.notifier).resetState();
              Navigator.pop(ctx, true);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInfoBanner() {
    final authState = ref.watch(authStateProvider);
    final isEthiopia = _selectedCountry.code == '+251';
    final accentColor = isEthiopia ? AppColors.emerald500 : AppColors.accent500;

    final message = isEthiopia
        ? l10n.authOtpSentMessage(authState.phoneNumber ?? _phoneController.text)
        : l10n.authOtpSentEmailMessage(_emailController.text);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
          top: BorderSide(
            color: context.theme.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary200,
          ),
          bottom: BorderSide(
            color: context.theme.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary200,
          ),
          right: BorderSide(
            color: context.theme.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary200,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              isEthiopia ? Icons.phone_android_rounded : Icons.email_rounded,
              size: 18,
              color: accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInputField(
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            errorText: _firstNameError,
            label: AppLocalizations.of(context).profileFirstName,
            hint: AppLocalizations.of(context).profileFirstName,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInputField(
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            errorText: _lastNameError,
            label: AppLocalizations.of(context).profileLastName,
            hint: AppLocalizations.of(context).profileLastName,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    final isEthiopia = _selectedCountry.code == '+251';
    return _buildInputField(
      controller: _emailController,
      focusNode: _emailFocus,
      errorText: _emailError,
      label: isEthiopia ? l10n.profileEmail : '${l10n.profileEmail} (${l10n.orderRequired})',
      hint: 'name@example.com',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
    );
  }

  Widget _buildPhoneInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = _phoneError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            l10n.authEnterPhone,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.primary800 : AppColors.primary50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: hasError
                  ? AppColors.error.withValues(alpha: 0.5)
                  : (isDark ? AppColors.primary700 : AppColors.primary200),
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
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  decoration: InputDecoration(
                    hintText: _selectedCountry.example,
                    hintStyle: AppTextStyles.bodySmall,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white : AppColors.primary900,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildFieldError(_phoneError),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: hasError
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.primary200,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted),
              prefixIcon: Icon(icon, color: context.theme.iconSecondary, size: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            ),
            keyboardType: keyboardType,
            autocorrect: autocorrect,
            textCapitalization: textCapitalization,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary900),
          ),
        ),
        _buildFieldError(errorText),
      ],
    );
  }

  Widget _buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: AppColors.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
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
              child: _buildGenderOption('male', l10n.profileMale, Icons.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('female', l10n.profileFemale, Icons.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
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
              label,
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
        l10n.authResendCountdown(_resendCountdown),
        style: AppTextStyles.bodyMedium.copyWith(
          color: ThemeColors(context).textSecondary,
        ),
      );
    }

    return TextButton(
      onPressed: _sendRegistrationOtp,
      child: Text(
        l10n.authResendOtp,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.accent600,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accent600,
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
    final firstNameErr = _validateFirstName();
    final lastNameErr = _validateLastName();
    final phoneErr = _validatePhone();
    final emailErr = _validateEmail();
    setState(() {
      _firstNameError = firstNameErr;
      _lastNameError = lastNameErr;
      _phoneError = phoneErr;
      _emailError = emailErr;
    });
    if (firstNameErr != null) {
      _showErrorSnackBar(firstNameErr);
      return false;
    }
    if (lastNameErr != null) {
      _showErrorSnackBar(lastNameErr);
      return false;
    }
    if (emailErr != null) {
      _showErrorSnackBar(emailErr);
      return false;
    }
    if (phoneErr != null) {
      _showErrorSnackBar(phoneErr);
      return false;
    }
    if (_selectedGender == null) {
      _showErrorSnackBar(l10n.authSelectGender);
      return false;
    }
    if (!_agreedToTerms) {
      _showErrorSnackBar(l10n.listingErrorTermsRequired);
      return false;
    }
    return true;
  }

  Widget _buildTermsCheckbox() {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: AppColors.primary300,
      ),
      child: CheckboxListTile(
        value: _agreedToTerms,
        onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
        title: Text(
          l10n.listingAcceptTerms,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary800,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.listingTermsSubtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary500,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.accent600,
        dense: true,
      ),
    );
  }

  String? _validateFirstName() {
    if (_firstNameController.text.trim().isEmpty) {
      return l10n.authFirstNameRequired;
    }
    return null;
  }

  String? _validateLastName() {
    if (_lastNameController.text.trim().isEmpty) {
      return l10n.authLastNameRequired;
    }
    return null;
  }

  String? _validatePhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      return l10n.authPhoneRequired;
    }
    return null;
  }

  String? _validateEmail() {
    final email = _emailController.text.trim();
    final isEthiopia = _selectedCountry.code == '+251';
    if (!isEthiopia && email.isEmpty) {
      return l10n.profileEmailRequired;
    }
    if (email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return l10n.profileEmailInvalid;
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
