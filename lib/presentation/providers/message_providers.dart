import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/message_service.dart';
import '../../data/services/notification_service.dart';
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
  return ConversationsNotifier(ref.watch(messageServiceProvider), ref);
});

/// Unread messages count provider - uses cheap /v2/notifications/unread-count
class UnreadCountNotifier extends StateNotifier<int> {
  final NotificationService _notificationService;
  final Ref _ref;
  Timer? _timer;

  UnreadCountNotifier(this._notificationService, this._ref) : super(0) {
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
      final count = await _notificationService.getUnreadMessagesCount();
      if (mounted) {
        state = count;
      }
    } catch (_) {
      // Handle error silently for background polling
    }
  }

  void decrementBy(int count) {
    if (count <= 0) return;
    state = (state - count).clamp(0, 999999);
  }

  void pausePolling() {
    _timer?.cancel();
    _timer = null;
  }

  void resumePolling() {
    _timer?.cancel();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final unreadMessagesCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier(ref.watch(notificationServiceProvider), ref);
});

/// Lifecycle Provider - Triggers refresh when app comes to foreground
final appLifecycleProvider =
    StateNotifierProvider<LifecycleNotifier, AppLifecycleState>((ref) {
  return LifecycleNotifier(ref);
});

class LifecycleNotifier extends StateNotifier<AppLifecycleState>
    with WidgetsBindingObserver {
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
      _ref.read(conversationsProvider.notifier).refreshConversations();
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
  final Ref _ref;
  int _loadGeneration = 0;

  ConversationsNotifier(this._messageService, this._ref)
      : super(const ConversationsState.initial());

  Future<void> loadConversations({int page = 1, int? currentUserId}) async {
    if (state.isLoading && state.conversations.isNotEmpty && page == 1) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final generation = ++_loadGeneration;

    final response = await _messageService.getConversations(
      page: page,
      currentUserId: currentUserId,
    );

    if (generation != _loadGeneration) return;

    if (response.success) {
      state = ConversationsState.loaded(
        conversations: response.conversations,
        total: response.total ?? response.conversations.length,
        hasMore: response.hasMore,
        nextCursor: response.nextCursor,
        currentPage: page,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> loadMore({int? currentUserId}) async {
    if (state.isLoading || !state.hasMore) return;
    final nextCursor = state.nextCursor;
    if (nextCursor == null) return;

    state = state.copyWith(isLoading: true);
    final generation = ++_loadGeneration;

    final response = await _messageService.getConversations(
      cursor: nextCursor,
      currentUserId: currentUserId,
    );

    if (generation != _loadGeneration) return;

    if (response.success) {
      state = ConversationsState.loaded(
        conversations: [...state.conversations, ...response.conversations],
        total: response.total ??
            (state.conversations.length + response.conversations.length),
        hasMore: response.hasMore,
        nextCursor: response.nextCursor,
        currentPage: state.currentPage + 1,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Refresh conversations list (e.g., after reading a message or on tab switch)
  Future<void> refreshConversations({int? currentUserId}) async {
    final generation = ++_loadGeneration;
    final response = await _messageService.getConversations(
      page: 1,
      currentUserId: currentUserId,
    );

    if (generation != _loadGeneration) return;

    if (response.success) {
      state = ConversationsState.loaded(
        conversations: response.conversations,
        total: response.total ?? response.conversations.length,
        hasMore: response.hasMore,
        nextCursor: response.nextCursor,
        currentPage: 1,
      );
    }
  }

  /// Optimistically mark a conversation read in the list
  void markConversationRead(int conversationId) {
    final idx = state.conversations.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;
    final conv = state.conversations[idx];
    final unread = conv.unreadCount ?? 0;
    if (unread <= 0) return;

    final updated = List<msg.Conversation>.from(state.conversations);
    updated[idx] = conv.copyWith(unreadCount: 0);
    state = state.copyWith(conversations: updated);

    // Optimistically update global badge count
    _ref.read(unreadMessagesCountProvider.notifier).decrementBy(unread);
  }

  /// Optimistically update the latest snippet and move conversation to top
  void updateConversationSnippet({
    required int conversationId,
    required String lastMessageBody,
    required int senderId,
  }) {
    final idx = state.conversations.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;

    final conv = state.conversations[idx];
    final updated = conv.copyWith(
      lastMessage: lastMessageBody,
      lastMessageAt: DateTime.now(),
      lastMessageSenderId: senderId,
    );

    final updatedList = List<msg.Conversation>.from(state.conversations);
    updatedList.removeAt(idx);
    updatedList.insert(0, updated);

    state = state.copyWith(conversations: updatedList);
  }
}

class ConversationsState {
  final bool isLoading;
  final List<msg.Conversation> conversations;
  final int total;
  final bool hasMore;
  final String? nextCursor;
  final int currentPage;
  final String? errorMessage;

  const ConversationsState({
    required this.isLoading,
    this.conversations = const [],
    this.total = 0,
    this.hasMore = false,
    this.nextCursor,
    this.currentPage = 1,
    this.errorMessage,
  });

  const ConversationsState.initial()
      : isLoading = true,
        conversations = const [],
        total = 0,
        hasMore = false,
        nextCursor = null,
        currentPage = 1,
        errorMessage = null;

  const ConversationsState.loaded({
    required this.conversations,
    this.total = 0,
    this.hasMore = false,
    this.nextCursor,
    this.currentPage = 1,
  })  : isLoading = false,
        errorMessage = null;

  ConversationsState copyWith({
    bool? isLoading,
    List<msg.Conversation>? conversations,
    int? total,
    bool? hasMore,
    String? nextCursor,
    int? currentPage,
    String? errorMessage,
  }) {
    return ConversationsState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

/// Chat Messages Provider - manages messages within a single conversation.
/// autoDispose ensures polling stops when the user navigates away from ChatScreen.
final chatMessagesProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesNotifier, ChatMessagesState, int>(
        (ref, conversationId) {
  final currentUserId = ref.watch(authStateProvider.select((s) => s.user?.id));
  return ChatMessagesNotifier(
    ref.watch(messageServiceProvider),
    conversationId,
    currentUserId,
    ref,
  );
});

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final MessageService _messageService;
  final int conversationId;
  final int? _currentUserId;
  final Ref _ref;
  Timer? _pollingTimer;
  int _loadGeneration = 0;
  bool _isMarkingRead = false;

  ChatMessagesNotifier(
    this._messageService,
    this.conversationId,
    this._currentUserId,
    this._ref,
  ) : super(const ChatMessagesState.initial()) {
    // Set active conversation ID for FCM suppression
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(activeConversationIdProvider.notifier).state = conversationId;
    });
    loadMessages(isInitial: true);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchNewMessages();
    });
  }

  Future<void> fetchNewMessages() async {
    // If initial load is still running, wait for it
    if (state.isLoading) return;

    // If conversation is empty (no messages yet), retry initial load
    if (state.messages.isEmpty) {
      await loadMessages();
      return;
    }

    final lastMessage = state.messages.last;
    final response = await _messageService.fetchNewMessages(
      conversationId: conversationId,
      lastMessageId: lastMessage.id,
      currentUserId: _currentUserId,
    );

    if (response.success && response.messages.isNotEmpty && mounted) {
      final existingIds = state.messages.map((m) => m.id).toSet();
      final trulyNew =
          response.messages.where((m) => !existingIds.contains(m.id)).toList();

      if (trulyNew.isNotEmpty) {
        state = state.copyWith(
          messages: [...state.messages, ...trulyNew],
        );

        // Mark received messages read immediately
        _markAsReadOnServer(trulyNew);

        // Update list snippet for this conversation
        final newest = trulyNew.last;
        _ref.read(conversationsProvider.notifier).updateConversationSnippet(
              conversationId: conversationId,
              lastMessageBody: newest.body,
              senderId: newest.senderId,
            );
      }
    }
  }

  Future<void> loadMessages({
    int page = 1,
    bool isInitial = false,
    msg.Conversation? initialConversation,
  }) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final generation = ++_loadGeneration;

    // Load conversation metadata if not present
    if (state.conversation == null && initialConversation != null) {
      state = state.copyWith(conversation: initialConversation);
    }

    final response = await _messageService.getConversationMessages(
      conversationId: conversationId,
      page: page,
      currentUserId: _currentUserId,
    );

    if (generation != _loadGeneration) return;

    if (response.success) {
      final newMessages = page == 1
          ? response.messages
          : [...response.messages, ...state.messages];

      // If conversation metadata is still missing, fetch it
      msg.Conversation? conv = state.conversation;
      if (conv == null) {
        final convResp = await _messageService.getConversation(
          conversationId,
          currentUserId: _currentUserId,
        );
        if (convResp.success && convResp.conversation != null) {
          conv = convResp.conversation;
        }
      }

      state = ChatMessagesState.loaded(
        messages: newMessages,
        hasMore: response.hasMore,
        nextCursor: response.nextCursor,
        conversation: conv,
        relatedConversations: _findRelatedConversations(conv),
      );

      // Mark received messages read on server and locally
      _markAsReadOnServer(newMessages);
    } else {
      if (state.messages.isEmpty) {
        state = ChatMessagesState(
          isLoading: false,
          messages: const [],
          hasMore: false,
          errorMessage: response.message,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  List<msg.Conversation> _findRelatedConversations(msg.Conversation? conv) {
    if (conv == null) return const [];
    final all = _ref.read(conversationsProvider).conversations;
    final otherId = conv.getOtherParticipantId(_currentUserId ?? 0);
    if (otherId == null) return const [];

    return all.where((c) {
      final cOther = c.getOtherParticipantId(_currentUserId ?? 0);
      return cOther == otherId;
    }).toList();
  }

  Future<void> _markAsReadOnServer(List<msg.Message> targetMessages) async {
    if (_isMarkingRead) return;

    final hasUnreadFromOther = targetMessages.any((m) =>
        m.senderId != _currentUserId && (!m.isRead || m.readAt == null));

    if (!hasUnreadFromOther) return;

    _isMarkingRead = true;
    try {
      await _messageService.markAsRead(conversationId);

      if (mounted) {
        // Optimistically update local message read receipts
        final updated = state.messages.map((m) {
          if (m.senderId != _currentUserId && (!m.isRead || m.readAt == null)) {
            return m.copyWith(isRead: true, readAt: DateTime.now());
          }
          return m;
        }).toList();

        state = state.copyWith(messages: updated);
      }

      // Mark conversation read in list & decrement badge
      _ref
          .read(conversationsProvider.notifier)
          .markConversationRead(conversationId);
      _ref.read(unreadMessagesCountProvider.notifier).refresh();
    } finally {
      _isMarkingRead = false;
    }
  }

  Future<bool> sendMessage(String body) async {
    final response = await _messageService.sendMessage(
      conversationId: conversationId,
      body: body,
    );

    if (response.success && response.message != null) {
      final sentMessage = response.message!;
      state = state.copyWith(
        messages: [...state.messages, sentMessage],
      );

      _ref.read(conversationsProvider.notifier).updateConversationSnippet(
            conversationId: conversationId,
            lastMessageBody: sentMessage.body,
            senderId: sentMessage.senderId,
          );

      return true;
    }

    return false;
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
  final msg.Conversation? conversation;
  final bool hasMore;
  final String? nextCursor;
  final String? errorMessage;

  const ChatMessagesState({
    required this.isLoading,
    this.messages = const [],
    this.relatedConversations = const [],
    this.conversation,
    this.hasMore = false,
    this.nextCursor,
    this.errorMessage,
  });

  const ChatMessagesState.initial()
      : isLoading = true,
        messages = const [],
        relatedConversations = const [],
        conversation = null,
        hasMore = false,
        nextCursor = null,
        errorMessage = null;

  const ChatMessagesState.loaded({
    required this.messages,
    this.hasMore = false,
    this.nextCursor,
    this.relatedConversations = const [],
    this.conversation,
  })  : isLoading = false,
        errorMessage = null;

  ChatMessagesState copyWith({
    bool? isLoading,
    List<msg.Message>? messages,
    List<msg.Conversation>? relatedConversations,
    msg.Conversation? conversation,
    bool? hasMore,
    String? nextCursor,
    String? errorMessage,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      relatedConversations: relatedConversations ?? this.relatedConversations,
      conversation: conversation ?? this.conversation,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      errorMessage: errorMessage,
    );
  }
}
