import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../models/message.dart' as msg;
import '../models/v2/v2_legacy_adapters.dart';
import 'v2/conversation_service.dart';

/// Service for messaging and conversations backed by V2 API.
class MessageService {
  final ConversationServiceV2 _v2;
  final Map<int, String> _cursors = {};

  MessageService({ApiClient? apiClient, ConversationServiceV2? v2Service})
      : _v2 = v2Service ?? ConversationServiceV2();

  Future<ConversationResponse> getConversations({
    int page = 1,
    int perPage = 15,
    int? currentUserId,
  }) async {
    try {
      if (page <= 1) {
        _cursors.clear();
      }
      final cursor = page > 1 ? _cursors[page] : null;
      final result = await _v2.fetch(cursor: cursor, limit: perPage);
      if (result.nextCursor != null) {
        _cursors[page + 1] = result.nextCursor!;
      }
      final conversations = result.items
          .map((c) => c.toLegacyConversation(currentUserId: currentUserId))
          .toList();

      return ConversationResponse(
        success: true,
        conversations: conversations,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: conversations.length,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<MessageResponse> getConversationMessages({
    required int conversationId,
    int page = 1,
    int perPage = 30,
    int? currentUserId,
  }) async {
    try {
      final result = await _v2.fetchMessages(
        conversationId,
        limit: perPage,
      );

      // Legacy screens expect chronological order (oldest to newest)
      final messages = result.items.reversed
          .map((m) => m.toLegacyMessage())
          .toList();

      return MessageResponse(
        success: true,
        messages: messages,
        currentPage: page,
        totalPages: result.hasMore ? page + 1 : page,
        total: messages.length,
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return MessageResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<SingleMessageResponse> sendMessage({
    required int conversationId,
    String? message,
    String? body,
    File? file,
  }) async {
    try {
      final text = body ?? message ?? '';
      final sent = await _v2.sendMessage(conversationId, text);
      return SingleMessageResponse(
        success: true,
        message: sent.toLegacyMessage(),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SingleMessageResponse(
        success: false,
        errorMessage: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<MessageResponse> fetchNewMessages({
    required int conversationId,
    required int lastMessageId,
  }) async {
    return getConversationMessages(conversationId: conversationId);
  }

  Future<SingleConversationResponse> startConversationFromListing({
    required int listingId,
    String? message,
  }) async {
    try {
      final conv = await _v2.start(listingId: listingId);
      if (message != null && message.trim().isNotEmpty) {
        await _v2.sendMessage(conv.id, message.trim());
      }
      return SingleConversationResponse(
        success: true,
        conversation: conv.toLegacyConversation(),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SingleConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<SingleConversationResponse> startDirectConversation({
    required int userId,
    String? message,
  }) async {
    try {
      final conv = await _v2.start(userId: userId);
      if (message != null && message.trim().isNotEmpty) {
        await _v2.sendMessage(conv.id, message.trim());
      }
      return SingleConversationResponse(
        success: true,
        conversation: conv.toLegacyConversation(),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return SingleConversationResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  Future<bool> markAsRead(int conversationId) async {
    try {
      await _v2.markRead(conversationId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteConversation(int conversationId) async {
    try {
      await _v2.deleteConversation(conversationId);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class ConversationResponse {
  final bool success;
  final String message;
  final List<msg.Conversation> conversations;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const ConversationResponse({
    required this.success,
    this.message = '',
    this.conversations = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

class MessageResponse {
  final bool success;
  final String message;
  final List<msg.Message> messages;
  final List<msg.Conversation> relatedConversations;
  final int? currentPage;
  final int? totalPages;
  final int? total;

  const MessageResponse({
    required this.success,
    this.message = '',
    this.messages = const [],
    this.relatedConversations = const [],
    this.currentPage,
    this.totalPages,
    this.total,
  });
}

class SingleMessageResponse {
  final bool success;
  final msg.Message? message;
  final String? errorMessage;

  const SingleMessageResponse({
    required this.success,
    this.message,
    this.errorMessage,
  });
}

class SingleConversationResponse {
  final bool success;
  final String message;
  final msg.Conversation? conversation;

  const SingleConversationResponse({
    required this.success,
    this.message = '',
    this.conversation,
  });
}
