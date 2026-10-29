import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ethiopian_date_helper.dart';
import '../../../../data/models/v2/payment_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';

/// Payment History Screen backed by V2 `/v2/payments`
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
        !state.isLoading &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref.read(paymentHistoryProvider.notifier).loadMore();
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
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.profilePayments),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PaymentHistoryState state) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading && state.payments.isEmpty) {
      return _buildSkeletonList();
    }

    if (state.errorMessage != null && state.payments.isEmpty) {
      return WaveMessageScreen.error(
        title: l10n.errorLoadingPayments,
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
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.paddingLg,
        itemCount: state.payments.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.payments.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final payment = state.payments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                context.push('/payments/${payment.txRef}');
              },
              child: WaveGlass(
                child: _PaymentTile(payment: payment),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.shimmerBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 14, width: 140, color: context.shimmerBase),
                      const SizedBox(height: 8),
                      Container(
                          height: 12, width: 200, color: context.shimmerBase),
                      const SizedBox(height: 4),
                      Container(
                          height: 12, width: 100, color: context.shimmerBase),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        height: 16, width: 80, color: context.shimmerBase),
                    const SizedBox(height: 6),
                    Container(
                      height: 18,
                      width: 60,
                      decoration: BoxDecoration(
                        color: context.shimmerBase,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentState payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.theme.isDark;
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: payment.isSuccess
                  ? (isDark
                      ? AppColors.emerald500.withValues(alpha: 0.15)
                      : AppColors.emerald50)
                  : payment.isFailed
                      ? (isDark
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.errorLight)
                      : (isDark
                          ? AppColors.accent500.withValues(alpha: 0.15)
                          : AppColors.accent50),
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
                  ? (isDark ? AppColors.emerald400 : AppColors.emerald600)
                  : payment.isFailed
                      ? (isDark ? Colors.red.shade300 : AppColors.error)
                      : (isDark ? AppColors.accent400 : AppColors.accent600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _paymentTitle(payment, context),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.paymentsRef}: ${payment.txRef.isNotEmpty ? payment.txRef : l10n.commonNA}',
                  style: AppTextStyles.caption
                      .copyWith(color: context.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(payment.createdAt, context),
                  style: AppTextStyles.caption.copyWith(
                    color: context.theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment.displayAmount,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.theme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(payment, isDark)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment.getStatusLabel(l10n),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _statusColor(payment, isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentTitle(PaymentState payment, BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

  String _formatDate(DateTime? date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (date == null) return l10n.paymentsUnknownDate;
    final locale = Localizations.localeOf(context).languageCode;
    return '${EthiopianDateHelper.formatDual(date, locale)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(PaymentState payment, bool isDark) {
    if (payment.isSuccess) {
      return isDark ? AppColors.emerald400 : AppColors.emerald600;
    }
    if (payment.isFailed) {
      return isDark ? Colors.red.shade300 : AppColors.error;
    }
    if (payment.isCancelled) {
      return isDark ? AppColors.stone400 : AppColors.stone500;
    }
    return isDark ? AppColors.accent400 : AppColors.accent600;
  }
}
