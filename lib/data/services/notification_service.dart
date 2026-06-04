import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
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

        List<dynamic> notifList = ApiEnvelope.extractList(
          responseData,
          itemKeys: const ['notifications', 'items'],
        );

        final pagination = ApiEnvelope.extractPagination(responseData, fallbackPage: page);

        int unreadCount = 0;
        if (responseData is Map) {
          final dataField = responseData['data'];
          if (dataField is Map) {
            unreadCount = ApiEnvelope.safeIntOr(dataField['unread_count'], 0);
          }
        }

        final notifications = notifList
            .whereType<Map>()
            .map((json) => app.Notification.fromJson(json as Map<String, dynamic>))
            .toList();

        return NotificationResponse(
          success: true,
          notifications: notifications,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
          unreadCount: unreadCount,
        );
      }

      return NotificationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch notifications'),
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
          // Try top-level keys first, then nested under 'data'
          count = ApiEnvelope.safeIntOr(
            responseData['unread_count'] ?? responseData['count'],
            0,
          );
          if (count == 0 && responseData['data'] is Map) {
            final data = responseData['data'] as Map;
            count = ApiEnvelope.safeIntOr(
              data['unread_count'] ?? data['count'],
              0,
            );
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
          message: ApiEnvelope.extractMessage(response.data, 'Marked as read'),
        );
      }

      return NotificationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to mark as read'),
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
          message: ApiEnvelope.extractMessage(response.data, 'All marked as read'),
        );
      }

      return NotificationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to mark all as read'),
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
          message: ApiEnvelope.extractMessage(response.data, 'Notification deleted'),
        );
      }

      return NotificationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to delete notification'),
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
