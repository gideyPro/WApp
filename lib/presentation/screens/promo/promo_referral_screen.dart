import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/v2/promo_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Screen displaying the user's promo code, referral link, wallet balance,
/// Telebirr withdrawal flow, and detailed earning history.
class PromoReferralScreen extends ConsumerStatefulWidget {
  const PromoReferralScreen({super.key});

  @override
  ConsumerState<PromoReferralScreen> createState() => _PromoReferralScreenState();
}

class _PromoReferralScreenState extends ConsumerState<PromoReferralScreen> {
  int _selectedActivityTab = 0;
  AppLocalizations get l10n => AppLocalizations.of(context);

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.promoCodeCopied),
        backgroundColor: AppColors.emerald600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sharePromoCode(PromoDashboardData data) {
    final message = l10n.promoShareMessage(
      data.promoCode,
      data.discountPercentage.toInt().toString(),
      data.inviteLink,
    );
    Share.share(message);
  }

  void _showWithdrawModal(BuildContext context, PromoDashboardData data) {
    final authUser = ref.read(authStateProvider).user;
    final amountController = TextEditingController(
      text: data.walletBalance.toStringAsFixed(0),
    );
    final phoneController = TextEditingController(
      text: authUser?.phoneNumber ?? '',
    );
    final nameController = TextEditingController(
      text: authUser?.fullName ?? '',
    );

    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary900 : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.textMuted.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.accent500,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.promoWithdrawTitle,
                                style: AppTextStyles.title.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.promoWalletBalance}: ${data.walletBalance.toStringAsFixed(2)} ETB (${l10n.promoMinWithdraw(data.minWithdrawAmount.toStringAsFixed(0))})',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Amount field
                        Text(
                          l10n.promoWithdrawAmount,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.money_rounded),
                            hintText: l10n.promoWithdrawMinHint(
                              data.minWithdrawAmount.toStringAsFixed(0),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.primary800
                                : AppColors.primary50.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : AppColors.primary200,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final val = double.tryParse(value?.trim() ?? '');
                            if (val == null) {
                              return l10n.promoWithdrawInvalidAmount;
                            }
                            if (val < data.minWithdrawAmount) {
                              return l10n.promoMinWithdraw(
                                data.minWithdrawAmount.toStringAsFixed(0),
                              );
                            }
                            if (val > data.walletBalance) {
                              return l10n.promoWithdrawExceedsBalance;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Phone Number field
                        Text(
                          l10n.promoWithdrawPhone,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_android_rounded),
                            hintText: '+251 9XXXXXXXX',
                            filled: true,
                            fillColor: isDark
                                ? AppColors.primary800
                                : AppColors.primary50.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : AppColors.primary200,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.promoWithdrawPhoneRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Account Name field
                        Text(
                          l10n.promoWithdrawAccountName,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_rounded),
                            hintText: l10n.promoWithdrawAccountNameHint,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.primary800
                                : AppColors.primary50.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : AppColors.primary200,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.promoWithdrawNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        WaveButton(
                          text: l10n.promoWithdrawSubmit,
                          icon: Icons.send_rounded,
                          isLoading: isSubmitting,
                          isFullWidth: true,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() => isSubmitting = true);
                            try {
                              final amt = double.parse(amountController.text.trim());
                              await ref.read(promoV2ServiceProvider).withdraw(
                                    amount: amt,
                                    phoneNumber: phoneController.text.trim(),
                                    accountName: nameController.text.trim(),
                                  );

                              if (!bottomSheetContext.mounted) return;
                              Navigator.pop(bottomSheetContext);

                              ref.invalidate(promoDashboardProvider);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.promoWithdrawSuccess),
                                  backgroundColor: AppColors.emerald600,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(promoDashboardProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(
          l10n.promoReferralsTitle,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  err.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                WaveButton(
                  text: l10n.commonRetry,
                  onPressed: () => ref.refresh(promoDashboardProvider),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(promoDashboardProvider);
            await ref.read(promoDashboardProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroRewardsPass(data),
                const SizedBox(height: 18),
                _buildStatsGrid(data),
                const SizedBox(height: 24),
                _buildActivitySection(data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Option A: Integrated Rewards Pass (Ticket style hero merging Wallet & Voucher)
  Widget _buildHeroRewardsPass(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardNavyDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFCBD5E1),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper Section: Wallet & Balance
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Promoter Tier Badge + Ready Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emerald500.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.emerald500.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.emerald500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.promoTierPromoter,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.emerald500,
                              fontWeight: FontWeight.w800,
                              fontSize: 10.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (data.canWithdraw
                                ? AppColors.emerald500
                                : context.textMuted)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (data.canWithdraw
                                  ? AppColors.emerald500
                                  : context.textMuted)
                              .withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        data.canWithdraw
                            ? l10n.promoWalletWithdrawable
                            : l10n.promoWalletLocked,
                        style: AppTextStyles.caption.copyWith(
                          color: data.canWithdraw
                              ? AppColors.emerald500
                              : context.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.promoWalletBalance.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      data.walletBalance.toStringAsFixed(2),
                      style: AppTextStyles.headline1.copyWith(
                        color: isDark ? Colors.white : AppColors.primary900,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ETB',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.accent500,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '(${l10n.promoMinWithdraw(data.minWithdrawAmount.toStringAsFixed(0))})',
                        style: AppTextStyles.caption.copyWith(
                          color: context.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Side-by-side balanced action buttons
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: data.canWithdraw
                              ? () {
                                  HapticFeedback.lightImpact();
                                  _showWithdrawModal(context, data);
                                }
                              : null,
                          borderRadius: BorderRadius.circular(13),
                          child: Ink(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: data.canWithdraw
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF059669),
                                      ],
                                    )
                                  : null,
                              color: data.canWithdraw
                                  ? null
                                  : (isDark
                                      ? AppColors.primary800
                                      : AppColors.stone300),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: data.canWithdraw
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 15,
                                    color: data.canWithdraw
                                        ? const Color(0xFF041E15)
                                        : context.textMuted,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      l10n.promoWithdrawTelebirr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: data.canWithdraw
                                            ? const Color(0xFF041E15)
                                            : context.textMuted,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: data.walletBalance > 0
                              ? () {
                                  HapticFeedback.lightImpact();
                                  context.push('/subscriptions');
                                }
                              : null,
                          borderRadius: BorderRadius.circular(13),
                          child: Ink(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardNavyLight
                                  : AppColors.stone100,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : const Color(0xFFCBD5E1),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond_rounded,
                                    size: 15,
                                    color: data.walletBalance > 0
                                        ? AppColors.accent500
                                        : context.textMuted,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      l10n.promoUseForPackage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: data.walletBalance > 0
                                            ? context.textPrimary
                                            : context.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
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
                  ],
                ),
              ],
            ),
          ),

          // Perforated Ticket Divider with Semicircle Notches
          _buildTicketDivider(context, isDark),

          // Lower Section: Voucher & Referral Link
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF081A2C)
                              : AppColors.stone50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E4569)
                                : const Color(0xFFCBD5E1),
                            width: 0.9,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.promoYourCode.toUpperCase(),
                                    style: AppTextStyles.caption.copyWith(
                                      color: context.textMuted,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data.promoCode,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: AppColors.accent500,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                      letterSpacing: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _copyPromoCode(data.promoCode);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent500
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.promoCopyCode,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accent500,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _sharePromoCode(data);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.share_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.promoShare,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '🎁 ${l10n.promoInviteDiscount(data.discountPercentage.toInt().toString())}',
                  style: AppTextStyles.caption.copyWith(
                    color: context.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Authentic Perforated Ticket Divider with side notches
  Widget _buildTicketDivider(BuildContext context, bool isDark) {
    final cutoutColor = context.scaffoldBg;
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          Container(
            width: 11,
            height: 22,
            decoration: BoxDecoration(
              color: cutoutColor,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(11),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 5.0;
                const dashSpace = 4.0;
                final dashCount =
                    (constraints.maxWidth / (dashWidth + dashSpace)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                      width: dashWidth,
                      height: 1.2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Container(
            width: 11,
            height: 22,
            decoration: BoxDecoration(
              color: cutoutColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3 Balanced Stat Tiles
  Widget _buildStatsGrid(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: l10n.promoStatsInvited,
            value: data.totalInvited.toString(),
            icon: Icons.people_outline_rounded,
            accentColor: const Color(0xFF0EA5E9),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            title: l10n.promoStatsSubscribed,
            value: data.totalSubscribed.toString(),
            icon: Icons.verified_user_rounded,
            accentColor: AppColors.emerald500,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            title: l10n.promoStatsEarned,
            value: '${data.totalEarned.toStringAsFixed(0)} ETB',
            icon: Icons.monetization_on_rounded,
            accentColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardNavyDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: context.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Activity & Records with Segmented Tab Switching
  Widget _buildActivitySection(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.promoActivityRecords,
          style: AppTextStyles.titleSmall.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        // Segmented Tab Capsule
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardNavyDark : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFCBD5E1),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedActivityTab = 0);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedActivityTab == 0
                          ? (isDark ? AppColors.cardNavyLight : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: _selectedActivityTab == 0
                          ? [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.3 : 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${l10n.promoEarningsHistory} (${data.earnings.length})',
                        style: AppTextStyles.caption.copyWith(
                          color: _selectedActivityTab == 0
                              ? (isDark ? Colors.white : AppColors.primary900)
                              : context.textSecondary,
                          fontWeight: _selectedActivityTab == 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedActivityTab = 1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedActivityTab == 1
                          ? (isDark ? AppColors.cardNavyLight : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: _selectedActivityTab == 1
                          ? [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.3 : 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${l10n.promoPayoutHistory} (${data.payouts.length})',
                        style: AppTextStyles.caption.copyWith(
                          color: _selectedActivityTab == 1
                              ? (isDark ? Colors.white : AppColors.primary900)
                              : context.textSecondary,
                          fontWeight: _selectedActivityTab == 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _selectedActivityTab == 0
            ? _buildEarningsList(data)
            : _buildPayoutsList(data),
      ],
    );
  }

  Widget _buildEarningsList(PromoDashboardData data) {
    if (data.earnings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary100,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 44,
              color: context.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.promoNoEarningsYet,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.earnings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = data.earnings[index];
        return _buildEarningCard(item);
      },
    );
  }

  Widget _buildPayoutsList(PromoDashboardData data) {
    if (data.payouts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary100,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.payments_rounded,
              size: 44,
              color: context.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.promoNoPayoutsYet,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.payouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payout = data.payouts[index];
        return _buildPayoutCard(payout);
      },
    );
  }

  Widget _buildEarningCard(ReferralEarningItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = item.createdAt != null
        ? DateFormat('MMM d, yyyy').format(item.createdAt!)
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.emerald500.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              color: AppColors.emerald600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.inviteeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.promoEarningBase(
                    item.planName,
                    item.planBasePrice.toStringAsFixed(0),
                    item.commissionPercentage.toInt().toString(),
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: AppTextStyles.caption.copyWith(
                      color: context.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '+${item.earnedAmount.toStringAsFixed(2)} ETB',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.emerald600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(PayoutHistoryItem payout) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = payout.createdAt != null
        ? DateFormat('MMM d, yyyy').format(payout.createdAt!)
        : '';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (payout.status) {
      case 'approved':
        statusColor = AppColors.accent500;
        statusLabel = l10n.promoPayoutApproved;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'completed':
        statusColor = AppColors.emerald600;
        statusLabel = l10n.promoPayoutCompleted;
        statusIcon = Icons.verified_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusLabel = l10n.promoPayoutRejected;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = l10n.promoPayoutPending;
        statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.promoPayoutDestination(payout.phoneNumber),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: AppTextStyles.caption.copyWith(
                          color: context.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                if (payout.status == 'rejected' &&
                    payout.adminNotes != null &&
                    payout.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payout.adminNotes!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (payout.status == 'rejected') ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.promoPayoutRefunded,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.emerald500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${payout.amount.toStringAsFixed(2)} ETB',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: payout.status == 'rejected'
                  ? AppColors.error
                  : context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
