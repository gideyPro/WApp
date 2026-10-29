import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/conversation.dart';
import '../../data/services/v2/conversation_service.dart';
import '../../data/services/v2/notification_service.dart';
import 'auth_provider.dart';
import 'notification_providers.dart';
import 'v2_providers.dart';

/// Currently active conversation ID (for suppression of background notifications)
final activeConversationIdProvider = StateProvider<int?>((ref) => null);

/// Cursor-paginated chat threads from `/v2/conversations`.
///
/// The legacy symbol is kept so FCM, connectivity healing and the app
/// lifecycle observer keep refreshing the same provider.
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  return ConversationsNotifier(ref.watch(conversationV2ServiceProvider));
});

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ConversationServiceV2 _service;

  ConversationsNotifier(this._service)
      : super(const ConversationsState.initial());

  /// Load the newest page. Refreshes triggered by FCM or a tab switch keep the
  /// current list visible unless [silent] is explicitly false.
  Future<void> loadConversations({bool? silent}) async {
    final quiet = silent ?? state.conversations.isNotEmpty;

    if (!quiet) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final page = await _service.fetch();
      state = ConversationsState.loaded(
        conversations: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load conversations',
      );
    }
  }

  /// Refresh after returning from a chat without blanking the list.
  Future<void> refreshConversations() => loadConversations(silent: true);

  Future<void> loadMore() async {
    final cursor = state.nextCursor;

    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final page = await _service.fetch(cursor: cursor);
      state = state.copyWith(
        conversations: [...state.conversations, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more conversations',
      );
    }
  }

  /// Zero the unread badge for one row after a read receipt.
  void markConversationRead(int conversationId) {
    final updated = state.conversations
        .map(
          (conversation) => conversation.id == conversationId
              ? conversation.copyWith(unreadCount: 0)
              : conversation,
        )
        .toList();

    state = state.copyWith(conversations: updated);
  }

  /// Apply a message the viewer just sent, keeping newest-first ordering.
  void applyMessage(int conversationId, ChatMessage message) {
    final updated = [
      for (final conversation in state.conversations)
        conversation.id == conversationId
            ? conversation.copyWith(
                lastMessage: message,
                lastMessageAt: message.createdAt,
                unreadCount: 0,
              )
            : conversation,
    ];

    updated.sort(_newestFirst);
    state = state.copyWith(conversations: updated);
  }

  static int _newestFirst(ChatConversation a, ChatConversation b) {
    final aAt = a.lastMessageAt;
    final bAt = b.lastMessageAt;

    if (aAt == null && bAt == null) return b.id.compareTo(a.id);
    if (aAt == null) return 1;
    if (bAt == null) return -1;

    final byDate = bAt.compareTo(aAt);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  }
}

class ConversationsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ChatConversation> conversations;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  const ConversationsState({
    required this.isLoading,
    this.isLoadingMore = false,
    this.conversations = const [],
    this.nextCursor,
    this.hasMore = false,
    this.errorMessage,
  });

  const ConversationsState.initial()
      : isLoading = true,
        isLoadingMore = false,
        conversations = const [],
        nextCursor = null,
        hasMore = false,
        errorMessage = null;

  const ConversationsState.loaded({
    required this.conversations,
    this.nextCursor,
    this.hasMore = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  /// Cursor pages load incrementally, so this is the number of threads fetched
  /// so far rather than a server-side total.
  int get total => conversations.length;

  ConversationsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ChatConversation>? conversations,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ConversationsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      conversations: conversations ?? this.conversations,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

/// Unread messages badge. The dedicated endpoint keeps messages separate from
/// notifications, so the two tab badges never double count.
final unreadMessagesCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier(ref.watch(notificationV2ServiceProvider), ref);
});

class UnreadCountNotifier extends StateNotifier<int> {
  final NotificationServiceV2 _notificationService;
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
      final counters = await _notificationService.unreadCount();
      setCount(counters.messages);
    } catch (_) {
      // Background polling stays silent; the screens surface their own errors.
    }
  }

  /// Use a count returned by a read receipt instead of re-fetching.
  void setCount(int value) {
    final next = value < 0 ? 0 : value;
    if (state != next) state = next;
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
      _ref.read(conversationsProvider.notifier).loadConversations();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Messages for one conversation, stored oldest-first for display.
///
/// The API returns newest-first pages; [loadOlder] walks the cursor and
/// prepends each reversed page, while polling appends newly arrived messages.
final chatMessagesProvider =
    StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, int>(
        (ref, conversationId) {
  return ChatMessagesNotifier(
    ref.watch(conversationV2ServiceProvider),
    conversationId,
    ref,
  );
});

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ConversationServiceV2 _service;
  final int conversationId;
  final Ref _ref;
  Timer? _pollingTimer;
  bool _polling = false;
  int _lastReadMessageId = 0;

  ChatMessagesNotifier(this._service, this.conversationId, this._ref)
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
      _pollForNewMessages();
    });
  }

  Future<void> _pollForNewMessages() async {
    if (_polling || state.isLoading || state.messages.isEmpty) return;

    _polling = true;

    try {
      final page = await _service.fetchMessages(conversationId);
      final newestId = state.messages.last.id;
      final fresh = page.items
          .where((message) => message.id > newestId)
          .toList()
          .reversed
          .toList();

      if (fresh.isNotEmpty && mounted) {
        state = state.copyWith(messages: [...state.messages, ...fresh]);
        await markRead();
      }
    } catch (_) {
      // Polling failures are silent; the next tick retries.
    } finally {
      _polling = false;
    }
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _service.fetchMessages(conversationId);
      state = ChatMessagesState.loaded(
        messages: page.items.reversed.toList(),
        olderCursor: page.nextCursor,
        hasMoreOlder: page.hasMore && page.nextCursor != null,
      );

      // Reads are an explicit receipt in v2; GET never mutates state.
      await markRead();
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load messages',
      );
    }
  }

  /// Prepend the next older page while keeping chronological display order.
  Future<void> loadOlder() async {
    final cursor = state.olderCursor;

    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMoreOlder ||
        cursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _service.fetchMessages(
        conversationId,
        cursor: cursor,
      );
      state = state.copyWith(
        messages: [...page.items.reversed, ...state.messages],
        olderCursor: page.nextCursor ?? state.olderCursor,
        hasMoreOlder: page.hasMore && page.nextCursor != null,
        isLoadingMore: false,
      );
    } on ApiV2Exception catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load earlier messages',
      );
    }
  }

  /// Mark received messages read. Safe to repeat and skipped once the newest
  /// incoming message has already been acknowledged.
  Future<void> markRead() async {
    final unread = state.messages
        .where((message) => !message.isMine && !message.isRead)
        .toList();

    if (unread.isEmpty) return;

    final newestUnreadId = unread.last.id;
    if (newestUnreadId <= _lastReadMessageId) return;

    final previous = _lastReadMessageId;
    _lastReadMessageId = newestUnreadId;

    try {
      await _service.markRead(conversationId);
      _ref
          .read(conversationsProvider.notifier)
          .markConversationRead(conversationId);
      _ref.read(unreadMessagesCountProvider.notifier).refresh();
    } catch (_) {
      _lastReadMessageId = previous;
    }
  }

  Future<bool> sendMessage(String body) async {
    try {
      final message = await _service.sendMessage(conversationId, body);
      final exists = state.messages.any((item) => item.id == message.id);

      if (!exists && mounted) {
        state = state.copyWith(messages: [...state.messages, message]);
      }

      _ref.read(conversationsProvider.notifier).applyMessage(
            conversationId,
            message,
          );
      return true;
    } catch (_) {
      return false;
    }
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
  final bool isLoadingMore;
  final List<ChatMessage> messages;
  final String? olderCursor;
  final bool hasMoreOlder;
  final String? errorMessage;

  const ChatMessagesState({
    required this.isLoading,
    this.isLoadingMore = false,
    this.messages = const [],
    this.olderCursor,
    this.hasMoreOlder = false,
    this.errorMessage,
  });

  const ChatMessagesState.initial()
      : isLoading = true,
        isLoadingMore = false,
        messages = const [],
        olderCursor = null,
        hasMoreOlder = false,
        errorMessage = null;

  const ChatMessagesState.loaded({
    required this.messages,
    this.olderCursor,
    this.hasMoreOlder = false,
  })  : isLoading = false,
        isLoadingMore = false,
        errorMessage = null;

  ChatMessagesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ChatMessage>? messages,
    String? olderCursor,
    bool? hasMoreOlder,
    String? errorMessage,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      messages: messages ?? this.messages,
      olderCursor: olderCursor ?? this.olderCursor,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      errorMessage: errorMessage,
    );
  }
}
