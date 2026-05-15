import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import 'create_order_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadOrders();
    });
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
        return AppColors.zinc400;
      default:
        return AppColors.primary400;
    }
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    return type == 'house' ? l10n.ordersTypeHouse : l10n.ordersTypeLand;
  }

  Color _typeColor(String type) {
    return type == 'house' ? AppColors.primary600 : AppColors.emerald500;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: context.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.ordersTitle),
        actions: [
          if (state.orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${state.total}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent600,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
          if (mounted) {
            ref.read(ordersProvider.notifier).loadOrders();
          }
        },
        backgroundColor: AppColors.accent500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(OrdersState state, AppLocalizations l10n) {
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
        onAction: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
          if (mounted) {
            ref.read(ordersProvider.notifier).loadOrders();
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WaveGlass(
              child: InkWell(
                onTap: () => _showOrderDetail(context, order, l10n),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              order.holdingType!,
                              AppColors.zinc100,
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
                          if (order.minBudget != null || order.maxBudget != null)
                            _infoChip(
                              Icons.monetization_on_outlined,
                              '${_formatPrice(order.minBudget)} - ${_formatPrice(order.maxBudget)} ETB',
                            ),
                          if ((order.minBudget != null || order.maxBudget != null) &&
                              (order.minArea != null || order.maxArea != null))
                            const SizedBox(width: 12),
                          if (order.minArea != null || order.maxArea != null)
                            _infoChip(
                              Icons.square_foot,
                              '${_formatPrice(order.minArea)} - ${_formatPrice(order.maxArea)} m²',
                            ),
                        ],
                      ),
                      if (order.locationDisplay.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.primary400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.locationDisplay,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.primary500),
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
          style: AppTextStyles.caption.copyWith(color: AppColors.primary600),
        ),
      ],
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(value);
  }

  void _showOrderDetail(BuildContext context, dynamic order, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.zinc300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildBadge(
                      _typeLabel(order.type, l10n),
                      _typeColor(order.type),
                      Colors.white,
                    ),
                    const SizedBox(width: 6),
                    if (order.holdingType != null)
                      _buildBadge(
                        order.holdingType!,
                        AppColors.zinc100,
                        AppColors.primary800,
                      ),
                    const Spacer(),
                    _buildBadge(
                      _statusLabel(order.status, l10n),
                      _statusColor(order.status).withValues(alpha: 0.15),
                      _statusColor(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (order.minBudget != null || order.maxBudget != null) ...[
                  _detailRow(l10n.ordersBudget,
                      '${_formatPrice(order.minBudget)} - ${_formatPrice(order.maxBudget)} ETB'),
                  const Divider(height: 16),
                ],
                if (order.minArea != null || order.maxArea != null) ...[
                  _detailRow(l10n.ordersArea,
                      '${_formatPrice(order.minArea)} - ${_formatPrice(order.maxArea)} m²'),
                  const Divider(height: 16),
                ],
                if (order.facingDirection != null) ...[
                  _detailRow(l10n.ordersFacing,
                      order.facingDirection!.replaceAll('_', ' ')),
                  const Divider(height: 16),
                ],
                if (order.locationDisplay.isNotEmpty) ...[
                  _detailRow(l10n.ordersLocation, order.locationDisplay),
                  const Divider(height: 16),
                ],
                _detailRow(l10n.ordersDescription, order.description, isDescription: true),
                const SizedBox(height: 16),
                if (order.isActive)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmCancel(order.id, l10n),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                            foregroundColor: AppColors.error,
                          ),
                          child: Text(l10n.ordersCancel),
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

  Widget _detailRow(String label, String value, {bool isDescription = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary400,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary900,
            fontWeight: FontWeight.w700,
          ),
          maxLines: isDescription ? 10 : 2,
          overflow: isDescription ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _confirmCancel(int orderId, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.ordersCancel),
        content: Text(l10n.ordersCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.listingsYes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(ordersProvider.notifier).cancelOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.ordersCancelled : l10n.commonError),
            backgroundColor: success ? AppColors.accent500 : AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSkeletonList(int count) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WaveGlass(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _SkeletonBox(width: 60, height: 22),
                    Spacer(),
                    _SkeletonBox(width: 70, height: 22),
                  ]),
                  SizedBox(height: 12),
                  _SkeletonBox(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 200, height: 14),
                  SizedBox(height: 10),
                  Row(children: [
                    _SkeletonBox(width: 120, height: 14),
                    SizedBox(width: 12),
                    _SkeletonBox(width: 100, height: 14),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.zinc200,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
