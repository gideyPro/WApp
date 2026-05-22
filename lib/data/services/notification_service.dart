import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/notification.dart' as app;

/// Service for managing notifications
class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's notifications
  Future<NotificationResponse> getNotifications({
    int page = 1,
    String filter = 'all', // 'all', 'unread', 'read'
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'filter': filter == 'all' ? 'all' : filter,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        List<dynamic> notifList = _extractList(responseData);
        int currentPage = page;
        int totalPages = 1;
        int total = 0;
        int unreadCount = 0;

        if (responseData is Map) {
          final dataField = responseData['data'];
          if (dataField is Map) {
            final notificationsRaw = dataField['notifications'];
            if (notificationsRaw is Map) {
              currentPage = (notificationsRaw['current_page'] ?? page).toInt();
              totalPages = (notificationsRaw['last_page'] ?? 1).toInt();
              total = (notificationsRaw['total'] ?? 0).toInt();
            }
            unreadCount = (dataField['unread_count'] ?? 0).toInt();
          }
        }

        final notifications = notifList
            .whereType<Map>()
            .map((json) => app.Notification.fromJson(json as Map<String, dynamic>))
            .toList();

        return NotificationResponse(
          success: true,
          notifications: notifications,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
          unreadCount: unreadCount,
        );
      }

      return NotificationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch notifications'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get unread notification count
  Future<NotificationCountResponse> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.unreadCount);

      if (response.statusCode == 200) {
        final responseData = response.data;
        int count = 0;
        
        if (responseData is Map) {
          if (responseData['unread_count'] != null) {
            count = (responseData['unread_count'] as num).toInt();
          } else if (responseData['count'] != null) {
            count = (responseData['count'] as num).toInt();
          } else if (responseData['data'] is Map) {
            final data = responseData['data'];
            if (data['unread_count'] != null) {
              count = (data['unread_count'] as num).toInt();
            } else if (data['count'] != null) {
              count = (data['count'] as num).toInt();
            }
          }
        }
        
        return NotificationCountResponse(
          success: true,
          count: count,
        );
      }

      return const NotificationCountResponse(
        success: false,
        count: 0,
      );
    } catch (e) {
      return const NotificationCountResponse(success: false, count: 0);
    }
  }

  /// Mark notification as read
  Future<NotificationResponse> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.markAsRead}/$notificationId/read',
      );

      if (response.statusCode == 200) {
        return NotificationResponse(
          success: true,
          message: _extractMessage(response.data, 'Marked as read'),
        );
      }

      return NotificationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to mark as read'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Mark all notifications as read
  Future<NotificationResponse> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.markAllAsRead);

      if (response.statusCode == 200) {
        return NotificationResponse(
          success: true,
          message: _extractMessage(response.data, 'All marked as read'),
        );
      }

      return NotificationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to mark all as read'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete notification
  Future<NotificationResponse> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteNotification}/$notificationId',
      );

      if (response.statusCode == 200) {
        return NotificationResponse(
          success: true,
          message: _extractMessage(response.data, 'Notification deleted'),
        );
      }

      return NotificationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to delete notification'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return NotificationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Helper to extract list from dynamic response
  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final dataField = raw['data'];
      if (dataField is Map) {
        final notificationsRaw = dataField['notifications'];
        if (notificationsRaw is Map && notificationsRaw['data'] is List) {
          return notificationsRaw['data'];
        }
        if (notificationsRaw is List) return notificationsRaw;
      }
      if (raw['notifications'] is List) return raw['notifications'];
      if (raw['data'] is List) return raw['data'];
    }
    return [];
  }

  /// Helper to extract message from dynamic response
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map && raw['message'] != null) {
      return raw['message'].toString();
    }
    return defaultMessage;
  }
}

/// Response wrapper for notification operations
class NotificationResponse {
  final bool success;
  final String message;
  final List<app.Notification> notifications;
  final int? currentPage;
  final int? totalPages;
  final int? total;
  final int unreadCount;

  const NotificationResponse({
    required this.success,
    this.message = '',
    this.notifications = const [],
    this.currentPage,
    this.totalPages,
    this.total,
    this.unreadCount = 0,
  });
}

/// Response wrapper for notification count
class NotificationCountResponse {
  final bool success;
  final int count;

  const NotificationCountResponse({
    required this.success,
    required this.count,
  });
}
