import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/notification.dart' as app;
import '../../../../data/services/notification_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_card.dart';
import '../listing/listing_detail_screen.dart';
import '../messages/messages_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../settings/settings_screen.dart';
import '../../../../l10n/app_localizations.dart';
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
                  color: AppColors.accent600,
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
      return _buildSkeletonList();
    }

    // Error state
    if (state.errorMessage != null && state.notifications.isEmpty) {
      return WaveMessageScreen.error(
        title: 'Error Loading Notifications',
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
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.notifications.length + (state.isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return const Padding(
              padding: AppSpacing.paddingLg,
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
      case app.NotificationType.newInterest:
        if (notification.relatedId != null) {
          _navigateToListingDetail(notification.relatedId!);
        }
        break;
      case app.NotificationType.newMessage:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MessagesScreen()),
        );
        break;
      case app.NotificationType.paymentSuccess:
      case app.NotificationType.subscriptionActivated:
      case app.NotificationType.systemAnnouncement:
        break;
    }
  }

  void _navigateToListingDetail(int listingId) {
    final subState = ref.read(subscriptionProvider);
    final settingsAsync = ref.read(appSettingsProvider);
    final user = ref.read(profileProvider).user;
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => true,
    );

    if (subscriptionEnabled && !subState.canCreateListing) {
      _showSubscriptionRequiredDialog();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listingId),
      ),
    );
  }

  Future<void> _showSubscriptionRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_outlined, size: 32, color: AppColors.accent600),
              ),
              const SizedBox(height: 16),
              const Text('Subscription Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text('You need an active subscription to view property details and contact owners.', style: TextStyle(color: AppColors.primary600), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: AppColors.primary200),
                        foregroundColor: AppColors.primary600,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: AppColors.accent600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Plans'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
      );
    }
  }

  Widget _buildSkeletonList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 160, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(height: 12, width: double.infinity, color: Colors.grey[300]),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 80, color: Colors.grey[300]),
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
          color: AppColors.error.withValues(alpha: 0.8),
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
      child: WaveCard(
        isGlass: true,
        showBorder: false,
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.isRead ? (context.theme.isDark ? AppColors.primary800 : AppColors.primary50) : (context.theme.isDark ? AppColors.accent900 : AppColors.accent100),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              notification.icon,
              size: 24,
                color:
                  notification.isRead ? context.theme.textSecondary : AppColors.accent600,
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
                    color: AppColors.accent500,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: onTap,
        ),
      ),
    );
  }
}
