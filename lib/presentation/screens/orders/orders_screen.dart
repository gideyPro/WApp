import '../../../core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_dialog.dart';
import '../../widgets/common/wave_glass.dart';

import '../subscriptions/subscription_plans_screen.dart';
import 'create_order_screen.dart';
import 'order_details_screen.dart';
import '../../../core/constants/app_spacing.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _isCreatingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  /// Pre-flight check before opening Create Order — force-refresh subscription, then check
  Future<void> _onCreateOrderTap() async {
    setState(() => _isCreatingOrder = true);
    try {
      await ref.read(subscriptionProvider.notifier).refresh();
      if (!mounted) return;
      final subState = ref.read(subscriptionProvider);

      if (!subState.canCreateOrder) {
        final l10n = AppLocalizations.of(context);
        String message;
        if (!subState.hasPaidSubscription) {
          message = l10n.ordersLimitMessage;
        } else {
          final plan = subState.subscription?.plan;
          if (plan == null || plan.maxOrders == 0) {
            message = l10n.subscriptionPlanNotSupportedOrder;
          } else {
            message = l10n.ordersLimitMessage;
          }
        }
        final goSub = await WaveDialog.showUpgrade(
          context: context,
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.accent500,
          title: l10n.ordersLimitTitle,
          message: message,
          actionLabel: l10n.ordersUpgradePlan,
        );
        if (goSub == true && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
          );
        }
        return;
      }

      // All good — open create order
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
        );
        if (mounted) ref.read(ordersProvider.notifier).loadOrders();
      }
    } finally {
      if (mounted) setState(() => _isCreatingOrder = false);
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return l10n.ordersStatusActive;
      case 'fulfilled':
        return l10n.ordersStatusFulfilled;
      case 'cancelled':
        return l10n.ordersStatusCancelled;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.accent500;
      case 'fulfilled':
        return AppColors.success;
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    return type == 'house' ? l10n.ordersTypeHouse : l10n.ordersTypeLand;
  }

  Color _typeColor(String type) {
    return type == 'house' ? AppColors.primary800 : AppColors.emerald500;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.ordersTitle),
            if (state.total > 0)
              Text(
                l10n.ordersCount(state.total.toString()),
                style: AppTextStyles.caption
                    .copyWith(color: context.theme.textMuted),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isCreatingOrder
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Icon(Icons.add_rounded),
            onPressed: _isCreatingOrder ? null : _onCreateOrderTap,
          ),
        ],
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(OrdersState state, AppLocalizations l10n) {
    final cache = ref.watch(addressCacheProvider);
    if (state.isLoading) {
      return _buildSkeletonList(5);
    }

    if (state.errorMessage != null) {
      return WaveMessageScreen.error(
        title: l10n.commonError,
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(ordersProvider.notifier).loadOrders();
        },
        isEmbedded: true,
      );
    }

    if (state.orders.isEmpty) {
      return WaveEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.ordersEmpty,
        subtitle: l10n.ordersEmptySubtitle,
        actionLabel: l10n.ordersCreate,
        onAction: _onCreateOrderTap,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).loadOrders(),
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WaveGlass(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(orderId: order.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadge(
                            _typeLabel(order.type, l10n),
                            _typeColor(order.type),
                            Colors.white,
                          ),
                          if (order.holdingType != null) ...[
                            const SizedBox(width: 6),
                            _buildBadge(
                              order.getLocalizedHoldingType(context),
                              AppColors.stone100,
                              AppColors.primary800,
                            ),
                          ],
                          const Spacer(),
                          _buildBadge(
                            _statusLabel(order.status, l10n),
                            _statusColor(order.status).withValues(alpha: 0.15),
                            _statusColor(order.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.description,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (order.minBudget != null ||
                              order.maxBudget != null)
                            _infoChip(
                              Icons.monetization_on_outlined,
                              _formatRange(
                                  order.minBudget, order.maxBudget, 'ETB'),
                            ),
                          if ((order.minBudget != null ||
                                  order.maxBudget != null) &&
                              (order.minArea != null || order.maxArea != null))
                            const SizedBox(width: 12),
                          if (order.minArea != null || order.maxArea != null)
                            _infoChip(
                              Icons.square_foot,
                              _formatRange(order.minArea, order.maxArea, 'm²'),
                            ),
                        ],
                      ),
                      if (order.address != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.address!.getLocalizedAddress(context, cache),
                                style: AppTextStyles.caption
                                    .copyWith(color: ThemeColors(context).textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList(int count) {
    return ListView.builder(
      padding: AppSpacing.paddingLg,
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: WaveGlass(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                    height: 14,
                    width: double.infinity,
                    color: AppColors.primary100),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                        width: 100, height: 14, color: AppColors.primary100),
                    const SizedBox(width: 12),
                    Container(
                        width: 80, height: 14, color: AppColors.primary100),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary400),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: ThemeColors(context).textSecondary),
        ),
      ],
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(value);
  }

  String _formatRange(double? min, double? max, String unit) {
    final l10n = AppLocalizations.of(context);
    if (min != null && max != null) {
      return '${_formatPrice(min)} - ${_formatPrice(max)} $unit';
    }
    if (min != null) return '${_formatPrice(min)}+ $unit';
    if (max != null) return l10n.orderUpTo(_formatPrice(max), unit);
    return '';
  }
}
