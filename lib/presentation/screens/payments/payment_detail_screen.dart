import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/v2/api_v2_error.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ethiopian_date_helper.dart';
import '../../../../data/models/v2/payment_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final String txRef;

  const PaymentDetailScreen({super.key, required this.txRef});

  @override
  ConsumerState<PaymentDetailScreen> createState() =>
      _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  PaymentState? _payment;
  bool _isLoading = true;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payment =
          await ref.read(paymentV2ServiceProvider).fetchOne(widget.txRef);
      if (mounted) {
        setState(() {
          _payment = payment;
          _isLoading = false;
        });
      }
    } on ApiV2Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load payment details';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPayment() async {
    setState(() => _isVerifying = true);
    try {
      final receipt =
          await ref.read(paymentV2ServiceProvider).verify(widget.txRef);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(receipt.isActivated
                ? 'Subscription activated!'
                : 'Payment verified'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(subscriptionOverviewProvider);
        _loadPayment();
      }
    } on ApiV2Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(title: Text(l10n.profilePayments)),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return WaveMessageScreen.error(
        title: l10n.errorLoadingPayments,
        subtitle: _error!,
        onRetry: _loadPayment,
        isEmbedded: true,
      );
    }

    final payment = _payment;
    if (payment == null) {
      return WaveEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.paymentsEmpty,
        subtitle: l10n.settingsPaymentsSubtitle,
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          _buildStatusBanner(payment, l10n),
          const SizedBox(height: 20),
          _buildDetailCard(payment, l10n),
          if (payment.paidAt != null) ...[
            const SizedBox(height: 20),
            _buildTimestampCard(payment, l10n),
          ],
          if (payment.isPending) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyPayment,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Verify Payment Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner(PaymentState payment, AppLocalizations l10n) {
    final isDark = context.theme.isDark;
    Color bgColor;
    Color iconColor;
    Color textColor;
    IconData icon;

    if (payment.isSuccess) {
      bgColor = isDark
          ? AppColors.emerald500.withValues(alpha: 0.15)
          : AppColors.emerald50;
      iconColor = isDark ? AppColors.emerald400 : AppColors.emerald600;
      textColor = isDark ? AppColors.emerald300 : AppColors.emerald800;
      icon = Icons.check_circle;
    } else if (payment.isFailed) {
      bgColor = isDark
          ? AppColors.error.withValues(alpha: 0.15)
          : AppColors.errorLight;
      iconColor = isDark ? Colors.red.shade300 : AppColors.error;
      textColor = isDark ? Colors.red.shade200 : Colors.red.shade800;
      icon = Icons.cancel_outlined;
    } else if (payment.isCancelled) {
      bgColor = isDark ? AppColors.cardNavyLight : AppColors.stone100;
      iconColor = isDark ? AppColors.stone400 : AppColors.stone500;
      textColor = isDark ? AppColors.stone300 : AppColors.stone600;
      icon = Icons.cancel_outlined;
    } else {
      bgColor = isDark
          ? AppColors.accent500.withValues(alpha: 0.15)
          : AppColors.accent50;
      iconColor = isDark ? AppColors.accent400 : AppColors.accent600;
      textColor = isDark ? AppColors.accent300 : AppColors.warning;
      icon = Icons.pending;
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.getStatusLabel(l10n),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.displayAmount,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(PaymentState payment, AppLocalizations l10n) {
    return LiquidGlass(
      borderRadius: 16,
      blur: 20,
      variant: LiquidGlassVariant.regular,
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Amount', payment.displayAmount),
          _detailRow('Type', _paymentTypeLabel(payment, l10n)),
          _detailRow('Method', payment.paymentMethod ?? 'Chapa'),
          _detailRow('Transaction Ref', payment.txRef),
          _detailRow('Status', payment.getStatusLabel(l10n)),
          if (payment.createdAt != null)
            _detailRow('Date', _formatDate(payment.createdAt!)),
        ],
      ),
    );
  }

  Widget _buildTimestampCard(PaymentState payment, AppLocalizations l10n) {
    return LiquidGlass(
      borderRadius: 16,
      blur: 20,
      variant: LiquidGlassVariant.regular,
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (payment.createdAt != null)
            _timelineRow(
              icon: Icons.receipt_long,
              label: 'Created',
              value: _formatDate(payment.createdAt!),
            ),
          if (payment.paidAt != null) ...[
            const SizedBox(height: 12),
            _timelineRow(
              icon: Icons.check_circle_outline,
              label: 'Paid At',
              value: _formatDate(payment.paidAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = context.theme.isDark;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardNavyLight : AppColors.primary50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: context.theme.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _paymentTypeLabel(PaymentState payment, AppLocalizations l10n) {
    switch (payment.type) {
      case 'subscription':
        return l10n.paymentsSubscription;
      case 'feature':
      case 'featured':
      case 'featuredListing':
        return l10n.paymentsFeatured;
      default:
        return l10n.paymentsGeneral;
    }
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return '${EthiopianDateHelper.formatDual(date, locale)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
