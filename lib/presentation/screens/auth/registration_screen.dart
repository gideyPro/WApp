import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/app_logo.dart';
import '../navigation/main_navigation_shell.dart';
import '../../widgets/common/auth_background.dart';

/// Modern Registration Screen with consistent design
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

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
    // Listen for user input
    _firstNameController.addListener(_markDataEntered);
    _lastNameController.addListener(_markDataEntered);
    _phoneController.addListener(_markDataEntered);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      for (int i = 0; i < _otpFocusNodes.length; i++) {
        if (_otpFocusNodes[i].hasFocus) {
          if (_otpControllers[i].text.isEmpty && i > 0) {
            _otpFocusNodes[i - 1].requestFocus();
            return true;
          }
          break;
        }
      }
    }
    return false;
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

    // If authenticated, navigate to home
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      });
    }

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

                  // Back button + Logo row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showCancelDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
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

                  // Logo with glassmorphism
                  const GlassLogoContainer(size: 72, logoSize: 52),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // White card container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
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
                          _buildSectionTitle(l10n.authVerifyPhone),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authOtpSentMessage(_phoneController.text),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.zinc500,
                            ),
                            textAlign: TextAlign.center,
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
                          const SizedBox(height: 16),
                          _buildResendOtp(),
                        ],

                        // Error Message
                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _buildInlineError(authState.errorMessage!),
                        ],

                        // Login Link INSIDE card (only show before OTP is sent)
                        if (!_isOtpSent) _buildLoginLink(),
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
    // If no data entered, just go back without asking
    if (!_hasUserData && !_isOtpSent) {
      Navigator.pop(context);
      return;
    }

    // Show compact confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          content: Text(
            l10n.authCancelRegistration,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.navy900,
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

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.zinc200),
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
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15),
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
        color: AppColors.zinc50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.zinc200),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.zinc400, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.navy600, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.navy800,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.wave50 : AppColors.zinc50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.wave500 : AppColors.zinc200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.wave600 : AppColors.zinc500,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.wave700 : AppColors.zinc600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final fieldWidth = isSmall ? 38.0 : 42.0;
    final fieldHeight = isSmall ? 46.0 : 50.0;
    final gap = isSmall ? 3.0 : 4.0;
    final fontSize = isSmall ? 18.0 : 20.0;
    final borderRadius = isSmall ? 8.0 : 10.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 5 ? gap : 0),
          child: SizedBox(
            width: fieldWidth,
            height: fieldHeight,
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.navy900,
              ),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.zinc50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: AppColors.zinc200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide:
                      const BorderSide(color: AppColors.wave500, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: isSmall ? 10 : 12,
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty && index > 0) {
                  _otpFocusNodes[index - 1].requestFocus();
                } else if (value.isNotEmpty && index < 5) {
                  _otpFocusNodes[index + 1].requestFocus();
                } else if (value.isNotEmpty && index == 5) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendOtp() {
    if (_resendCountdown > 0) {
      return Text(
        'Resend code in ${_resendCountdown}s',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.zinc400,
        ),
      );
    }

    return TextButton(
      onPressed: _sendRegistrationOtp,
      child: const Text(
        'Resend Code',
        style: TextStyle(
          color: AppColors.wave600,
          fontWeight: FontWeight.w600,
          fontSize: 15,
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            l10n.authLogin,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
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
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
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
              style: const TextStyle(
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
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Prepend country code
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
    final otp = _otpControllers.map((c) => c.text).join();
    final l10n = AppLocalizations.of(context);
    if (otp.length != 6) {
      _showErrorSnackBar(l10n.authEnterOtpPrompt);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authStateProvider.notifier).register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            gender: _selectedGender!,
            otpCode: otp,
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
      final l10n = AppLocalizations.of(context);
      _showErrorSnackBar(l10n.authNetworkError);
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
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
