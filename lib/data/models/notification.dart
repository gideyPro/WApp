import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Notification types
enum NotificationType {
  listingApproved,
  listingRejected,
  newInterest,
  paymentSuccess,
  paymentFailed,
  subscriptionActivated,
  systemAnnouncement,
  featuredListingExpired,
  suggestion,
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
  final Map<String, dynamic>? data;
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
    this.data,
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
    Map<String, dynamic>? data,
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
      data: data ?? this.data,
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
      type: _parseType(json['type']),
      actionUrl: json['action_url'],
      relatedId: json['related_id'],
      relatedType: json['related_type'],
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      isRead: json['read_at'] != null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'listing_update':
      case 'listing_approved':
        return NotificationType.listingApproved;
      case 'listing_rejected':
      case 'listing_rejection':
        return NotificationType.listingRejected;
      case 'inquiry':
        return NotificationType.newInterest;
      case 'payment_success':
        return NotificationType.paymentSuccess;
      case 'payment_failed':
        return NotificationType.paymentFailed;
      case 'suggestion':
        return NotificationType.suggestion;
      default:
        return NotificationType.systemAnnouncement;
    }
  }

  String getDisplayTime(AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return l10n.notificationJustNow;
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
      case NotificationType.newInterest:
        return Icons.interests_outlined;
      case NotificationType.paymentSuccess:
        return Icons.payment_outlined;
      case NotificationType.paymentFailed:
        return Icons.error_outline;
      case NotificationType.subscriptionActivated:
        return Icons.star_outline;
      case NotificationType.systemAnnouncement:
        return Icons.campaign_outlined;
      case NotificationType.featuredListingExpired:
        return Icons.timer_outlined;
      case NotificationType.suggestion:
        return Icons.auto_awesome;
    }
  }
}
