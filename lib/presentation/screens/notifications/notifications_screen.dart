import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/models/v2/app_notification.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import '../../../core/constants/app_spacing.dart';

/// Notifications Screen - wired to the v2 notification feed.
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

  /// Refresh notifications when tab becomes visible (IndexedStack keeps
  /// the widget alive but we detect tab-switch via [selectedTabProvider]).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(selectedTabProvider, (prev, next) {
      if (prev != next && next == 3 && mounted) {
        ref
            .read(notificationsProvider.notifier)
            .loadNotifications(silent: true);
        ref.read(unreadCountProvider.notifier).refresh();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        automaticallyImplyLeading: false,
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
      body: _buildBody(state),
    );
  }

  Widget _buildBody(NotificationState state) {
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
        itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
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
              borderRadius: 16,
              child: InkWell(
                onTap: () => _handleNotificationTap(notification),
                borderRadius: BorderRadius.circular(16),
                child: _NotificationTile(notification: notification),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
    }

    if (!mounted) return;

    // Prefer a relative action URL (deep link from the backend). Web URLs are
    // not openable by the app, so fall through to the type/data routing.
    final actionUrl = notification.actionUrl;
    if (actionUrl != null && actionUrl.startsWith('/')) {
      context.push(actionUrl);
      return;
    }

    switch (notification.type) {
      case 'listing_approved':
      case 'listing_published':
      case 'listing_update':
      case 'listing_featured':
      case 'listing_rejected':
      case 'listing_expired':
      case 'favorite':
      case 'inquiry':
      case 'new_interest':
        final listingId = _extractId(notification, 'listing_id');
        if (listingId != null) {
          context.push('/listings/$listingId');
        }
        break;

      case 'suggestion':
        final orderId = _extractId(notification, 'order_id');
        if (orderId != null) {
          context.push('/orders/$orderId');
        }
        break;

      case 'payment_success':
      case 'payment_failed':
        final paymentId = _extractId(notification, 'payment_id');
        context.push(paymentId != null ? '/payments/$paymentId' : '/payments');
        break;

      case 'subscription_activated':
        final paymentId = _extractId(notification, 'payment_id');
        context.push(
          paymentId != null ? '/payments/$paymentId' : '/subscriptions',
        );
        break;

      case 'subscription_expired':
        context.push('/subscriptions');
        break;

      case 'kyc_update':
      case 'kyc_submitted':
        context.push('/kyc');
        break;

      case 'conference_invite':
      case 'conference_update':
      case 'incoming_call':
        final conferenceId = _extractId(notification, 'conference_id');
        if (conferenceId != null) {
          final rawVideo = notification.data['is_video'];
          final isVideo = rawVideo == true || rawVideo == '1' || rawVideo == 1;
          context.push('/call/$conferenceId', extra: {'is_video': isVideo});
        }
        break;

      case 'message':
        final conversationId = _extractId(notification, 'conversation_id');
        if (conversationId != null) {
          context.push('/chat/$conversationId');
        } else {
          context.push('/messages');
        }
        break;

      default:
        break;
    }
  }

  int? _extractId(AppNotification notification, String key) {
    final value = notification.data[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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
                    borderRadius: BorderRadius.circular(12),
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
                      Container(
                          height: 12, width: 80, color: context.shimmerBase),
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
  final AppNotification notification;

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
                      ? AppColors.cardNavyLight
                      : AppColors.primary50)
                  : (context.theme.isDark
                      ? AppColors.accent500.withValues(alpha: 0.15)
                      : AppColors.accent100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForType(notification.type),
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
                  notification.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.theme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _displayTime(notification.createdAt, l10n),
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

  String _displayTime(DateTime? createdAt, AppLocalizations l10n) {
    if (createdAt == null) return '';

    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return l10n.notificationJustNow;
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'listing_approved':
      case 'listing_published':
      case 'listing_update':
      case 'listing_featured':
        return Icons.check_circle_outline;
      case 'listing_rejected':
      case 'listing_expired':
      case 'payment_failed':
        return Icons.error_outline;
      case 'favorite':
        return Icons.favorite_border;
      case 'inquiry':
      case 'new_interest':
        return Icons.interests_outlined;
      case 'payment_success':
        return Icons.payment_outlined;
      case 'subscription_activated':
        return Icons.star_outline;
      case 'subscription_expired':
        return Icons.timer_off_outlined;
      case 'kyc_update':
      case 'kyc_submitted':
        return Icons.verified_outlined;
      case 'conference_invite':
        return Icons.videocam_outlined;
      case 'conference_update':
        return Icons.info_outline;
      case 'incoming_call':
        return Icons.phone_in_talk_outlined;
      case 'suggestion':
        return Icons.auto_awesome;
      case 'message':
        return Icons.chat_bubble_outline;
      default:
        return Icons.campaign_outlined;
    }
  }
}
