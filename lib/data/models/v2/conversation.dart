import '../../../core/utils/type_utils.dart';
import 'listing_summary.dart';

/// Safe public projection of the other side of a chat thread.
class ConversationParticipant {
  final int id;
  final String? firstName;
  final String? lastName;
  final String name;
  final String initials;
  final String? avatarUrl;

  const ConversationParticipant({
    required this.id,
    this.firstName,
    this.lastName,
    this.name = '',
    this.initials = '',
    this.avatarUrl,
  });

  String get displayName {
    if (name.trim().isNotEmpty) return name;
    final parts = [firstName, lastName]
        .map((part) => part?.trim())
        .whereType<String>()
        .where((part) => part.isNotEmpty);
    return parts.join(' ');
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  factory ConversationParticipant.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ConversationParticipant(
      id: TypeUtils.safeInt(map['id']) ?? 0,
      firstName: _text(map['first_name']),
      lastName: _text(map['last_name']),
      name: map['name']?.toString() ?? '',
      initials: map['initials']?.toString() ?? '',
      avatarUrl: _text(map['avatar_url']),
    );
  }
}

/// One chat message from `/v2/conversations/{id}/messages`.
///
/// `isRead` is the recipient's read receipt; on the viewer's own message it
/// reports whether the other participant has opened it.
class ChatMessage {
  final int id;
  final int conversationId;
  final String body;
  final int senderId;
  final ConversationParticipant? sender;
  final bool isMine;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.senderId,
    this.sender,
    this.isMine = false,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  bool get hasSender => sender != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawSender = json['sender'];

    return ChatMessage(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      conversationId: TypeUtils.safeInt(json['conversation_id']) ?? 0,
      body: json['body']?.toString() ?? '',
      senderId: TypeUtils.safeInt(json['sender_id']) ?? 0,
      sender: rawSender is Map
          ? ConversationParticipant.fromJson(
              Map<String, dynamic>.from(rawSender))
          : null,
      isMine: TypeUtils.safeBool(json['is_mine']),
      isRead: TypeUtils.safeBool(json['is_read']),
      readAt: _date(json['read_at']),
      createdAt: _date(json['created_at']),
    );
  }
}

/// Chat thread from `/v2/conversations`.
///
/// Named [ChatConversation] so it can coexist with the legacy `Conversation`
/// model while the messaging screens migrate.
class ChatConversation {
  final int id;
  final String type;
  final ListingSummary? listing;
  final ConversationParticipant? otherParticipant;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatConversation({
    required this.id,
    required this.type,
    this.listing,
    this.otherParticipant,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isDirect => type == 'direct';

  bool get isAboutListing => type == 'listing' && listing != null;

  bool get hasUnread => unreadCount > 0;

  bool get hasListing => listing != null;

  String get title {
    final participant = otherParticipant?.displayName;
    if (participant != null && participant.isNotEmpty) return participant;

    return listing?.title ?? '';
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final rawListing = json['listing'];
    final rawParticipant = json['other_participant'];
    final rawLastMessage = json['last_message'];

    return ChatConversation(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? 'direct',
      listing: rawListing is Map
          ? ListingSummary.fromJson(Map<String, dynamic>.from(rawListing))
          : null,
      otherParticipant: rawParticipant is Map
          ? ConversationParticipant.fromJson(
              Map<String, dynamic>.from(rawParticipant))
          : null,
      lastMessage: rawLastMessage is Map
          ? ChatMessage.fromJson(Map<String, dynamic>.from(rawLastMessage))
          : null,
      unreadCount: TypeUtils.safeInt(json['unread_count']) ?? 0,
      lastMessageAt: _date(json['last_message_at']),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }
}

/// Result of marking a thread read.
class ConversationReadReceipt {
  final int conversationId;
  final int markedRead;
  final int unreadCount;
  final DateTime? readAt;

  const ConversationReadReceipt({
    required this.conversationId,
    this.markedRead = 0,
    this.unreadCount = 0,
    this.readAt,
  });

  factory ConversationReadReceipt.fromJson(Map<String, dynamic> json) {
    return ConversationReadReceipt(
      conversationId: TypeUtils.safeInt(json['conversation_id']) ?? 0,
      markedRead: TypeUtils.safeInt(json['marked_read']) ?? 0,
      unreadCount: TypeUtils.safeInt(json['unread_count']) ?? 0,
      readAt: _date(json['read_at']),
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
