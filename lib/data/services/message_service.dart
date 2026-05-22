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
        final raw = response.data;
        dev.log('Response: $raw', name: 'Messages');

        final dataList = _extractList(raw);
        
        // Pagination metadata can be at root or under 'data'
        final paginationSource = (raw is Map && raw['data'] is Map) ? raw['data'] : (raw is Map ? raw : {});
        int currentPage = _safeInt(paginationSource['current_page']) ?? page;
        int totalPages = _safeInt(paginationSource['last_page']) ?? 1;
        int total = _safeInt(paginationSource['total']) ?? 0;

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
        message: _extractMessage(response.data, 'Failed to fetch conversations'),
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

  /// Robustly extract a list from various API response structures
  List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'];
      if (data is List) return data;
      if (data is Map) {
        final nestedData = data['data'] ?? data['conversations'] ?? data['messages'] ?? data['items'];
        if (nestedData is List) return nestedData;
      }
      final directList = raw['conversations'] ?? raw['messages'] ?? raw['items'];
      if (directList is List) return directList;
    }
    return [];
  }

  /// Robustly extract a message from various API response structures
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map) {
      return raw['message']?.toString() ?? 
             raw['error']?.toString() ?? 
             raw['errors']?.toString() ?? 
             defaultMessage;
    }
    if (raw is String) return raw;
    return defaultMessage;
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
          } else {
            innerData = Map<String, dynamic>.from(raw);
          }
        }

        // Extract messages from paginator
        final msgList = _extractList(innerData['messages'] ?? innerData);

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
        final relatedRaw = innerData['related_conversations'];
        final relatedList = relatedRaw is List ? relatedRaw : [];
        final relatedConversations = relatedList
              .whereType<Map>()
              .map((json) => msg.Conversation.fromJson(
                  json as Map<String, dynamic>,
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
        message: _extractMessage(response.data, 'Failed to fetch messages'),
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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final message = data != null ? msg.Message.fromJson(data) : null;

        return MessageResponse(
          success: true,
          message: _extractMessage(response.data, 'Message sent'),
          messageData: message,
        );
      }

      return MessageResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to send message'),
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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final conversation = data != null ? msg.Conversation.fromJson(data) : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: _extractMessage(response.data, 'Conversation started'),
        );
      }

      return ConversationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to start conversation'),
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
        final raw = response.data;
        Map<String, dynamic>? data;
        if (raw is Map) {
          data = raw['data'] is Map ? Map<String, dynamic>.from(raw['data']) : Map<String, dynamic>.from(raw);
        }

        final conversation = data != null ? msg.Conversation.fromJson(data) : null;

        return ConversationResponse(
          success: true,
          conversation: conversation,
          message: _extractMessage(response.data, 'Conversation started'),
        );
      }

      return ConversationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to start conversation'),
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
          message: _extractMessage(response.data, 'Conversation deleted'),
        );
      }

      return ConversationResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to delete conversation'),
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
        final msgList = _extractList(response.data);

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
        message: _extractMessage(response.data, 'Failed to fetch messages'),
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

