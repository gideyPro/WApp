import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/favorite_service.dart';
import '../../data/services/order_service.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/message_service.dart';
import '../../data/services/payment_service.dart';
import '../../data/services/subscription_service.dart';
import '../../data/services/kyc_service.dart';
import '../../data/services/lead_service.dart';
import '../../data/services/address_service.dart';
import '../../data/models/subscription.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import 'auth_provider.dart';
import '../../data/models/message.dart' as msg;

/// Global Navigator Key for context-less navigation (useful for overlays)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global Route Observer for navigation tracking

final appSettingsProvider = FutureProvider<Map<String, dynamic>>((_) async {
  try {
    final response =
        await ApiClient().dio.get('${ApiConstants.apiBase}/settings');
    if (response.statusCode == 200 && response.data is Map) {
      return response.data['data'] ?? {};
    }
  } catch (_) {}
  return {'subscription_enabled': false};
});
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// Selected Tab Provider for MainNavigationShell
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Currently active conversation ID (for suppression of background notifications)
final activeConversationIdProvider = StateProvider<int?>((ref) => null);
final connectivityProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

enum ConnectivityStatus { online, offline, connecting }

final connectivityStatusProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier(ref);
});

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  final Ref _ref;
  StreamSubscription? _subscription;
  bool _wasOffline = false;

  ConnectivityNotifier(this._ref) : super(ConnectivityStatus.online) {
    _init();
  }

  void _init() {
    _subscription = _ref.read(connectivityProvider).connectionStatus.listen((isConnected) {
      if (isConnected) {
        state = ConnectivityStatus.online;
        if (_wasOffline) {
          _triggerAutoHealing();
          _wasOffline = false;
        }
      } else {
        state = ConnectivityStatus.offline;
        _wasOffline = true;
      }
    });
  }

  void _triggerAutoHealing() {
    // Standard industry practice: auto-refresh active data when connection returns
    final authState = _ref.read(authStateProvider);
    if (authState.isAuthenticated) {
      // Silent refresh of core data
      _ref.read(unreadCountProvider.notifier).refresh();
      _ref.read(unreadMessagesCountProvider.notifier).refresh();
      _ref.read(conversationsProvider.notifier).loadConversations();
      _ref.read(notificationsProvider.notifier).loadNotifications();
      _ref.read(kycStatusProvider.notifier).loadKycStatus();
      _ref.read(subscriptionProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Is connected stream (keeping for backward compatibility if needed)
final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStatusProvider) == ConnectivityStatus.online;
});

/// Favorite Provider
final favoriteServiceProvider =
    Provider<FavoriteService>((ref) => FavoriteService());
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(favoriteServiceProvider), ref);
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteService _favoriteService;
  final Ref _ref;
  FavoritesNotifier(this._favoriteService, this._ref)
      : super(const FavoritesState.initial());

  Future<void> loadFavorites({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _favoriteService.getFavorites(page: page);
    if (response.success) {
      state = FavoritesState.loaded(
        favorites: response.listings,
        total: response.total ?? 0,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> toggleFavorite(int listingId) async {
    final response = await _favoriteService.toggleFavorite(listingId);
    if (response.success) {
      await loadFavorites();
      await _ref.read(profileProvider.notifier).loadProfile();
    }
    return response.success;
  }
}

class FavoritesState {
  final bool isLoading;
  final List<dynamic> favorites;
  final int total;
  final String? errorMessage;
  const FavoritesState(
      {required this.isLoading,
      this.favorites = const [],
      this.total = 0,
      this.errorMessage});
  const FavoritesState.initial()
      : isLoading = true,
        favorites = const [],
        total = 0,
        errorMessage = null;
  const FavoritesState.loaded({required this.favorites, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  FavoritesState copyWith(
      {bool? isLoading,
      List<dynamic>? favorites,
      int? total,
      String? errorMessage}) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }
}

/// Order Provider
final orderServiceProvider =
    Provider<OrderService>((ref) => OrderService());
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.watch(orderServiceProvider));
});

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderService _orderService;
  OrdersNotifier(this._orderService)
      : super(const OrdersState.initial());

  Future<void> loadOrders({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _orderService.getOrders(page: page);
    if (response.success) {
      state = OrdersState.loaded(
        orders: response.orders,
        total: response.total ?? 0,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    final response = await _orderService.cancelOrder(orderId);
    if (response.success) {
      await loadOrders();
    }
    return response.success;
  }
}

class OrdersState {
  final bool isLoading;
  final List<dynamic> orders;
  final int total;
  final String? errorMessage;
  const OrdersState(
      {required this.isLoading,
      this.orders = const [],
      this.total = 0,
      this.errorMessage});
  const OrdersState.initial()
      : isLoading = true,
        orders = const [],
        total = 0,
        errorMessage = null;
  const OrdersState.loaded({required this.orders, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  OrdersState copyWith(
      {bool? isLoading,
      List<dynamic>? orders,
      int? total,
      String? errorMessage}) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }
}

/// Profile Provider
final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileServiceProvider));
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  ProfileNotifier(this._profileService) : super(const ProfileState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _profileService.getProfile();
    if (response.success && response.user != null) {
      state = ProfileState.loaded(response.user!, stats: response.stats);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _profileService.updateProfile(data);
    if (response.success && response.user != null) {
      state = ProfileState.loaded(response.user!, stats: state.stats);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response.success;
  }
}

class ProfileState {
  final bool isLoading;
  final dynamic user;
  final ProfileStats? stats;
  final String? errorMessage;
  const ProfileState(
      {required this.isLoading, this.user, this.stats, this.errorMessage});
  const ProfileState.initial()
      : isLoading = true,
        user = null,
        stats = null,
        errorMessage = null;
  const ProfileState.loaded(this.user, {this.stats})
      : isLoading = false,
        errorMessage = null;
  ProfileState copyWith(
      {bool? isLoading,
      dynamic user,
      ProfileStats? stats,
      String? errorMessage}) {
    return ProfileState(
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        stats: stats ?? this.stats,
        errorMessage: errorMessage);
  }
}

/// Notification Provider
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
final notificationsProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(notificationServiceProvider), ref);
});
class UnreadNotifCountNotifier extends StateNotifier<int> {
  final NotificationService _notificationService;
  final Ref _ref;
  Timer? _timer;

  UnreadNotifCountNotifier(this._notificationService, this._ref) : super(0) {
    refresh();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    // Poll every 60 seconds as a fallback to FCM
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
      final response = await _notificationService.getNotifications(filter: 'unread', page: 1);
      if (response.success) {
        state = response.unreadCount;
      }
    } catch (e) {
      // Handle error silently for background polling
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final unreadCountProvider = StateNotifierProvider<UnreadNotifCountNotifier, int>((ref) {
  return UnreadNotifCountNotifier(ref.watch(notificationServiceProvider), ref);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final Ref _ref;
  NotificationNotifier(this._notificationService, this._ref)
      : super(const NotificationState.initial());

  Future<void> loadNotifications({int page = 1}) async {
    if (page == 1) state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _notificationService.getNotifications(page: page);
    if (response.success) {
      final newListings = page == 1
          ? response.notifications
          : [...state.notifications, ...response.notifications];
      state = NotificationState.loaded(
          notifications: newListings, total: response.total ?? 0);
      
      // Update unread count provider if we just loaded page 1
      if (page == 1) {
        _ref.read(unreadCountProvider.notifier).refresh();
      }
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> markAsRead(int id) async {
    await _notificationService.markAsRead(id);
    state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList());
    
    // Refresh unread count
    _ref.read(unreadCountProvider.notifier).refresh();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    state = state.copyWith(
        notifications:
            state.notifications.map((n) => n.copyWith(isRead: true)).toList());
    
    // Refresh unread count
    _ref.read(unreadCountProvider.notifier).refresh();
  }
}

class NotificationState {
  final bool isLoading;
  final List<dynamic> notifications;
  final int total;
  final String? errorMessage;
  const NotificationState(
      {required this.isLoading,
      this.notifications = const [],
      this.total = 0,
      this.errorMessage});
  const NotificationState.initial()
      : isLoading = true,
        notifications = const [],
        total = 0,
        errorMessage = null;
  const NotificationState.loaded({required this.notifications, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  NotificationState copyWith(
      {bool? isLoading,
      List<dynamic>? notifications,
      int? total,
      String? errorMessage}) {
    return NotificationState(
        isLoading: isLoading ?? this.isLoading,
        notifications: notifications ?? this.notifications,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}

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
  final List<dynamic> conversations;
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
      List<dynamic>? conversations,
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


/// Payment Provider
final paymentServiceProvider =
    Provider<PaymentService>((ref) => PaymentService());
final paymentHistoryProvider =
    StateNotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>((ref) {
  return PaymentHistoryNotifier(ref.watch(paymentServiceProvider));
});

class PaymentHistoryNotifier extends StateNotifier<PaymentHistoryState> {
  final PaymentService _paymentService;
  PaymentHistoryNotifier(this._paymentService)
      : super(const PaymentHistoryState.initial());

  Future<void> loadPayments({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _paymentService.getPaymentHistory(page: page);
    if (response.success) {
      state = PaymentHistoryState.loaded(
          payments: response.payments, total: response.total ?? 0);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }
}

class PaymentHistoryState {
  final bool isLoading;
  final List<dynamic> payments;
  final int total;
  final String? errorMessage;
  const PaymentHistoryState(
      {required this.isLoading,
      this.payments = const [],
      this.total = 0,
      this.errorMessage});
  const PaymentHistoryState.initial()
      : isLoading = true,
        payments = const [],
        total = 0,
        errorMessage = null;
  const PaymentHistoryState.loaded({required this.payments, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  PaymentHistoryState copyWith(
      {bool? isLoading,
      List<dynamic>? payments,
      int? total,
      String? errorMessage}) {
    return PaymentHistoryState(
        isLoading: isLoading ?? this.isLoading,
        payments: payments ?? this.payments,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}

/// Subscription Providers
final subscriptionServiceProvider =
    Provider<SubscriptionServiceApi>((ref) => SubscriptionServiceApi());

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(subscriptionServiceProvider));
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionServiceApi _subscriptionService;
  SubscriptionNotifier(this._subscriptionService)
      : super(const SubscriptionState.initial()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _subscriptionService.getFullData();

      if (data.success) {
        state = SubscriptionState.loaded(
          plans: data.plans,
          subscription: data.subscription,
          canCreateListing: data.canCreateListing,
          canFeatureListing: data.canFeatureListing,
          canViewVip: data.canViewVip,
          canCreateOrder: data.canCreateOrder,
          hasPaidSubscription: data.hasPaidSubscription,
          canSeeVideo: data.canSeeVideo,
          canSeeContact: data.canSeeContact,
          contactViewsUsed: data.contactViewsUsed,
          contactViewsRemaining: data.contactViewsRemaining,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: data.message,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class SubscriptionState {
  final bool isLoading;
  final List<SubscriptionPlan> plans;
  final Subscription? subscription;
  final bool canCreateListing;
  final bool canFeatureListing;
  final bool canViewVip;
  final bool canCreateOrder;
  final bool hasPaidSubscription;
  final bool canSeeVideo;
  final bool canSeeContact;
  final int contactViewsUsed;
  final int contactViewsRemaining;
  final String? errorMessage;

  const SubscriptionState({
    required this.isLoading,
    this.plans = const [],
    this.subscription,
    this.canCreateListing = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
    this.errorMessage,
  });

  const SubscriptionState.initial()
      : isLoading = true,
        plans = const [],
        subscription = null,
        canCreateListing = false,
        canFeatureListing = false,
        canViewVip = false,
        canCreateOrder = false,
        hasPaidSubscription = false,
        canSeeVideo = false,
        canSeeContact = false,
        contactViewsUsed = 0,
        contactViewsRemaining = 0,
        errorMessage = null;

  const SubscriptionState.loaded({
    required this.plans,
    this.subscription,
    this.canCreateListing = false,
    this.canFeatureListing = false,
    this.canViewVip = false,
    this.canCreateOrder = false,
    this.hasPaidSubscription = false,
    this.canSeeVideo = false,
    this.canSeeContact = false,
    this.contactViewsUsed = 0,
    this.contactViewsRemaining = 0,
  })  : isLoading = false,
        errorMessage = null;

  SubscriptionState copyWith({
    bool? isLoading,
    List<SubscriptionPlan>? plans,
    Subscription? subscription,
    bool? canCreateListing,
    bool? canFeatureListing,
    bool? canViewVip,
    bool? canCreateOrder,
    bool? hasPaidSubscription,
    bool? canSeeVideo,
    bool? canSeeContact,
    int? contactViewsUsed,
    int? contactViewsRemaining,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      subscription: subscription ?? this.subscription,
      canCreateListing: canCreateListing ?? this.canCreateListing,
      canFeatureListing: canFeatureListing ?? this.canFeatureListing,
      canViewVip: canViewVip ?? this.canViewVip,
      canCreateOrder: canCreateOrder ?? this.canCreateOrder,
      hasPaidSubscription: hasPaidSubscription ?? this.hasPaidSubscription,
      canSeeVideo: canSeeVideo ?? this.canSeeVideo,
      canSeeContact: canSeeContact ?? this.canSeeContact,
      contactViewsUsed: contactViewsUsed ?? this.contactViewsUsed,
      contactViewsRemaining: contactViewsRemaining ?? this.contactViewsRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasError => errorMessage != null;
}

/// KYC Provider
final kycServiceProvider = Provider<KycService>((ref) => KycService());
final kycStatusProvider =
    StateNotifierProvider<KycStatusNotifier, KycStatusState>((ref) {
  return KycStatusNotifier(ref.watch(kycServiceProvider));
});

class KycStatusNotifier extends StateNotifier<KycStatusState> {
  final KycService _kycService;
  KycStatusNotifier(this._kycService) : super(const KycStatusState.initial());

  Future<void> loadKycStatus() async {
    // Only set loading if not already loading to avoid flicker
    if (state.isLoading && state.status == 'none') {
      // Already in initial loading state
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final response = await _kycService.getKycStatus();
    if (response.success) {
      state = KycStatusState.loaded(
        status: response.status,
        isVerified: response.isVerified,
        rejectionReason: response.rejectionReason,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.errorMessage ?? response.status,
        status: response.status,
      );
    }
  }
}

class KycStatusState {
  final bool isLoading;
  final String status;
  final bool isVerified;
  final String? rejectionReason;
  final String? submittedAt;
  final String? errorMessage;
  const KycStatusState(
      {required this.isLoading,
      this.status = 'none',
      this.isVerified = false,
      this.rejectionReason,
      this.submittedAt,
      this.errorMessage});
  const KycStatusState.initial()
      : isLoading = false,
        status = 'none',
        isVerified = false,
        rejectionReason = null,
        submittedAt = null,
        errorMessage = null;
  const KycStatusState.loaded(
      {this.status = 'none',
      this.isVerified = false,
      this.rejectionReason,
      this.submittedAt})
      : isLoading = false,
        errorMessage = null;
  KycStatusState copyWith(
      {bool? isLoading,
      String? status,
      bool? isVerified,
      String? rejectionReason,
      String? submittedAt,
      String? errorMessage}) {
    return KycStatusState(
        isLoading: isLoading ?? this.isLoading,
        status: status ?? this.status,
        isVerified: isVerified ?? this.isVerified,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        submittedAt: submittedAt ?? this.submittedAt,
        errorMessage: errorMessage);
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasError => status == 'error';
  bool get isNone => status == 'none' || status.isEmpty;
}

/// Incoming Call Provider
class IncomingCall {
  final int conferenceId;
  final String callerName;
  final String? callerAvatar;
  final String? callerInitials;
  final String? listingTitle;

  const IncomingCall({
    required this.conferenceId,
    required this.callerName,
    this.callerAvatar,
    this.callerInitials,
    this.listingTitle,
  });
}

final incomingCallProvider =
    StateNotifierProvider<IncomingCallNotifier, IncomingCall?>((ref) {
  return IncomingCallNotifier();
});

class IncomingCallNotifier extends StateNotifier<IncomingCall?> {
  IncomingCallNotifier() : super(null);

  void setIncomingCall(IncomingCall? call) {
    state = call;
  }

  void clearIncomingCall() {
    state = null;
  }

  void markDeclined(int conferenceId) {
    // Just clear the state for now
    state = null;
  }
}

/// Lead (Interest) Provider
final leadServiceProvider =
    Provider<LeadService>((ref) => LeadService());
final myInterestsProvider =
    StateNotifierProvider<MyInterestsNotifier, MyInterestsState>((ref) {
  return MyInterestsNotifier(ref.watch(leadServiceProvider));
});

class MyInterestsNotifier extends StateNotifier<MyInterestsState> {
  final LeadService _leadService;
  MyInterestsNotifier(this._leadService)
      : super(const MyInterestsState.initial());

  Future<void> loadInterests({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _leadService.getMyInterests(page: page);
    if (response.success) {
      state = MyInterestsState.loaded(
          interests: response.leads, total: response.leads.length);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> expressInterest(int listingId, {String? message}) async {
    final response = await _leadService.expressInterest(
        listingId: listingId, message: message);
    if (response.success) await loadInterests();
    return response.success;
  }
}

class MyInterestsState {
  final bool isLoading;
  final List<dynamic> interests;
  final int total;
  final String? errorMessage;
  const MyInterestsState(
      {required this.isLoading,
      this.interests = const [],
      this.total = 0,
      this.errorMessage});
  const MyInterestsState.initial()
      : isLoading = true,
        interests = const [],
        total = 0,
        errorMessage = null;
  const MyInterestsState.loaded({required this.interests, this.total = 0})
      : isLoading = false,
        errorMessage = null;
  MyInterestsState copyWith(
      {bool? isLoading,
      List<dynamic>? interests,
      int? total,
      String? errorMessage}) {
    return MyInterestsState(
        isLoading: isLoading ?? this.isLoading,
        interests: interests ?? this.interests,
        total: total ?? this.total,
        errorMessage: errorMessage);
  }
}

/// Address Provider
final addressServiceProvider =
    Provider<AddressService>((ref) => AddressService());
final regionsProvider = FutureProvider((ref) async {
  return ref.watch(addressServiceProvider).getRegions();
});
final zonesProvider = FutureProvider.family((ref, String region) async {
  return ref.watch(addressServiceProvider).getZones(region: region);
});
final woredasProvider =
    FutureProvider.family((ref, Map<String, String> params) async {
  return ref
      .watch(addressServiceProvider)
      .getWoredas(region: params['region']!, zone: params['zone']!);
});
final kebelesProvider =
    FutureProvider.family((ref, Map<String, String> params) async {
  return ref.watch(addressServiceProvider).getKebeles(
      region: params['region']!,
      zone: params['zone']!,
      woreda: params['woreda']!);
});

/// Global cache for localized address names
/// Structure: { 'en_name': 'localized_name' }
final addressCacheProvider = StateProvider<Map<String, String>>((ref) => {});

/// Locale Provider
final localeProvider =
    StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<LocaleState> {
  final Ref _ref;
  LocaleNotifier(this._ref) : super(const LocaleState.initial()) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    // Load from Hive
    final box = await Hive.openBox('app_preferences');
    final savedLocale = box.get('locale');

    if (savedLocale != null) {
      state = LocaleState.loaded(locale: Locale(savedLocale));
    } else {
      // Use system locale or default to English
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      const supportedLocales = ['en', 'am', 'ti'];

      if (supportedLocales.contains(systemLocale.languageCode)) {
        state = LocaleState.loaded(locale: systemLocale);
      } else {
        state = const LocaleState.loaded(locale: Locale('en'));
      }
    }
    
    // Sync to API Client
    if (state.locale != null) {
      ApiClient.currentLocale = state.locale!.languageCode;
      _warmupAddressCache();
    }
  }

  Future<void> setLocale(Locale locale) async {
    final box = await Hive.openBox('app_preferences');
    await box.put('locale', locale.languageCode);

    state = LocaleState.loaded(locale: locale);
    
    // Sync to API Client
    ApiClient.currentLocale = locale.languageCode;
    _warmupAddressCache();
  }

  /// Prefetch localized region/zone names to populate the cache
  Future<void> _warmupAddressCache() async {
    final locale = state.locale?.languageCode ?? 'en';
    if (locale == 'en') return;

    try {
      final service = _ref.read(addressServiceProvider);
      
      // 1. Fetch Regions
      final regResp = await service.getRegions(locale: 'en'); // Get EN keys
      final locRegResp = await service.getRegions(locale: locale); // Get Loc keys
      
      if (regResp.success && locRegResp.success) {
        final cache = {..._ref.read(addressCacheProvider)};
        final enNames = regResp.regions.map((r) => r.region).toList();
        final locNames = locRegResp.regions.map((r) => r.region).toList();
        
        for (int i = 0; i < enNames.length && i < locNames.length; i++) {
          if (enNames[i] != null && locNames[i] != null) {
            cache[enNames[i]!] = locNames[i]!;
          }
        }

        // 2. Fetch common Zones (optional but helpful for speed)
        // For brevity, we focus on regions first as they are most visible
        
        _ref.read(addressCacheProvider.notifier).state = cache;
      }
    } catch (_) {}
  }
}

class LocaleState {
  final bool isLoading;
  final Locale? locale;
  final String? errorMessage;

  const LocaleState({
    required this.isLoading,
    this.locale,
    this.errorMessage,
  });

  const LocaleState.initial() : this(isLoading: true);
  const LocaleState.loaded({required this.locale})
      : isLoading = false,
        errorMessage = null;

  LocaleState copyWith({
    bool? isLoading,
    Locale? locale,
    String? errorMessage,
  }) {
    return LocaleState(
      isLoading: isLoading ?? this.isLoading,
      locale: locale ?? this.locale,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
