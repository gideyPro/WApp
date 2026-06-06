import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/auth_background.dart';
import '../../widgets/common/otp_input_field.dart';
import '../../widgets/common/wave_language_chip.dart';
import 'registration_screen.dart';
import '../navigation/main_navigation_shell.dart';
import '../../../../l10n/app_localizations.dart';

class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final GlobalKey<OtpInputFieldState> _otpKey = GlobalKey();
  String _otpCode = '';
  bool _hasUserData = false;
  String? _phoneError;

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
    _phoneFocus.addListener(_onPhoneFocusChanged);
  }

  void _onPhoneFocusChanged() {
    if (!_phoneFocus.hasFocus) {
      final phone = _phoneController.text.trim();
      setState(() {
        _phoneError = (phone.isEmpty || phone.length < 9) ? l10n.authPhoneRequired : null;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
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

    if (authState.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.primary900,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent500),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        body: WaveAuthBackground(
          child: SafeArea(
            child: Stack(
              children: [
                const Positioned(
                  top: 8,
                  right: 16,
                  child: WaveLanguageChip(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                  // Logo with glassmorphism
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
                    l10n.authWelcomeTitle,
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.authWelcomeSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Card container
                  Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Inline Error Message
                          if (authState.errorMessage != null)
                            _buildInlineError(authState.errorMessage!),

                          if (authState.errorMessage != null)
                            const SizedBox(height: 16),

                          // Step 1: Phone Input
                          if (!authState.otpSent) ...[
                            _buildSectionTitle(AppLocalizations.of(context).authEnterPhone),
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
                            _buildOtpInfoBanner(),
                            const SizedBox(height: 16),
                            _buildSectionTitle(l10n.authEnterOtp),
                            const SizedBox(height: 16),
                            _buildOtpInput(),
                            const SizedBox(height: 20),
                            WaveButton(
                              text: AppLocalizations.of(context).authVerifyOtp,
                              icon: Icons.check_circle_rounded,
                              isLoading: authState.isLoading,
                              isFullWidth: true,
                              onPressed: authState.isLoading ? null : _verifyOtp,
                            ),
                            const SizedBox(height: 12),
                            _buildChangeNumberButton(),
                            const SizedBox(height: 8),
                            _buildResendOtp(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
                ),
              ],
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
        color: AppColors.primary900,
      ),
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
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _phoneError!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final hasError = ref.watch(authStateProvider).errorMessage != null;
    return OtpInputField(
      key: _otpKey,
      onChanged: (value) => _otpCode = value,
      hasError: hasError,
      autofocus: true,
    );
  }

  Widget _buildResendOtp() {
    final l10n = AppLocalizations.of(context);
    if (_resendCountdown > 0) {
      return Text(
        l10n.authResendCountdown(_resendCountdown),
        style: AppTextStyles.bodyMedium.copyWith(
          color: ThemeColors(context).textSecondary,
        ),
      );
    }

    return TextButton(
      onPressed: _resendOtp,
      child: Text(
        AppLocalizations.of(context).authResendOtp,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.accent600,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accent600,
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
            color: ThemeColors(context).textSecondary,
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
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.accent600,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    final accentColor = isEthiopia ? AppColors.emerald500 : AppColors.accent500;

    final effectiveMessage = authState.otpMessage != null
        ? authState.otpMessage!
        : isEthiopia
            ? l10n.authOtpSentMessage(authState.phoneNumber ?? '')
            : l10n.authOtpSentEmailMessage(displayDestination ?? 'your email');

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEthiopia ? Icons.phone_android_rounded : Icons.email_rounded,
                  size: 18,
                  color: accentColor,
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.theme.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.primary50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEthiopia ? Icons.phone_outlined : Icons.email_outlined,
                      size: 14,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayDestination,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isEthiopia) ...[
              const SizedBox(height: 8),
              Text(
                l10n.authSpamFolderHint,
                style: AppTextStyles.caption.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChangeNumberButton() {
    return TextButton.icon(
      onPressed: () => _confirmChangeNumber(),
      icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.primary600),
      label: Text(
        l10n.authChangeNumber,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary600,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  void _confirmChangeNumber() {
    final l10n = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.authChangeNumber),
        content: Text(l10n.authChangeNumberConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonYes),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        _countdownTimer?.cancel();
        ref.read(authStateProvider.notifier).clearOtpSent();
      }
    });
  }

  void _showExitDialog() {
    final authState = ref.read(authStateProvider);
    if (!_hasUserData && !authState.otpSent) {
      SystemNavigator.pop();
      return;
    }

    final l10n = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.authExitLogin),
        content: Text(l10n.authExitLoginConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonYes),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        _countdownTimer?.cancel();
        ref.read(authStateProvider.notifier).clearOtpSent();
        SystemNavigator.pop();
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authEnterPhonePrompt), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    setState(() => _hasUserData = true);
    final fullPhone = '${_selectedCountry.code}$phone';
    await ref.read(authStateProvider.notifier).sendOtp(fullPhone);
    if (mounted) {
      _startCountdown();
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context);
    if (_otpCode.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authEnterOtpPrompt), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final response =
        await ref.read(authStateProvider.notifier).login(_otpCode);

    if (mounted && response.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  Future<void> _resendOtp() async {
    _otpKey.currentState?.clear();
    _otpCode = '';

    final response = await ref.read(authStateProvider.notifier).resendOtp();
    if (mounted) {
      if (response.success) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
