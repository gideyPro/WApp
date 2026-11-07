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
                _buildReferralCard(data),
                const SizedBox(height: 14),
                _buildWalletCard(data),
                const SizedBox(height: 16),
                _buildStatsGrid(data),
                const SizedBox(height: 22),
                _buildActivitySection(data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact Referral Code & Share Card (Option 1)
  Widget _buildReferralCard(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label & Discount Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.promoYourCode.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: context.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accent500.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_offer_rounded,
                      size: 11,
                      color: AppColors.accent500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.promoReferralHeaderDiscount(
                        data.discountPercentage.toInt().toString(),
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent500,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Code Box + Share Button Row
          Row(
            children: [
              // Code Box with Copy Chip
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1E36)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFCBD5E1),
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.promoCode,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: isDark ? Colors.white : AppColors.primary900,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Semantics(
                        button: true,
                        label: l10n.promoCopyCode,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _copyPromoCode(data.promoCode);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent500.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.promoCopyCode,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent500,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Share Button
              Semantics(
                button: true,
                label: l10n.promoShare,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _sharePromoCode(data);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.share_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.promoShare,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
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

          // Subtitle Note
          Text(
            l10n.promoReferralNote(data.discountPercentage.toInt().toString()),
            style: AppTextStyles.caption.copyWith(
              color: context.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Wallet Balance & Actions Card (Option 1)
  Widget _buildWalletCard(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance & Actions Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Balance Side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.promoWalletBalance.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: context.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          data.walletBalance.toStringAsFixed(2),
                          style: AppTextStyles.title.copyWith(
                            color: isDark ? Colors.white : AppColors.primary900,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ETB',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent500,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(${l10n.promoMinWithdrawRequirement(data.minWithdrawAmount.toStringAsFixed(0))})',
                      style: AppTextStyles.caption.copyWith(
                        color: context.textMuted,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Action Buttons: Withdraw & Use
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Withdraw Button
                  Semantics(
                    button: true,
                    label: l10n.promoWithdrawTelebirr,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: data.canWithdraw
                            ? () {
                                HapticFeedback.lightImpact();
                                _showWithdrawModal(context, data);
                              }
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                    : AppColors.stone200),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: data.canWithdraw
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 14,
                                  color: data.canWithdraw
                                      ? const Color(0xFF041E15)
                                      : context.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.promoWithdrawSubmit,
                                  style: AppTextStyles.caption.copyWith(
                                    color: data.canWithdraw
                                        ? const Color(0xFF041E15)
                                        : context.textMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Use Button
                  Semantics(
                    button: true,
                    label: l10n.promoUseForPackage,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: data.walletBalance > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                context.push('/subscriptions');
                              }
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardNavyLight
                                : AppColors.stone100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFCBD5E1),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.diamond_outlined,
                                  size: 13,
                                  color: data.walletBalance > 0
                                      ? AppColors.accent500
                                      : context.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Use',
                                  style: AppTextStyles.caption.copyWith(
                                    color: data.walletBalance > 0
                                        ? context.textPrimary
                                        : context.textMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
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
          const SizedBox(height: 12),

          // Status Line
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: data.canWithdraw
                      ? AppColors.emerald500
                      : const Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.canWithdraw
                      ? l10n.promoReadyToWithdraw
                      : l10n.promoEarnMoreToWithdraw(
                          (data.minWithdrawAmount - data.walletBalance)
                              .toStringAsFixed(0),
                        ),
                  style: AppTextStyles.caption.copyWith(
                    color: data.canWithdraw
                        ? AppColors.emerald500
                        : const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
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
    final isSubscribed = item.isSubscribed;

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
          // Avatar Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSubscribed
                  ? AppColors.emerald500.withValues(alpha: 0.12)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSubscribed
                  ? Icons.attach_money_rounded
                  : Icons.person_add_alt_1_rounded,
              color: isSubscribed
                  ? AppColors.emerald600
                  : const Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // User details and plan/joined info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.inviteeName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Distinct Status Mark
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSubscribed
                            ? AppColors.emerald500.withValues(alpha: 0.12)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSubscribed
                              ? AppColors.emerald500.withValues(alpha: 0.25)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          width: 0.7,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSubscribed
                                  ? AppColors.emerald500
                                  : const Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 3.5),
                          Text(
                            isSubscribed
                                ? l10n.promoStatusSubscribed
                                : l10n.promoStatusNotSubscribed,
                            style: AppTextStyles.caption.copyWith(
                              color: isSubscribed
                                  ? AppColors.emerald600
                                  : const Color(0xFFD97706),
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isSubscribed
                      ? l10n.promoEarningBase(
                          item.planName,
                          item.planBasePrice.toStringAsFixed(0),
                          item.commissionPercentage.toInt().toString(),
                        )
                      : l10n.promoJoinedNoSubscription,
                  style: AppTextStyles.caption.copyWith(
                    color: context.textSecondary,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: AppTextStyles.caption.copyWith(
                      color: context.textMuted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount Earned
          Text(
            isSubscribed
                ? '+${item.earnedAmount.toStringAsFixed(2)} ETB'
                : '0.00 ETB',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isSubscribed
                  ? AppColors.emerald600
                  : context.textMuted,
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
