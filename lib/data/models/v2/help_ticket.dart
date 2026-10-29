import '../../../core/utils/type_utils.dart';
import 'help_content.dart';

/// Lifecycle state of a support ticket.
enum HelpTicketStatus {
  open('open'),
  inProgress('in_progress'),
  waitingCustomer('waiting_customer'),
  resolved('resolved'),
  closed('closed'),
  unknown('unknown');

  final String wireValue;

  const HelpTicketStatus(this.wireValue);

  static HelpTicketStatus parse(dynamic value) {
    switch (value?.toString()) {
      case 'open':
        return HelpTicketStatus.open;
      case 'in_progress':
        return HelpTicketStatus.inProgress;
      case 'waiting_customer':
        return HelpTicketStatus.waitingCustomer;
      case 'resolved':
        return HelpTicketStatus.resolved;
      case 'closed':
        return HelpTicketStatus.closed;
      default:
        return HelpTicketStatus.unknown;
    }
  }

  bool get isResolved => this == HelpTicketStatus.resolved;

  bool get isClosed => this == HelpTicketStatus.closed;

  /// Rating is allowed only once support resolved or closed the ticket.
  bool get canRate => isResolved || isClosed;
}

/// Ticket priority chosen when the ticket is opened.
enum HelpTicketPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent'),
  unknown('unknown');

  final String wireValue;

  const HelpTicketPriority(this.wireValue);

  static HelpTicketPriority parse(dynamic value) {
    switch (value?.toString()) {
      case 'low':
        return HelpTicketPriority.low;
      case 'medium':
        return HelpTicketPriority.medium;
      case 'high':
        return HelpTicketPriority.high;
      case 'urgent':
        return HelpTicketPriority.urgent;
      default:
        return HelpTicketPriority.unknown;
    }
  }
}

/// One attachment on a ticket message.
class HelpTicketAttachment {
  final String url;

  const HelpTicketAttachment({required this.url});

  factory HelpTicketAttachment.fromJson(Map<String, dynamic> json) {
    return HelpTicketAttachment(url: json['url']?.toString() ?? '');
  }
}

/// A message in a support ticket thread.
class HelpTicketMessage {
  final int id;
  final String body;
  final bool isStaff;
  final List<HelpTicketAttachment> attachments;
  final bool isRead;
  final DateTime? createdAt;

  const HelpTicketMessage({
    required this.id,
    required this.body,
    this.isStaff = false,
    this.attachments = const [],
    this.isRead = false,
    this.createdAt,
  });

  bool get hasAttachments => attachments.isNotEmpty;

  factory HelpTicketMessage.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];

    return HelpTicketMessage(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      body: json['body']?.toString() ?? '',
      isStaff: TypeUtils.safeBool(json['is_staff']),
      attachments: rawAttachments is List
          ? rawAttachments
              .whereType<Map>()
              .map((item) => HelpTicketAttachment.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
      isRead: TypeUtils.safeBool(json['is_read']),
      createdAt: _date(json['created_at']),
    );
  }
}

/// Ticket list projection.
class HelpTicketSummary {
  final String ticketNumber;
  final String subject;
  final HelpTicketStatus status;
  final HelpTicketPriority priority;
  final HelpCategory? category;
  final int? rating;
  final int unreadMessages;
  final HelpTicketMessage? lastMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  const HelpTicketSummary({
    required this.ticketNumber,
    required this.subject,
    this.status = HelpTicketStatus.open,
    this.priority = HelpTicketPriority.medium,
    this.category,
    this.rating,
    this.unreadMessages = 0,
    this.lastMessage,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
  });

  bool get hasUnreadMessages => unreadMessages > 0;

  bool get isRated => rating != null;

  factory HelpTicketSummary.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final rawLastMessage = json['last_message'];
    final rawRating = TypeUtils.safeInt(json['rating']);

    return HelpTicketSummary(
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      status: HelpTicketStatus.parse(json['status']),
      priority: HelpTicketPriority.parse(json['priority']),
      category: rawCategory is Map
          ? HelpCategory.fromJson(Map<String, dynamic>.from(rawCategory))
          : null,
      rating: rawRating,
      unreadMessages: TypeUtils.safeInt(json['unread_messages']) ?? 0,
      lastMessage: rawLastMessage is Map
          ? HelpTicketMessage.fromJson(
              Map<String, dynamic>.from(rawLastMessage))
          : null,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      resolvedAt: _date(json['resolved_at']),
      closedAt: _date(json['closed_at']),
    );
  }
}

/// Full ticket payload, including the description and loaded thread.
class HelpTicket extends HelpTicketSummary {
  final String message;
  final String? ratingComment;
  final List<HelpTicketMessage> messages;

  const HelpTicket({
    required super.ticketNumber,
    required super.subject,
    super.status,
    super.priority,
    super.category,
    super.rating,
    super.unreadMessages,
    super.lastMessage,
    super.createdAt,
    super.updatedAt,
    super.resolvedAt,
    super.closedAt,
    this.message = '',
    this.ratingComment,
    this.messages = const [],
  });

  factory HelpTicket.fromJson(Map<String, dynamic> json) {
    final summary = HelpTicketSummary.fromJson(json);
    final rawMessages = json['messages'];

    return HelpTicket(
      ticketNumber: summary.ticketNumber,
      subject: summary.subject,
      status: summary.status,
      priority: summary.priority,
      category: summary.category,
      rating: summary.rating,
      unreadMessages: summary.unreadMessages,
      lastMessage: summary.lastMessage,
      createdAt: summary.createdAt,
      updatedAt: summary.updatedAt,
      resolvedAt: summary.resolvedAt,
      closedAt: summary.closedAt,
      message: json['message']?.toString() ?? '',
      ratingComment: _text(json['rating_comment']),
      messages: rawMessages is List
          ? rawMessages
              .whereType<Map>()
              .map((item) =>
                  HelpTicketMessage.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }
}

/// Result of rating a resolved ticket.
class HelpTicketRating {
  final String ticketNumber;
  final int rating;
  final String? comment;

  const HelpTicketRating({
    required this.ticketNumber,
    required this.rating,
    this.comment,
  });

  factory HelpTicketRating.fromJson(Map<String, dynamic> json) {
    return HelpTicketRating(
      ticketNumber: json['ticket_number']?.toString() ?? '',
      rating: TypeUtils.safeInt(json['rating']) ?? 0,
      comment: _text(json['comment']),
    );
  }
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
