import 'dart:developer' as dev;
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/message.dart' as msg;

/// Service for messaging and conversations
class MessageService {
  final ApiClient _apiClient;

  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all conversations
  Future<ConversationResponse> getConversations({
    int page = 1,
    int perPage = 15,
    int? currentUserId,
  }) async {
    try {
      dev.log('=== FETCHING CONVERSATIONS (page=$page, perPage=$perPage) ===', name: 'Messages');

      final response = await _apiClient.dio.get(
        ApiConstants.messages,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        dev.log('Response: $raw', name: 'Messages');

        final dataList = ApiEnvelope.extractList(
          raw,
          itemKeys: const ['conversations', 'messages', 'items'],
        );

        final pagination = ApiEnvelope.extractPagination(raw, fallbackPage: page);

        final conversations = dataList
            .whereType<Map>()
            .map((json) => msg.Conversation.fromJson(json as Map<String, dynamic>, currentUserId: currentUserId))
            .toList();

        return ConversationResponse(
          success: true,
          conversations: conversations,
          currentPage: pagination.currentPage,
          totalPages: pagination.totalPages,
          total: pagination.total,
        );
      }

      return ConversationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch conversations'),
      );
    } catch (e, stackTrace) {
      dev.log('Error fetching conversations: $e\n$stackTrace', name: 'Messages');
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get conversation messages
  Future<MessageResponse> getConversationMessages({
    required int conversationId,
    int page = 1,
    int? currentUserId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.conversation}/$conversationId',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final raw = response.data;

        // Backend returns: { success: true, data: { conversation, messages: { paginator }, other_user, related_conversations } }
        final innerData = ApiEnvelope.extractData(raw);

        // Extract messages from paginator
        final msgList = ApiEnvelope.extractList(
          innerData['messages'] ?? innerData,
          itemKeys: const ['messages', 'items'],
        );

        final messages = msgList
            .whereType<Map>()
            .map((json) => msg.Message.fromJson(json as Map<String, dynamic>))
            .toList();

        msg.Conversation? conversation;
        final convData = innerData['conversation'];
        if (convData is Map) {
          conversation = msg.Conversation.fromJson(
              Map<String, dynamic>.from(convData),
              currentUserId: currentUserId);
        }

        // Extract related conversations
        final relatedRaw = innerData['related_conversations'];
        final relatedList = relatedRaw is List ? relatedRaw : [];
        final relatedConversations = relatedList
              .whereType<Map>()
              .map((json) => msg.Conversation.fromJson(
                  Map<String, dynamic>.from(json),
                  currentUserId: currentUserId))
              .toList();

        return MessageResponse(
          success: true,
          messages: messages,
          conversation: conversation,
          relatedConversations: relatedConversations,
        );
      }

      return MessageResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch messages'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }


  /// Send message in conversation
  Future<MessageResponse> sendMessage({
    required int conversationId,
    required String body,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.sendMessage}/$conversationId',
        data: {
          'body': body,
          if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ApiEnvelope.extractData(response.data);

        final message = data.isNotEmpty ? msg.Message.fromJson(data) : null;

        return MessageResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Message sent'),
          messageData: message,
        );
      }

      return MessageResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to send message'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Start conversation from listing
  Future<ConversationResponse> startConversationFromListing({
    required int listingId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.startMessageFromListing}/$listingId/message',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ApiEnvelope.extractData(response.data);

        final conversation =
            data.isNotEmpty ? msg.Conversation.fromJson(data) : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: ApiEnvelope.extractMessage(response.data, 'Conversation started'),
        );
      }

      return ConversationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to start conversation'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Start direct conversation with user
  Future<ConversationResponse> startDirectConversation({
    required int userId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.startDirectMessage}/$userId/message',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ApiEnvelope.extractData(response.data);

        final conversation =
            data.isNotEmpty ? msg.Conversation.fromJson(data) : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: ApiEnvelope.extractMessage(response.data, 'Conversation started'),
        );
      }

      return ConversationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to start conversation'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete conversation
  Future<ConversationResponse> deleteConversation(int conversationId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.deleteConversation}/$conversationId',
      );

      if (response.statusCode == 200) {
        return ConversationResponse(
          success: true,
          message: ApiEnvelope.extractMessage(response.data, 'Conversation deleted'),
        );
      }

      return ConversationResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to delete conversation'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Fetch new messages (for polling)
  Future<MessageResponse> fetchNewMessages({
    required int conversationId,
    int? lastMessageId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (lastMessageId != null) {
        queryParams['last_message_id'] = lastMessageId;
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.fetchMessages}/$conversationId/fetch',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final msgList = ApiEnvelope.extractList(
          response.data,
          itemKeys: const ['messages', 'items'],
        );

        final messages = msgList
            .whereType<Map>()
            .map((json) => msg.Message.fromJson(json as Map<String, dynamic>))
            .toList();

        return MessageResponse(
          success: true,
          messages: messages,
        );
      }

      return MessageResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch messages'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for conversation operations
class ConversationResponse {
  final bool success;
  final String message;
  final List<msg.Conversation> conversations;
  final msg.Conversation? conversation;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const ConversationResponse({
    required this.success,
    this.message = '',
    this.conversations = const [],
    this.conversation,
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

/// Response wrapper for message operations
class MessageResponse {
  final bool success;
  final String message;
  final List<msg.Message> messages;
  final msg.Message? messageData;
  final msg.Conversation? conversation;
  final List<msg.Conversation> relatedConversations;

  const MessageResponse({
    required this.success,
    this.message = '',
    this.messages = const [],
    this.messageData,
    this.conversation,
    this.relatedConversations = const [],
  });
}

