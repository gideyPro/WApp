import 'dart:developer' as dev;
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
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
        final responseData = response.data;
        dev.log('Response: $responseData', name: 'Messages');

        List<dynamic> dataList = [];
        int currentPage = page;
        int totalPages = 1;
        int total = 0;

        if (responseData is Map && responseData['success'] == true) {
          final dataField = responseData['data'];
          if (dataField is Map) {
            final dataListRaw = dataField['data'];
            if (dataListRaw is List) dataList = dataListRaw;
            currentPage = _safeInt(dataField['current_page']) ?? page;
            totalPages = _safeInt(dataField['last_page']) ?? 1;
            total = _safeInt(dataField['total']) ?? 0;
          } else if (dataField is List) {
            dataList = dataField;
          }
        }

        final conversations = dataList
            .whereType<Map>()
            .map((json) => msg.Conversation.fromJson(json as Map<String, dynamic>, currentUserId: currentUserId))
            .toList();

        return ConversationResponse(
          success: true,
          conversations: conversations,
          currentPage: currentPage,
          totalPages: totalPages,
          total: total,
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch conversations',
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

  /// Safely convert dynamic value to int
  int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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
        Map<String, dynamic> innerData = {};
        if (raw is Map) {
          final dataField = raw['data'];
          if (dataField is Map) {
            innerData = Map<String, dynamic>.from(dataField);
          }
        }

        // Extract messages from paginator
        List<dynamic> msgList = [];
        final messagesRaw = innerData['messages'];
        if (messagesRaw is Map) {
          // Laravel paginator: { data: [...], current_page, ... }
          final listRaw = messagesRaw['data'] ??
              messagesRaw['listings'] ??
              messagesRaw['items'];
          if (listRaw is List) msgList = listRaw;
        } else if (messagesRaw is List) {
          msgList = messagesRaw;
        }

        final messages = msgList
            .whereType<Map>()
            .map((json) => msg.Message.fromJson(json as Map<String, dynamic>))
            .toList();

        msg.Conversation? conversation;
        if (innerData['conversation'] is Map) {
          conversation = msg.Conversation.fromJson(
              innerData['conversation'] as Map<String, dynamic>,
              currentUserId: currentUserId);
        }

        // Extract related conversations
        List<msg.Conversation> relatedConversations = [];
        final relatedRaw = innerData['related_conversations'];
        if (relatedRaw is List) {
          relatedConversations = relatedRaw
              .whereType<Map>()
              .map((json) => msg.Conversation.fromJson(
                  json as Map<String, dynamic>,
                  currentUserId: currentUserId))
              .toList();
        }

        return MessageResponse(
          success: true,
          messages: messages,
          conversation: conversation,
          relatedConversations: relatedConversations,
        );
      }

      return MessageResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to fetch messages',
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
        final message = response.data['data'] != null
            ? msg.Message.fromJson(response.data['data'])
            : null;

        return MessageResponse(
          success: true,
          message: 'Message sent',
          messageData: message,
        );
      }

      return MessageResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to send message',
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
        final conversation = response.data['data'] != null
            ? msg.Conversation.fromJson(response.data['data'])
            : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: 'Conversation started',
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to start conversation',
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
        final conversation = response.data['data'] != null
            ? msg.Conversation.fromJson(response.data['data'])
            : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: 'Conversation started',
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to start conversation',
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
          message: response.data['message'] ?? 'Conversation deleted',
        );
      }

      return ConversationResponse(
        success: false,
        message: response.data['message'] ?? 'Failed to delete conversation',
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
    DateTime? after,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (after != null) {
        queryParams['last_message_id'] = after.toIso8601String();
      }

      final response = await _apiClient.dio.get(
        '${ApiConstants.fetchMessages}/$conversationId/fetch',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> msgList = [];

        // Backend returns { messages: [...] } directly
        if (raw is Map) {
          final messagesRaw = raw['messages'] ?? raw['data'];
          if (messagesRaw is List) msgList = messagesRaw;
        } else if (raw is List) {
          msgList = raw;
        }

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
        message: response.data['message'] ?? 'Failed to fetch messages',
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

