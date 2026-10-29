import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/app_notification.dart';
import '../../data/services/fcm_service.dart';
import '../../data/services/v2/notification_service.dart';
import 'auth_provider.dart';

/// Notification reads and state for the `/v2/notifications` feed.
final notificationsProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(NotificationServiceV2(), ref);
});

/// Tab badge. Refreshed on resume, after reads, and on FCM delivery.
final unreadCountProvider =
    StateNotifierProvider<UnreadNotifCountNotifier, int>((ref) {
  return UnreadNotifCountNotifier(NotificationServiceV2(), ref);
});

class UnreadNotifCountNotifier extends StateNotifier<int> {
  final NotificationServiceV2 _notificationService;
  final Ref _ref;
  Timer? _timer;

  UnreadNotifCountNotifier(this._notificationService, this._ref) : super(0) {
    refresh();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    // Poll every 60 seconds as a fallback to FCM.
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_ref.read(authStateProvider).isAuthenticated) {
        refresh();
      }
    });
  }

  Future<void> refresh() async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (state != 0) state = 0;
      return;
    }

    try {
      final counters = await _notificationService.unreadCount();
      setCount(counters.notifications);
    } catch (_) {
      // Background polling stays silent; the screen shows its own errors.
    }
  }

  /// Use the count returned by a read receipt instead of re-fetching.
  void setCount(int value) {
    final next = value < 0 ? 0 : value;
    if (state != next) state = next;
  }

  void pausePolling() {
    _timer?.cancel();
    _timer = null;
  }

  void resumePolling() {
    _timer?.cancel();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationServiceV2 _notificationService;
  final Ref _ref;

  NotificationNotifier(this._notificationService, this._ref)
      : super(const NotificationState.initial());

  /// Load the first page. [silent] keeps the current list visible while an FCM
  /// push or a tab switch refreshes it in the background.
  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final page = await _notificationService.fetch();
      state = NotificationState.loaded(
        notifications: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
      _ref.read(unreadCountProvider.notifier).refresh();
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load notifications',
      );
    }
  }

  /// Append the next cursor page. Safe to call repeatedly while scrolling.
  Future<void> loadMore() async {
    final cursor = state.nextCursor;

    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final page = await _notificationService.fetch(cursor: cursor);
      state = state.copyWith(
        notifications: [...state.notifications, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoadingMore: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more notifications',
      );
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final receipt = await _notificationService.markRead(id);
      state = state.copyWith(
        notifications: state.notifications
            .map((notification) => notification.id == id
                ? notification.copyWith(isRead: true, readAt: receipt.readAt)
                : notification)
            .toList(),
      );

      // Dismiss from the notification shade.
      FcmService.dismissShadeNotification(id);
      _ref.read(unreadCountProvider.notifier).setCount(receipt.unreadCount);
    } catch (_) {
      // The tap still navigates if the read receipt fails.
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final result = await _notificationService.markAllRead();
      state = state.copyWith(
        notifications: state.notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList(),
      );

      FcmService.dismissAllShadeNotifications();
      _ref.read(unreadCountProvider.notifier).setCount(result.unreadCount);
    } catch (_) {
      // Leave the list untouched; the next refresh will reconcile it.
    }
  }

  Future<void> delete(int id) async {
    try {
      await _notificationService.delete(id);
      state = state.copyWith(
        notifications: state.notifications
            .where((notification) => notification.id != id)
            .toList(),
      );
    } catch (_) {
      // A failed delete should not break the feed.
    }
  }
}

class NotificationState {
  final bool isLoading;
  final List<AppNotification> notifications;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const NotificationState({
    required this.isLoading,
    this.notifications = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  const NotificationState.initial()
      : isLoading = true,
        notifications = const [],
        nextCursor = null,
        hasMore = false,
        isLoadingMore = false,
        errorMessage = null;

  const NotificationState.loaded({
    required this.notifications,
    this.nextCursor,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  NotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}
