import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_liquid_glass.dart';

/// Screen presented to newly registered users (e.g. following Google Sign-In)
/// offering them the opportunity to enter a friend's promo code before proceeding.
class WelcomePromoScreen extends ConsumerStatefulWidget {
  const WelcomePromoScreen({super.key});

  @override
  ConsumerState<WelcomePromoScreen> createState() => _WelcomePromoScreenState();
}

class _WelcomePromoScreenState extends ConsumerState<WelcomePromoScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();

  Timer? _debounceTimer;
  bool _isValidating = false;
  bool _isClaiming = false;
  bool? _isCodeValid;
  double _discountPercent = 10.0;
  String? _validationMessage;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    _debounceTimer?.cancel();
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _isCodeValid = null;
        _validationMessage = null;
        _isValidating = false;
      });
      return;
    }

    setState(() => _isValidating = true);
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      final result = await ref.read(promoV2ServiceProvider).validateCode(code);
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _isCodeValid = result.valid;
        if (result.valid) {
          _discountPercent = result.discountPercent;
          _validationMessage =
              l10n.promoCodeValid(result.discountPercent.toInt().toString());
        } else {
          _validationMessage = result.message ?? l10n.promoCodeInvalid;
        }
      });
    });
  }

  Future<void> _claimOffer() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isClaiming = true);
    try {
      final res = await ref.read(promoV2ServiceProvider).claimCode(code);
      if (!mounted) return;
      setState(() => _isClaiming = false);

      final discount = (res['discount_percent'] as num?)?.toInt() ?? 10;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.promoCodeValid(discount.toString())),
          backgroundColor: AppColors.emerald600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to subscriptions so user can purchase their first discounted plan
      context.go('/subscriptions');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isClaiming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _skip() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _skip();
        }
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decorative Hero Badge
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent500.withValues(alpha: 0.2),
                            AppColors.accent600.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent500.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          size: 46,
                          color: AppColors.accent500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      l10n.promoWelcomeTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline2.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle explaining the offer
                    Text(
                      l10n.promoWelcomeSubtitle(
                        _discountPercent.toInt().toString(),
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Promo Code Input Card
                    LiquidGlass(
                      borderRadius: 18,
                      blur: 16,
                      variant: LiquidGlassVariant.regular,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.promoCodeInputLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primary900
                                  : AppColors.primary50.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCodeValid == true
                                    ? AppColors.emerald500
                                    : (_isCodeValid == false
                                        ? AppColors.error
                                        : (isDark
                                            ? Colors.white.withValues(alpha: 0.12)
                                            : AppColors.primary200)),
                                width: _isCodeValid != null ? 1.5 : 1,
                              ),
                            ),
                            child: TextField(
                              controller: _codeController,
                              focusNode: _codeFocus,
                              textCapitalization: TextCapitalization.characters,
                              style: AppTextStyles.title.copyWith(
                                color: context.textPrimary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.promoCodeInputHint,
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: context.textMuted,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: const Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 20,
                                  color: AppColors.accent500,
                                ),
                                suffixIcon: _isValidating
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : (_isCodeValid == true
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.emerald500,
                                            size: 20,
                                          )
                                        : (_isCodeValid == false
                                            ? const Icon(
                                                Icons.cancel_rounded,
                                                color: AppColors.error,
                                                size: 20,
                                              )
                                            : null)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          // Validation feedback message
                          if (_validationMessage != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _isCodeValid == true
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  size: 14,
                                  color: _isCodeValid == true
                                      ? AppColors.emerald500
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _validationMessage!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: _isCodeValid == true
                                          ? AppColors.emerald500
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Claim Offer Button
                    WaveButton(
                      text: l10n.promoClaimButton,
                      icon: Icons.check_rounded,
                      isLoading: _isClaiming,
                      isFullWidth: true,
                      onPressed: (_isCodeValid == true && !_isValidating)
                          ? _claimOffer
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Skip for Now Button
                    TextButton(
                      onPressed: _isClaiming ? null : _skip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        l10n.promoSkipButton,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
