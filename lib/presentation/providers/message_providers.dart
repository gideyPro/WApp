import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/message_service.dart';
import '../../data/models/message.dart' as msg;
import 'auth_provider.dart';
import 'notification_providers.dart';

/// Currently active conversation ID (for suppression of background notifications)
final activeConversationIdProvider = StateProvider<int?>((ref) => null);

/// Message Provider
final messageServiceProvider =
    Provider<MessageService>((ref) => MessageService());
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  return ConversationsNotifier(ref.watch(messageServiceProvider));
});

/// Unread messages count provider - sums unreadCount from all conversations

class UnreadCountNotifier extends StateNotifier<int> {
  final MessageService _messageService;
  final Ref _ref;
  Timer? _timer;

  UnreadCountNotifier(this._messageService, this._ref) : super(0) {
    refresh();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      final authState = _ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        refresh();
      }
    });
  }

  Future<void> refresh() async {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (state != 0) state = 0;
      return;
    }

    try {
      final response = await _messageService.getConversations(page: 1, perPage: 100);
      if (response.success) {
        int totalUnread = 0;
        for (var conv in response.conversations) {
          totalUnread += (conv.unreadCount ?? 0);
        }
        state = totalUnread;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final unreadMessagesCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier(ref.watch(messageServiceProvider), ref);
});

/// Lifecycle Provider - Triggers refresh when app comes to foreground
final appLifecycleProvider = StateNotifierProvider<LifecycleNotifier, AppLifecycleState>((ref) {
  return LifecycleNotifier(ref);
});

class LifecycleNotifier extends StateNotifier<AppLifecycleState> with WidgetsBindingObserver {
  final Ref _ref;
  LifecycleNotifier(this._ref) : super(AppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
    if (state == AppLifecycleState.resumed) {
      _triggerRefresh();
    }
  }

  void _triggerRefresh() {
    final authState = _ref.read(authStateProvider);
    if (authState.isAuthenticated) {
      _ref.read(unreadCountProvider.notifier).refresh();
      _ref.read(unreadMessagesCountProvider.notifier).refresh();
      _ref.read(conversationsProvider.notifier).loadConversations();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final MessageService _messageService;
  ConversationsNotifier(this._messageService)
      : super(const ConversationsState.initial());

  Future<void> loadConversations({int page = 1, int? currentUserId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _messageService.getConversations(
        page: page, currentUserId: currentUserId);
    if (response.success) {
      state = ConversationsState.loaded(
          conversations: response.conversations, total: response.total ?? 0);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  /// Refresh conversations list (e.g., after reading a message)
  Future<void> refreshConversations({int? currentUserId}) async {
    if (state.errorMessage != null) return;
    final response = await _messageService.getConversations(
        page: 1, currentUserId: currentUserId);
    if (response.success) {
      state = ConversationsState.loaded(
          conversations: response.conversations, total: response.total ?? 0);
    }
  }
}

class ConversationsState {
  final bool isLoading;
  final List<msg.Conversation> conversations;
  final int total;
  final String? errorMessage;
  const ConversationsState(
      {required this.isLoading,
      this.conversations = const [],
      this.total = 0,
      this.errorMessage});
  const ConversationsState.initial()
      : isLoading = true,
        conversations = const [],
        total = 0,
        errorMessage = null;
  const ConversationsState.loaded({required this.conversations, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  ConversationsState copyWith(
      {bool? isLoading,
      List<msg.Conversation>? conversations,
      int? total,
      String? errorMessage}) {
    return ConversationsState(
        isLoading: isLoading ?? this.isLoading,
        conversations: conversations ?? this.conversations,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}

/// Chat Messages Provider - manages messages within a single conversation
final chatMessagesProvider =
    StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, int>(
        (ref, conversationId) {
  final authState = ref.watch(authStateProvider);
  return ChatMessagesNotifier(ref.watch(messageServiceProvider), conversationId,
      authState.user?.id, ref);
});

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final MessageService _messageService;
  final int conversationId;
  final int? _currentUserId;
  final Ref _ref;
  Timer? _pollingTimer;

  ChatMessagesNotifier(
      this._messageService, this.conversationId, this._currentUserId, this._ref)
      : super(const ChatMessagesState.initial()) {
    // Set active conversation ID for FCM suppression
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(activeConversationIdProvider.notifier).state = conversationId;
    });
    loadMessages();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchNewMessages();
    });
  }

  Future<void> fetchNewMessages() async {
    // If already loading or no messages yet, skip polling fetch
    if (state.isLoading || state.messages.isEmpty) return;

    final lastMessage = state.messages.last;
    final response = await _messageService.fetchNewMessages(
      conversationId: conversationId,
      lastMessageId: lastMessage.id,
    );

    if (response.success && response.messages.isNotEmpty && mounted) {
      // Filter out messages that might already be in state (though backend should handle this)
      final existingIds = state.messages.map((m) => m.id).toSet();
      final trulyNew = response.messages.where((m) => !existingIds.contains(m.id)).toList();

      if (trulyNew.isNotEmpty) {
        state = state.copyWith(
          messages: [...state.messages, ...trulyNew],
        );
        // Refresh global unread count
        _ref.read(unreadMessagesCountProvider.notifier).refresh();
      }
    }
  }

  Future<void> loadMessages({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final response = await _messageService.getConversationMessages(
      conversationId: conversationId,
      page: page,
      currentUserId: _currentUserId,
    );

    if (response.success) {
      final newMessages = page == 1
          ? response.messages
          : [...state.messages, ...response.messages];

      state = ChatMessagesState.loaded(
        messages: newMessages,
        hasMore: response.messages.length >= 50,
        relatedConversations: response.relatedConversations,
      );

      // Instant Update: Messages are marked as read on server when loaded,
      // so we refresh the global badge count immediately.
      _ref.read(unreadMessagesCountProvider.notifier).refresh();
    } else {
      // Graceful error handling - don't show error if no data yet
      if (state.messages.isEmpty) {
        state = const ChatMessagesState.loaded(messages: [], hasMore: false);
      }
    }
  }

  Future<bool> sendMessage(String body) async {
    final response = await _messageService.sendMessage(
      conversationId: conversationId,
      body: body,
    );
    if (response.success) {
      await loadMessages();
    }
    return response.success;
  }

  void pausePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void resumePolling() {
    _pollingTimer?.cancel();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    // Clear active conversation ID when user leaves chat
    Future.microtask(() {
      if (_ref.read(activeConversationIdProvider) == conversationId) {
        _ref.read(activeConversationIdProvider.notifier).state = null;
      }
    });
    super.dispose();
  }
}

class ChatMessagesState {
  final bool isLoading;
  final List<msg.Message> messages;
  final List<msg.Conversation> relatedConversations;
  final bool hasMore;
  final String? errorMessage;

  const ChatMessagesState({
    required this.isLoading,
    this.messages = const [],
    this.relatedConversations = const [],
    this.hasMore = false,
    this.errorMessage,
  });

  const ChatMessagesState.initial()
      : isLoading = true,
        messages = const [],
        relatedConversations = const [],
        hasMore = false,
        errorMessage = null;

  const ChatMessagesState.loaded({
    required this.messages,
    this.hasMore = false,
    this.relatedConversations = const [],
  })  : isLoading = false,
        errorMessage = null;

  ChatMessagesState copyWith({
    bool? isLoading,
    List<msg.Message>? messages,
    List<msg.Conversation>? relatedConversations,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      relatedConversations: relatedConversations ?? this.relatedConversations,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}
