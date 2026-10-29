import '../../../core/utils/type_utils.dart';

/// Server-side notification filter.
enum NotificationFilter {
  all('all'),
  unread('unread'),
  read('read');

  final String wireValue;

  const NotificationFilter(this.wireValue);
}

/// A notification from `/v2/notifications`.
///
/// Named [AppNotification] so it can coexist with the legacy `Notification`
/// model while screens migrate.
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final String? actionUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data = const {},
    this.actionUrl,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  bool get isUnread => !isRead;

  /// Listing id carried by listing-related notifications, when present.
  int? get listingId => TypeUtils.safeInt(data['listing_id']);

  /// Conversation id carried by message notifications, when present.
  int? get conversationId => TypeUtils.safeInt(data['conversation_id']);

  AppNotification copyWith({bool? isRead, DateTime? readAt}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      data: data,
      actionUrl: actionUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return AppNotification(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: rawData is Map ? Map<String, dynamic>.from(rawData) : const {},
      actionUrl: _text(json['action_url']),
      isRead: TypeUtils.safeBool(json['is_read']),
      readAt: _date(json['read_at']),
      createdAt: _date(json['created_at']),
    );
  }
}

/// Unread counters for the notification and message tab badges.
class NotificationCounters {
  final int notifications;
  final int messages;

  const NotificationCounters({this.notifications = 0, this.messages = 0});

  int get total => notifications + messages;

  factory NotificationCounters.fromJson(Map<String, dynamic> json) {
    return NotificationCounters(
      notifications: TypeUtils.safeInt(json['notifications']) ?? 0,
      messages: TypeUtils.safeInt(json['messages']) ?? 0,
    );
  }
}

/// Result of marking one notification as read.
class NotificationReadReceipt {
  final int id;
  final bool isRead;
  final DateTime? readAt;
  final int unreadCount;

  const NotificationReadReceipt({
    required this.id,
    required this.isRead,
    this.readAt,
    this.unreadCount = 0,
  });

  factory NotificationReadReceipt.fromJson(Map<String, dynamic> json) {
    return NotificationReadReceipt(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      isRead: TypeUtils.safeBool(json['is_read']),
      readAt: _date(json['read_at']),
      unreadCount: TypeUtils.safeInt(json['unread_count']) ?? 0,
    );
  }
}

/// Result of marking every notification as read.
class MarkAllReadResult {
  final int updated;
  final int unreadCount;

  const MarkAllReadResult({this.updated = 0, this.unreadCount = 0});

  factory MarkAllReadResult.fromJson(Map<String, dynamic> json) {
    return MarkAllReadResult(
      updated: TypeUtils.safeInt(json['updated']) ?? 0,
      unreadCount: TypeUtils.safeInt(json['unread_count']) ?? 0,
    );
  }
}

String? _text(dynamic value) {
  final text = value?.toString();
  return (text == null || text.isEmpty) ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
