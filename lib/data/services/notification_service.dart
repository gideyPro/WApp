import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../models/notification.dart' as app;
import '../models/v2/app_notification.dart';
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/notification_service.dart';

/// Service for managing notifications backed by V2 API.
class NotificationService {
  final NotificationServiceV2 _v2;
  final Map<int, String> _cursors = {};

  NotificationService({ApiClient? apiClient, NotificationServiceV2? v2Service})
      : _v2 = v2Service ?? NotificationServiceV2();

  Future<NotificationResponse> getNotifications({
    int page = 1,
    String filter = 'all',
  }) async {
    try {
      if (page <= 1) {
        _cursors.clear();
      }
      final cursor = page > 1 ? _cursors[page] : null;

      final nFilter = switch (filter) {
        'unread' => NotificationFilter.unread,
        'read' => NotificationFilter.read,
        _ => NotificationFilter.all,
      };

      final result = await _v2.fetch(cursor: cursor, filter: nFilter, limit: 30);
      if (result.nextCursor != null) {
        _cursors[page + 1] = result.nextCursor!;
      }
      final notifications =
          result.items.map((n) => n.toLegacyNotification()).toList();

      int unread = 0;
      try {
        final counters = await _v2.unreadCount();
        unread = counters.notifications;
      } catch (_) {}

      return NotificationResponse(
        success: true,
        notifications: notifications,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: notifications.length,
        unreadCount: unread,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<NotificationCountResponse> getUnreadCount() async {
    try {
      final counters = await _v2.unreadCount();
      return NotificationCountResponse(
        success: true,
        count: counters.notifications,
      );
    } catch (_) {
      return const NotificationCountResponse(success: false, count: 0);
    }
  }

  Future<NotificationResponse> markAsRead(int notificationId) async {
    try {
      await _v2.markRead(notificationId);
      return const NotificationResponse(
        success: true,
        message: 'Marked as read',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<NotificationResponse> markAllAsRead() async {
    try {
      await _v2.markAllRead();
      return const NotificationResponse(
        success: true,
        message: 'All notifications marked as read',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<NotificationResponse> deleteNotification(int notificationId) async {
    try {
      await _v2.delete(notificationId);
      return const NotificationResponse(
        success: true,
        message: 'Notification deleted',
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

class NotificationResponse {
  final bool success;
  final String message;
  final List<app.Notification> notifications;
  final int? currentPage;
  final int? totalPages;
  final int? total;
  final int? unreadCount;

  const NotificationResponse({
    required this.success,
    this.message = '',
    this.notifications = const [],
    this.currentPage,
    this.totalPages,
    this.total,
    this.unreadCount,
  });

  @override
  String toString() =>
      'NotificationResponse(success: $success, notifications: ${notifications.length})';
}

class NotificationCountResponse {
  final bool success;
  final int count;

  const NotificationCountResponse({
    required this.success,
    required this.count,
  });
}
