import '../../l10n/app_localizations.dart';

/// Conversation Model
class Conversation {
  final int id;
  final int senderId;
  final int receiverId;
  final int? listingId;
  final String? type;
  final String? subject;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int? unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Additional fields for WhatsApp-like UI
  final int? otherParticipantId;
  final String? otherParticipantFirstName;
  final String? otherParticipantLastName;
  final String? listingTitle;
  final String? listingImageUrl;
  final String? listingDescription;
  final int? listingOwnerId;
  final bool isAssetChat;

  // Raw sender/receiver data for dynamic name computation
  final Map<String, dynamic>? _senderData;
  final Map<String, dynamic>? _receiverData;
  final int? lastMessageSenderId;

  Conversation({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.listingId,
    this.type,
    this.subject,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount,
    required this.createdAt,
    this.updatedAt,
    this.otherParticipantId,
    this.otherParticipantFirstName,
    this.otherParticipantLastName,
    this.listingTitle,
    this.listingImageUrl,
    this.listingDescription,
    this.listingOwnerId,
    this.isAssetChat = false,
    Map<String, dynamic>? senderData,
    Map<String, dynamic>? receiverData,
    this.lastMessageSenderId,
  })  : _senderData = senderData,
        _receiverData = receiverData;

  factory Conversation.fromJson(Map<String, dynamic> json,
      {int? currentUserId}) {
    // Extract last message from nested relationships
    String? lastMsg;
    int? lastMsgSenderId;
    if (json['latest_message'] is Map) {
      final lm = json['latest_message'] as Map<String, dynamic>;
      lastMsg = lm['body'] ?? lm['message'];
      lastMsgSenderId = _safeInt(lm['sender_id']);
    } else if (json['last_message'] != null) {
      lastMsg = json['last_message'];
    }

    // Get listing info
    String? listingTitle;
    String? listingImageUrl;
    String? listingDescription;
    int? listingOwnerId;
    bool isAssetChat = false;
    if (json['listing'] is Map) {
      final listing = json['listing'] as Map<String, dynamic>;
      listingTitle = listing['title'];
      listingDescription = listing['description'];
      isAssetChat = json['listing_id'] != null;
      // Extract first image if available
      if (listing['property'] is Map) {
        final property = listing['property'] as Map<String, dynamic>;
        listingOwnerId = _safeInt(property['owner_id']);
        if (property['images'] is List &&
            (property['images'] as List).isNotEmpty) {
          final images = property['images'] as List;
          listingImageUrl = images.first['image_path'];
        }
      }
    }

    // Store raw sender/receiver data for dynamic name computation
    final senderData = json['sender'] is Map
        ? Map<String, dynamic>.from(json['sender'])
        : null;
    final receiverData = json['receiver'] is Map
        ? Map<String, dynamic>.from(json['receiver'])
        : null;

    // Determine other participant at parse time (if currentUserId is available)
    String? otherFirstName, otherLastName;
    int? otherId;
    if (currentUserId != null) {
      final sid = _safeInt(senderData?['id']);
      final rid = _safeInt(receiverData?['id']);

      if (sid != null && sid != currentUserId && senderData != null) {
        otherFirstName = senderData['first_name'];
        otherLastName = senderData['last_name'];
        otherId = sid;
      } else if (rid != null && rid != currentUserId && receiverData != null) {
        otherFirstName = receiverData['first_name'];
        otherLastName = receiverData['last_name'];
        otherId = rid;
      }
    }

    // Handle both unread_count and total_unread_count field names
    int? unreadVal =
        _safeInt(json['unread_count']) ?? _safeInt(json['total_unread_count']);

    return Conversation(
      id: _safeInt(json['id']) ?? 0,
      senderId: _safeInt(json['sender_id']) ?? 0,
      receiverId: _safeInt(json['receiver_id']) ?? 0,
      listingId: _safeInt(json['listing_id']),
      type: json['type'],
      subject: listingTitle ?? json['subject'],
      lastMessage: lastMsg,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: unreadVal,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      otherParticipantId: otherId,
      otherParticipantFirstName: otherFirstName,
      otherParticipantLastName: otherLastName,
      listingTitle: listingTitle,
      listingImageUrl: listingImageUrl,
      listingDescription: listingDescription,
      listingOwnerId: listingOwnerId,
      isAssetChat: isAssetChat,
      senderData: senderData,
      receiverData: receiverData,
      lastMessageSenderId: lastMsgSenderId,
    );
  }


  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  String getDisplayTitle(int currentUserId) {
    // First try pre-computed name (if available from parse time)
    if (otherParticipantFirstName != null) {
      final full = [otherParticipantFirstName, otherParticipantLastName]
          .where((e) => e != null && e.isNotEmpty)
          .join(' ');
      if (full.isNotEmpty) return full;
    }

    // Compute dynamically from raw data
    final otherData = _getOtherParticipantData(currentUserId);
    if (otherData != null) {
      final first = otherData['first_name'] ?? '';
      final last = otherData['last_name'] ?? '';
      final full = [first, last].where((e) => e.isNotEmpty).join(' ');
      if (full.isNotEmpty) return full;
    }

    if (subject != null && subject!.isNotEmpty) return subject!;
    if (listingTitle != null && listingTitle!.isNotEmpty) return listingTitle!;
    return 'Conversation #$id';
  }

  String getInitials(int currentUserId) {
    // First try pre-computed name
    if (otherParticipantFirstName != null &&
        otherParticipantFirstName!.isNotEmpty) {
      final first = otherParticipantFirstName!;
      final last = otherParticipantLastName ?? '';
      if (last.isNotEmpty) {
        return '${first[0]}${last[0]}'.toUpperCase();
      }
      return first.substring(0, first.length > 1 ? 2 : 1).toUpperCase();
    }

    // Compute dynamically from raw data
    final otherData = _getOtherParticipantData(currentUserId);
    if (otherData != null) {
      final first = otherData['first_name'] ?? '';
      final last = otherData['last_name'] ?? '';
      if (first.isNotEmpty && last.isNotEmpty) {
        return '${first[0]}${last[0]}'.toUpperCase();
      }
      if (first.isNotEmpty) {
        return first.substring(0, first.length > 1 ? 2 : 1).toUpperCase();
      }
    }

    return '??';
  }

  Map<String, dynamic>? _getOtherParticipantData(int currentUserId) {
    if (currentUserId <= 0) return null;
    final sid = _safeInt(_senderData?['id']);
    final rid = _safeInt(_receiverData?['id']);

    if (sid != null && sid != currentUserId) return _senderData;
    if (rid != null && rid != currentUserId) return _receiverData;
    return null;
  }

  bool isLastMessageFromMe(int currentUserId) {
    if (lastMessageSenderId != null) {
      return lastMessageSenderId == currentUserId;
    }
    // Fallback: check the conversation sender
    return senderId == currentUserId;
  }

  int? getOtherParticipantId(int currentUserId) {
    if (senderId == currentUserId) return receiverId;
    if (receiverId == currentUserId) return senderId;
    return null;
  }

  String get displayName {
    if (listingTitle != null && listingTitle!.isNotEmpty) {
      return listingTitle!;
    }
    final first = otherParticipantFirstName ?? '';
    final last = otherParticipantLastName ?? '';
    final full = [first, last].where((e) => e.isNotEmpty).join(' ');
    if (full.isNotEmpty) return full;
    return 'Conversation #$id';
  }

  String get displayInitials {
    final first = otherParticipantFirstName ?? '';
    final last = otherParticipantLastName ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.substring(0, first.length > 1 ? 2 : 1).toUpperCase();
    }
    return '??';
  }

  String? get otherParticipantAvatar {
    return null;
  }

  String get contextDisplayTitle {
    if (listingDescription != null && listingDescription!.isNotEmpty) {
      return listingDescription!;
    }
    if (listingTitle != null && listingTitle!.isNotEmpty) {
      return listingTitle!;
    }
    return 'Direct Chat';
  }

  bool matchesParticipant(int userId) {
    return senderId == userId || receiverId == userId;
  }
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final bool isRead;
  final DateTime? readAt;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;

  // Sender info for WhatsApp-like avatars
  final String? senderFirstName;
  final String? senderLastName;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.isRead = false,
    this.readAt,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    this.senderFirstName,
    this.senderLastName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String? firstName, lastName;
    if (json['sender'] is Map) {
      firstName = json['sender']['first_name'];
      lastName = json['sender']['last_name'];
    }

    return Message(
      id: _safeInt(json['id']) ?? 0,
      conversationId: _safeInt(json['conversation_id']) ?? 0,
      senderId: _safeInt(json['sender_id']) ?? 0,
      body: json['body'] ?? json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      senderFirstName: firstName,
      senderLastName: lastName,
    );
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  String getDisplayTime(AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return l10n.notificationJustNow;
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get senderInitials {
    final first = senderFirstName ?? '';
    final last = senderLastName ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.substring(0, first.length > 1 ? 2 : 1).toUpperCase();
    }
    return '??';
  }
}
