import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Payment History Screen
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentHistoryProvider.notifier).loadPayments();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(paymentHistoryProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading) {
      final nextPage = (state.payments.length ~/ 15) + 1;
      ref.read(paymentHistoryProvider.notifier).loadPayments(page: nextPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentHistoryProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profilePayments),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PaymentHistoryState state) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading && state.payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.payments.isEmpty) {
      return WaveMessageScreen.error(
        title: 'Error Loading Payments',
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(paymentHistoryProvider.notifier).loadPayments();
        },
        isEmbedded: true,
      );
    }

    if (state.payments.isEmpty) {
      return WaveEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.paymentsEmpty,
        subtitle: l10n.settingsPaymentsSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(paymentHistoryProvider.notifier).loadPayments();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.payments.length + (state.isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= state.payments.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final payment = state.payments[index];
          return _PaymentTile(payment: payment);
        },
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final dynamic payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: payment.isSuccess
              ? AppColors.emerald50
              : payment.isFailed
                  ? Colors.red[50]!
                  : AppColors.accent50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          payment.isSuccess
              ? Icons.check_circle
              : payment.isFailed
                  ? Icons.cancel_outlined
                  : Icons.pending,
          size: 24,
          color: payment.isSuccess
              ? AppColors.emerald600
              : payment.isFailed
                  ? Colors.red[600]
                  : AppColors.accent600,
        ),
      ),
      title: Text(
        _paymentTitle(payment, context),
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${l10n.paymentsRef}: ${payment.transactionReference ?? l10n.commonNA}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(payment.createdAt, context),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.zinc400,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            payment.displayAmount,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary900,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor(payment).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              payment.statusLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: _statusColor(payment),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _paymentTitle(dynamic payment, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = payment.paymentType.toString().split('.').last;
    switch (type) {
      case 'subscription':
        return l10n.paymentsSubscription;
      case 'featuredListing':
        return l10n.paymentsFeatured;
      case 'directPayment':
        return l10n.paymentsDirect;
      default:
        return l10n.paymentsGeneral;
    }
  }

  String _formatDate(dynamic date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (date == null) return l10n.paymentsUnknownDate;
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return date.toString();
  }

  Color _statusColor(dynamic payment) {
    if (payment.isSuccess) return AppColors.emerald600;
    if (payment.isFailed) return Colors.red[600]!;
    if (payment.isCancelled) return AppColors.zinc500;
    return AppColors.accent600;
  }
}
