import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import 'auth_provider.dart';

/// Notification Provider
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
final notificationsProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(notificationServiceProvider), ref);
});
class UnreadNotifCountNotifier extends StateNotifier<int> {
  final NotificationService _notificationService;
  final Ref _ref;
  Timer? _timer;

  UnreadNotifCountNotifier(this._notificationService, this._ref) : super(0) {
    refresh();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    // Poll every 60 seconds as a fallback to FCM
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      final authState = _ref.read(authStateProvider);
      if (authState.isAuthenticated) {
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
      final response = await _notificationService.getNotifications(filter: 'unread', page: 1);
      if (response.success) {
        state = response.unreadCount;
      }
    } catch (e) {
      // Handle error silently for background polling
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final unreadCountProvider = StateNotifierProvider<UnreadNotifCountNotifier, int>((ref) {
  return UnreadNotifCountNotifier(ref.watch(notificationServiceProvider), ref);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final Ref _ref;
  NotificationNotifier(this._notificationService, this._ref)
      : super(const NotificationState.initial());

  Future<void> loadNotifications({int page = 1}) async {
    if (page == 1) state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _notificationService.getNotifications(page: page);
    if (response.success) {
      final newListings = page == 1
          ? response.notifications
          : [...state.notifications, ...response.notifications];
      state = NotificationState.loaded(
          notifications: newListings, total: response.total ?? 0);
      
      // Update unread count provider if we just loaded page 1
      if (page == 1) {
        _ref.read(unreadCountProvider.notifier).refresh();
      }
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> markAsRead(int id) async {
    await _notificationService.markAsRead(id);
    state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList());
    
    // Refresh unread count
    _ref.read(unreadCountProvider.notifier).refresh();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    state = state.copyWith(
        notifications:
            state.notifications.map((n) => n.copyWith(isRead: true)).toList());
    
    // Refresh unread count
    _ref.read(unreadCountProvider.notifier).refresh();
  }
}

class NotificationState {
  final bool isLoading;
  final List<dynamic> notifications;
  final int total;
  final String? errorMessage;
  const NotificationState(
      {required this.isLoading,
      this.notifications = const [],
      this.total = 0,
      this.errorMessage});
  const NotificationState.initial()
      : isLoading = true,
        notifications = const [],
        total = 0,
        errorMessage = null;
  const NotificationState.loaded({required this.notifications, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  NotificationState copyWith(
      {bool? isLoading,
      List<dynamic>? notifications,
      int? total,
      String? errorMessage}) {
    return NotificationState(
        isLoading: isLoading ?? this.isLoading,
        notifications: notifications ?? this.notifications,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}
