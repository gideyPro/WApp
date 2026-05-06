import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/notification.dart' as app;
import '../../../../data/services/notification_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../listing/listing_detail_screen.dart';
import '../messages/messages_screen.dart';
import '../../../../l10n/app_localizations.dart';

/// Notifications Screen - Wired to notificationsProvider
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  final NotificationService _notificationService = NotificationService();

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
      appBar: AppBar(
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
                style: TextStyle(
                  color: AppColors.wave600,
                  fontSize: 14,
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
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.errorMessage != null && state.notifications.isEmpty) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(notificationsProvider.notifier).loadNotifications();
        },
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
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.notifications.length + (state.isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final notification = state.notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDismissed: () => _deleteNotification(notification.id),
          );
        },
      ),
    );
  }

  Future<void> _handleNotificationTap(app.Notification notification) async {
    // Mark as read
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case app.NotificationType.listingApproved:
      case app.NotificationType.listingRejected:
      case app.NotificationType.featuredListingExpired:
        // Navigate to listing detail
        if (notification.relatedId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ListingDetailScreen(listingId: notification.relatedId!),
            ),
          );
        }
        break;
      case app.NotificationType.newMessage:
        // Navigate to messages
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MessagesScreen()),
        );
        break;
      case app.NotificationType.newInterest:
        if (notification.relatedId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ListingDetailScreen(listingId: notification.relatedId!),
            ),
          );
        }
        break;
      case app.NotificationType.paymentSuccess:
      case app.NotificationType.subscriptionActivated:
        // Could navigate to payment history or subscriptions
        break;
      case app.NotificationType.systemAnnouncement:
        // Just show the notification content
        break;
    }
  }

  Future<void> _deleteNotification(int id) async {
    final response = await _notificationService.deleteNotification(id);
    if (response.success) {
      // Reload notifications to reflect deletion
      ref.read(notificationsProvider.notifier).loadNotifications();
    }
  }
}

/// Notification Tile Widget
class _NotificationTile extends StatelessWidget {
  final app.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final l10n = AppLocalizations.of(context);
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.notificationsDeleteTitle),
            content: Text(l10n.notificationsDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.notificationsDelete),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDismissed(),
      child: Material(
        color: notification.isRead ? context.theme.surface : (context.theme.isDark ? AppColors.navy800 : AppColors.wave50),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.isRead ? (context.theme.isDark ? AppColors.navy800 : AppColors.navy50) : (context.theme.isDark ? AppColors.wave900 : AppColors.wave100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.icon,
              size: 24,
                color:
                  notification.isRead ? context.theme.textSecondary : AppColors.wave600,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                notification.displayTime,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.zinc400,
                ),
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.wave500,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: onTap,
        ),
      ),
    );
  }
}
