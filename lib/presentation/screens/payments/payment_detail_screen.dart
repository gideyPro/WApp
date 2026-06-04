import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/ethiopian_date_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/models/payment.dart';
import '../../../../data/services/payment_service.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../core/constants/app_spacing.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final int paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PaymentDetailScreen> createState() =>
      _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  final PaymentService _paymentService = PaymentService();
  Payment? _payment;
  bool _isLoading = true;
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

    final result = await _paymentService.getPaymentDetail(widget.paymentId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        _payment = result.payment;
      } else {
        _error = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
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
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Payment payment, AppLocalizations l10n) {
    Color bgColor;
    Color iconColor;
    Color textColor;
    IconData icon;

    if (payment.isSuccess) {
      bgColor = AppColors.emerald50;
      iconColor = AppColors.emerald600;
      textColor = AppColors.emerald800;
      icon = Icons.check_circle;
    } else if (payment.isFailed) {
      bgColor = AppColors.errorLight;
      iconColor = AppColors.error;
      textColor = Colors.red.shade800;
      icon = Icons.cancel_outlined;
    } else if (payment.isCancelled) {
      bgColor = AppColors.stone100;
      iconColor = AppColors.stone500;
      textColor = AppColors.stone600;
      icon = Icons.cancel_outlined;
    } else {
      bgColor = AppColors.accent50;
      iconColor = AppColors.accent600;
      textColor = AppColors.warning;
      icon = Icons.pending;
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
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

  Widget _buildDetailCard(Payment payment, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stone200),
      ),
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
          _detailRow('Transaction Ref', payment.transactionReference),
          if (payment.chapaTransactionId != null)
            _detailRow('Chapa Ref', payment.chapaTransactionId!),
          _detailRow('Status', payment.getStatusLabel(l10n)),
          _detailRow('Date', _formatDate(payment.createdAt)),
        ],
      ),
    );
  }

  Widget _buildTimestampCard(Payment payment, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stone200),
      ),
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
          _timelineRow(
            icon: Icons.receipt_long,
            label: 'Created',
            value: _formatDate(payment.createdAt),
          ),
          const SizedBox(height: 12),
          _timelineRow(
            icon: Icons.check_circle_outline,
            label: 'Paid At',
            value: _formatDate(payment.paidAt!),
          ),
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
                color: AppColors.stone500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
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
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary600),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(
              color: AppColors.stone500,
            )),
            Text(value, style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ],
    );
  }

  String _paymentTypeLabel(Payment payment, AppLocalizations l10n) {
    switch (payment.paymentType) {
      case PaymentType.subscription:
        return l10n.paymentsSubscription;
      case PaymentType.featuredListing:
        return l10n.paymentsFeatured;
      case PaymentType.directPayment:
        return l10n.paymentsDirect;
    }
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return '${EthiopianDateHelper.formatDual(date, locale)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
