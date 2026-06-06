import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/models/notification.dart' as app;
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import '../listing/listing_detail_screen.dart';
import '../orders/order_details_screen.dart';
import '../payments/payment_detail_screen.dart';
import '../payments/payment_history_screen.dart';
import '../../../core/constants/app_spacing.dart';

/// Notifications Screen - Wired to notificationsProvider
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(notificationsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading) {
      final nextPage = (state.notifications.length ~/ 10) + 1;
      ref
          .read(notificationsProvider.notifier)
          .loadNotifications(page: nextPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(l10n.settingsNotifications),
        actions: [
          // Mark all as read
          if (state.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                l10n.notificationsMarkAllRead,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accent500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(state, unreadCount),
    );
  }

  Widget _buildBody(NotificationState state, int unreadCount) {
    // Loading state (initial load)
    if (state.isLoading && state.notifications.isEmpty) {
      return _buildSkeletonList();
    }

    // Error state
    if (state.errorMessage != null && state.notifications.isEmpty) {
      return WaveMessageScreen.error(
        title: AppLocalizations.of(context).errorLoadingNotifications,
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(notificationsProvider.notifier).loadNotifications();
        },
        isEmbedded: true,
      );
    }

    // Empty state
    if (state.notifications.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return WaveEmptyState(
        icon: Icons.notifications_none,
        title: l10n.notificationsEmpty,
        subtitle: l10n.notificationsEmptySubtitle,
      );
    }

    // Notifications list
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationsProvider.notifier).loadNotifications();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.paddingLg,
        itemCount: state.notifications.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final notification = state.notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WaveGlass(
              child: InkWell(
                onTap: () => _handleNotificationTap(notification),
                borderRadius: BorderRadius.circular(4),
                child: _NotificationTile(notification: notification),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleNotificationTap(app.Notification notification) async {
    // Mark as read
    if (!notification.isRead) {
      try {
        await ref
            .read(notificationsProvider.notifier)
            .markAsRead(notification.id);
      } catch (_) {}
    }

    if (!mounted) return;

    // Navigate based on notification type
    switch (notification.type) {
      case app.NotificationType.listingApproved:
      case app.NotificationType.listingRejected:
      case app.NotificationType.featuredListingExpired:
      case app.NotificationType.newInterest:
        if (notification.relatedId != null) {
          _navigateToListingDetail(notification.relatedId!);
        }
        break;
      case app.NotificationType.suggestion:
        final orderId = notification.relatedId ??
            (notification.data?['order_id'] as int?) ??
            (notification.data?['order_id'] is num
                ? (notification.data!['order_id'] as num).toInt()
                : null);
        if (orderId != null) {
          try {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    OrderDetailsScreen.fromNotification(orderId: orderId),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open order: $e'), backgroundColor: AppColors.error));
          }
        }
        break;
      case app.NotificationType.paymentSuccess:
      case app.NotificationType.paymentFailed:
        {
          final paymentId = notification.relatedId ??
              (notification.data?['payment_id'] as int?) ??
              (notification.data?['payment_id'] is num
                  ? (notification.data!['payment_id'] as num).toInt()
                  : null);
          if (paymentId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    PaymentDetailScreen(paymentId: paymentId),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PaymentHistoryScreen(),
              ),
            );
          }
        }
        break;
      case app.NotificationType.subscriptionActivated:
      case app.NotificationType.systemAnnouncement:
        break;
    }
  }

  void _navigateToListingDetail(int listingId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listingId),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.shimmerBase,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 14, width: 160, color: context.shimmerBase),
                      const SizedBox(height: 8),
                      Container(
                          height: 12,
                          width: double.infinity,
                          color: context.shimmerBase),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 80, color: context.shimmerBase),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Notification Tile Widget
class _NotificationTile extends StatelessWidget {
  final app.Notification notification;

  const _NotificationTile({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? (context.theme.isDark
                      ? AppColors.primary800
                      : AppColors.primary50)
                  : (context.theme.isDark
                      ? AppColors.accent900
                      : AppColors.accent100),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              notification.icon,
              size: 24,
              color: notification.isRead
                  ? context.theme.textSecondary
                  : AppColors.accent600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight:
                        notification.isRead ? FontWeight.w500 : FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.theme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.getDisplayTime(l10n),
                  style: AppTextStyles.caption.copyWith(
                    color: context.theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent500,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
