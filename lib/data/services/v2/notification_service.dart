import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/app_notification.dart';

/// Notification reads and state mutations for `/v2/notifications`.
class NotificationServiceV2 {
  final ApiV2Client _client;

  NotificationServiceV2({ApiV2Client? client})
      : _client = client ?? ApiV2Client();

  Future<Paginated<AppNotification>> fetch({
    NotificationFilter filter = NotificationFilter.all,
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    return _client.getCollection(
      ApiV2Constants.notifications,
      parse: AppNotification.fromJson,
      query: {
        'filter': filter.wireValue,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<NotificationCounters> unreadCount() async {
    final data = await _client.getItem(ApiV2Constants.notificationsUnreadCount);
    return NotificationCounters.fromJson(data);
  }

  Future<NotificationReadReceipt> markRead(int id) async {
    final data = await _client.sendItem(
      ApiV2Constants.notificationRead(id),
      method: 'POST',
    );

    return NotificationReadReceipt.fromJson(data);
  }

  Future<MarkAllReadResult> markAllRead() async {
    final data = await _client.sendItem(
      ApiV2Constants.notificationsReadAll,
      method: 'POST',
    );

    return MarkAllReadResult.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.send(ApiV2Constants.notification(id), method: 'DELETE');
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit
        ? ApiV2Constants.maxLimit
        : limit;
  }
}
