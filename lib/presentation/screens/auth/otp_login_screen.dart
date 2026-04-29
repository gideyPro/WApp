import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/auth_background.dart';
import 'registration_screen.dart';
import '../navigation/main_navigation_shell.dart';
import '../../../../l10n/app_localizations.dart';

/// Modern OTP Login Screen with 60-second countdown
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 0;
  Timer? _countdownTimer;
  CountryCode _selectedCountry = Countries.defaultCountry;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).clearError();
    });
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
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

    // If authenticated, show loading while navigating to home
    if (authState.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.wave500),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: WaveAuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Logo with glassmorphism
                  const GlassLogoContainer(size: 90, logoSize: 65),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    l10n.authWelcomeTitle,
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.authWelcomeSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

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
                        // Inline Error Message
                        if (authState.errorMessage != null)
                          _buildInlineError(authState.errorMessage!),

                        if (authState.errorMessage != null)
                          const SizedBox(height: 16),

                        // Step 1: Phone Input
                        if (!authState.otpSent) ...[
                          _buildSectionTitle(
                              AppLocalizations.of(context).authEnterPhone),
                          const SizedBox(height: 16),
                          _buildPhoneInput(),
                          const SizedBox(height: 20),
                          WaveButton(
                            text: AppLocalizations.of(context).authSendOtp,
                            icon: Icons.arrow_forward_rounded,
                            isLoading: authState.isLoading,
                            isFullWidth: true,
                            onPressed: authState.isLoading ? null : _sendOtp,
                          ),
                          const SizedBox(height: 16),
                          _buildRegisterLink(),
                        ],

                        // Step 2: OTP Input
                        if (authState.otpSent) ...[
                          _buildSectionTitle(l10n.authEnterOtp),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authOtpSentMessage(
                                authState.phoneNumber ?? ''),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.zinc500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          _buildOtpInput(),
                          const SizedBox(height: 20),
                          WaveButton(
                            text: AppLocalizations.of(context).authVerifyOtp,
                            icon: Icons.check_circle_rounded,
                            isLoading: authState.isLoading,
                            isFullWidth: true,
                            onPressed: authState.isLoading ? null : _verifyOtp,
                          ),
                          const SizedBox(height: 16),
                          _buildResendOtp(),
                        ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.navy900,
      ),
    );
  }

  Widget _buildPhoneInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc800 : AppColors.zinc50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc200),
      ),
      child: Row(
        children: [
          CountrySelectorDropdown(
            selectedCountry: _selectedCountry,
            onCountrySelected: (country) {
              setState(() => _selectedCountry = country);
            },
          ),
          Container(
            height: 24,
            width: 1,
            color: isDark ? AppColors.zinc700 : AppColors.zinc200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: _selectedCountry.example,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              ),
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.navy900,
              ),
            ),
          ),
        ],
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
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.w800,
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
                if (value.isNotEmpty) {
                  if (index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (index == 5) {
                    FocusScope.of(context).unfocus();
                  }
                } else if (value.isEmpty && index > 0) {
                  _otpFocusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendOtp() {
    final l10n = AppLocalizations.of(context);
    if (_resendCountdown > 0) {
      return Text(
        l10n.authResendCountdown(_resendCountdown),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.zinc400,
        ),
      );
    }

    return TextButton(
      onPressed: _resendOtp,
      child: Text(
        AppLocalizations.of(context).authResendOtp,
        style: TextStyle(
          color: AppColors.wave600,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authNoAccount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.navy600,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RegistrationScreen(),
              ),
            );
          },
          child: Text(
            l10n.authRegister,
            style: TextStyle(
              color: AppColors.wave600,
              fontWeight: FontWeight.w600,
              fontSize: 15,
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

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authEnterPhonePrompt),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Prepend country code
    final fullPhone = '${_selectedCountry.code}$phone';
    await ref.read(authStateProvider.notifier).sendOtp(fullPhone);
    if (mounted) {
      _startCountdown();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    final l10n = AppLocalizations.of(context);
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authEnterOtpPrompt),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final response = await ref.read(authStateProvider.notifier).login(otp);

    if (mounted && response.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  Future<void> _resendOtp() async {
    final response = await ref.read(authStateProvider.notifier).resendOtp();
    if (mounted) {
      if (response.success) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
