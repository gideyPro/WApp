import 'package:flutter/material.dart';

/// Notification types
enum NotificationType {
  listingApproved,
  listingRejected,
  newMessage,
  newInterest,
  paymentSuccess,
  subscriptionActivated,
  systemAnnouncement,
  featuredListingExpired,
}

/// Notification Model
class Notification {
  final int id;
  final int userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? actionUrl;
  final int? relatedId;
  final String? relatedType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.actionUrl,
    this.relatedId,
    this.relatedType,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  Notification copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? actionUrl,
    int? relatedId,
    String? relatedType,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      actionUrl: actionUrl ?? this.actionUrl,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      body: json['message'] ?? json['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'systemAnnouncement'),
        orElse: () => NotificationType.systemAnnouncement,
      ),
      actionUrl: json['action_url'],
      relatedId: json['related_id'],
      relatedType: json['related_type'],
      isRead: json['read_at'] != null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}';
  }

  IconData get icon {
    switch (type) {
      case NotificationType.listingApproved:
        return Icons.check_circle_outline;
      case NotificationType.listingRejected:
        return Icons.cancel_outlined;
      case NotificationType.newMessage:
        return Icons.message_outlined;
      case NotificationType.newInterest:
        return Icons.interests_outlined;
      case NotificationType.paymentSuccess:
        return Icons.payment_outlined;
      case NotificationType.subscriptionActivated:
        return Icons.star_outline;
      case NotificationType.systemAnnouncement:
        return Icons.campaign_outlined;
      case NotificationType.featuredListingExpired:
        return Icons.timer_outlined;
    }
  }
}
