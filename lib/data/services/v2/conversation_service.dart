import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../../core/network/v2/paginated.dart';
import '../../models/v2/conversation.dart';

/// Chat threads and messages for the authenticated participant.
class ConversationServiceV2 {
  final ApiV2Client _client;

  ConversationServiceV2({ApiV2Client? client})
      : _client = client ?? ApiV2Client();

  Future<Paginated<ChatConversation>> fetch({
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    return _client.getCollection(
      ApiV2Constants.conversations,
      parse: ChatConversation.fromJson,
      query: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<ChatConversation> fetchConversation(int id) async {
    final data = await _client.getItem(ApiV2Constants.conversation(id));
    return ChatConversation.fromJson(data);
  }

  /// Start (or reopen) a thread. Exactly one target must be supplied.
  Future<ChatConversation> start({
    int? listingId,
    int? userId,
  }) async {
    if ((listingId == null) == (userId == null)) {
      throw ArgumentError(
        'Pass exactly one of listingId or userId',
      );
    }

    final data = await _client.sendItem(
      ApiV2Constants.conversations,
      method: 'POST',
      body: {
        if (listingId != null) 'listing_id': listingId,
        if (userId != null) 'user_id': userId,
      },
    );

    return ChatConversation.fromJson(data);
  }

  /// Newest message first; follow [Paginated.nextCursor] for older pages.
  Future<Paginated<ChatMessage>> fetchMessages(
    int conversationId, {
    String? cursor,
    int limit = ApiV2Constants.defaultLimit,
  }) {
    return _client.getCollection(
      ApiV2Constants.conversationMessages(conversationId),
      parse: ChatMessage.fromJson,
      query: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': _clampLimit(limit),
      },
    );
  }

  Future<ChatMessage> sendMessage(int conversationId, String body) async {
    final text = body.trim();

    if (text.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Message body cannot be empty');
    }

    final data = await _client.sendItem(
      ApiV2Constants.conversationMessages(conversationId),
      method: 'POST',
      body: {'body': text},
    );

    return ChatMessage.fromJson(data);
  }

  /// Mark received messages read. Safe to repeat.
  Future<ConversationReadReceipt> markRead(int conversationId) async {
    final data = await _client.sendItem(
      ApiV2Constants.conversationRead(conversationId),
      method: 'POST',
    );

    return ConversationReadReceipt.fromJson(data);
  }

  Future<void> deleteConversation(int conversationId) async {
    await _client.send(
      ApiV2Constants.conversation(conversationId),
      method: 'DELETE',
    );
  }

  static int _clampLimit(int limit) {
    if (limit <= 0) return ApiV2Constants.defaultLimit;
    return limit > ApiV2Constants.maxLimit ? ApiV2Constants.maxLimit : limit;
  }
}
