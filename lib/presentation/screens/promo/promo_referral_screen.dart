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
import '../../widgets/common/wave_liquid_glass.dart';

/// Screen displaying the user's promo code, referral link, wallet balance,
/// Telebirr withdrawal flow, and detailed earning history.
class PromoReferralScreen extends ConsumerStatefulWidget {
  const PromoReferralScreen({super.key});

  @override
  ConsumerState<PromoReferralScreen> createState() => _PromoReferralScreenState();
}

class _PromoReferralScreenState extends ConsumerState<PromoReferralScreen> {
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
                _buildWalletCard(data),
                const SizedBox(height: 18),
                _buildPromoCodeCard(data),
                const SizedBox(height: 18),
                _buildStatsGrid(data),
                const SizedBox(height: 24),
                _buildEarningsSection(data),
                if (data.payouts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildPayoutHistorySection(data),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LiquidGlass(
      borderRadius: 20,
      blur: 16,
      variant: LiquidGlassVariant.prominent,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.emerald500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.promoWalletBalance,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.promoMinWithdraw(
                        data.minWithdrawAmount.toStringAsFixed(0),
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: context.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.canWithdraw
                            ? AppColors.emerald500
                            : context.textMuted,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${data.walletBalance.toStringAsFixed(2)} ETB',
            style: AppTextStyles.headline1.copyWith(
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Primary action: Full-width Withdraw via Telebirr
          WaveButton(
            text: l10n.promoWithdrawTelebirr,
            icon: Icons.payments_rounded,
            variant: ButtonVariant.primary,
            isFullWidth: true,
            height: 46,
            onPressed: data.canWithdraw
                ? () => _showWithdrawModal(context, data)
                : null,
          ),
          const SizedBox(height: 10),

          // Secondary action: Full-width Use for Package
          WaveButton(
            text: l10n.promoUseForPackage,
            icon: Icons.diamond_rounded,
            variant: ButtonVariant.outline,
            isFullWidth: true,
            height: 42,
            onPressed: data.walletBalance > 0
                ? () => context.push('/subscriptions')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeCard(PromoDashboardData data) {
    return LiquidGlass(
      borderRadius: 20,
      blur: 16,
      variant: LiquidGlassVariant.regular,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.accent500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.promoYourCode,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.promoInviteDiscount(
                        data.discountPercentage.toInt().toString(),
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Code display box with Copy action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accent500.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data.promoCode,
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.accent500,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _copyPromoCode(data.promoCode),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(l10n.promoCopyCode),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent500,
                    textStyle: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Share Button
          WaveButton(
            text: l10n.promoShare,
            icon: Icons.share_rounded,
            isFullWidth: true,
            height: 44,
            onPressed: () => _sharePromoCode(data),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(PromoDashboardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary100,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatTile(
                title: l10n.promoStatsInvited,
                value: data.totalInvited.toString(),
                icon: Icons.people_outline_rounded,
                accentColor: AppColors.accent500,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 0.8,
              color: context.divider.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _buildStatTile(
                title: l10n.promoStatsSubscribed,
                value: data.totalSubscribed.toString(),
                icon: Icons.verified_user_rounded,
                accentColor: AppColors.emerald500,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 0.8,
              color: context.divider.withValues(alpha: 0.5),
            ),
            Expanded(
              child: _buildStatTile(
                title: l10n.promoStatsEarned,
                value: '${data.totalEarned.toStringAsFixed(0)} ETB',
                icon: Icons.monetization_on_rounded,
                accentColor: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: context.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSection(PromoDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.promoEarningsHistory,
          style: AppTextStyles.titleSmall.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (data.earnings.isEmpty)
          Container(
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
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.earnings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = data.earnings[index];
              return _buildEarningCard(item);
            },
          ),
      ],
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

  Widget _buildPayoutHistorySection(PromoDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.promoPayoutHistory,
          style: AppTextStyles.titleSmall.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (data.payouts.isEmpty)
          Container(
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
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.payouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final payout = data.payouts[index];
              return _buildPayoutCard(payout);
            },
          ),
      ],
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
