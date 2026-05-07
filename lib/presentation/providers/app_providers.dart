import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/favorite_service.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/message_service.dart';
import '../../data/services/payment_service.dart';
import '../../data/services/subscription_service.dart';
import '../../data/services/kyc_service.dart';
import '../../data/services/conference_service.dart';
import '../../data/services/interest_service.dart';
import '../../data/services/address_service.dart';
import '../../data/models/subscription.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/local_notification_service.dart';
import 'auth_provider.dart';
import '../../data/models/message.dart' as msg;

/// Global Navigator Key for context-less navigation (useful for overlays)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global Route Observer for navigation tracking
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

/// Is connected stream
final isConnectedProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityProvider).connectionStatus;
});

/// Favorite Provider
final favoriteServiceProvider =
    Provider<FavoriteService>((ref) => FavoriteService());
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(favoriteServiceProvider));
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteService _favoriteService;
  FavoritesNotifier(this._favoriteService)
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
          totalUnread += (conv.unreadCount ?? 0) as int;
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
      if (state.conversations.isEmpty) {
        state = const ConversationsState.loaded(conversations: [], total: 0);
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: response.message);
      }
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

  ChatMessagesNotifier(
      this._messageService, this.conversationId, this._currentUserId, this._ref)
      : super(const ChatMessagesState.initial()) {
    // Set active conversation ID for FCM suppression
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(activeConversationIdProvider.notifier).state = conversationId;
    });
    loadMessages();
  }

  final Ref _ref;

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
      : super(const SubscriptionState.initial());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Both getPlans and getCurrentSubscription use the same endpoint
      // We'll use getPlans as it returns the full plans list
      final response = await _subscriptionService.getPlans();
      
      // We also need the current subscription info which is in the same response
      // but SubscriptionServiceApi splits them. To be efficient without changing 
      // the service significantly yet, we'll call getCurrentSubscription 
      // which is already cached or use a single call if we refactor.
      // For now, let's just make one call that gets everything.
      final currentSubResponse = await _subscriptionService.getCurrentSubscription();

      if (response.success && currentSubResponse.success) {
        state = SubscriptionState.loaded(
          plans: response.plans,
          subscription: currentSubResponse.subscription,
          canCreateListing: currentSubResponse.canCreateListing,
          canFeatureListing: currentSubResponse.canFeatureListing,
        );
      } else {
        state = state.copyWith(
          isLoading: false, 
          errorMessage: response.message.isNotEmpty ? response.message : currentSubResponse.message
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
  final String? errorMessage;

  const SubscriptionState({
    required this.isLoading,
    this.plans = const [],
    this.subscription,
    this.canCreateListing = true,
    this.canFeatureListing = true,
    this.errorMessage,
  });

  const SubscriptionState.initial()
      : isLoading = true,
        plans = const [],
        subscription = null,
        canCreateListing = true,
        canFeatureListing = true,
        errorMessage = null;

  const SubscriptionState.loaded({
    required this.plans,
    this.subscription,
    this.canCreateListing = true,
    this.canFeatureListing = true,
  })  : isLoading = false,
        errorMessage = null;

  SubscriptionState copyWith({
    bool? isLoading,
    List<SubscriptionPlan>? plans,
    Subscription? subscription,
    bool? canCreateListing,
    bool? canFeatureListing,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      subscription: subscription ?? this.subscription,
      canCreateListing: canCreateListing ?? this.canCreateListing,
      canFeatureListing: canFeatureListing ?? this.canFeatureListing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
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
      // Set status to error or keep existing to stop loading spinner
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.status,
        status: state.status == 'none' ? 'error' : state.status,
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
  bool get isNone => status == 'none' || status == 'error' || status.isEmpty;
}

/// Conference Provider
final conferenceServiceProvider =
    Provider<ConferenceService>((ref) => ConferenceService());
final conferencesProvider =
    StateNotifierProvider<ConferencesNotifier, ConferencesState>((ref) {
  return ConferencesNotifier(ref.watch(conferenceServiceProvider));
});

class ConferencesNotifier extends StateNotifier<ConferencesState> {
  final ConferenceService _conferenceService;
  ConferencesNotifier(this._conferenceService)
      : super(const ConferencesState.initial());

  Future<void> loadConferences() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _conferenceService.getConferences();
    if (response.success) {
      state = ConferencesState.loaded(conferences: response.conferences);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }
}

class ConferencesState {
  final bool isLoading;
  final List<dynamic> conferences;
  final String? errorMessage;
  const ConferencesState(
      {required this.isLoading,
      this.conferences = const [],
      this.errorMessage});
  const ConferencesState.initial()
      : isLoading = true,
        conferences = const [],
        errorMessage = null;
  const ConferencesState.loaded({required this.conferences})
      : isLoading = false,
        errorMessage = null;
  ConferencesState copyWith(
      {bool? isLoading, List<dynamic>? conferences, String? errorMessage}) {
    return ConferencesState(
        isLoading: isLoading ?? this.isLoading,
        conferences: conferences ?? this.conferences,
        errorMessage: errorMessage);
  }
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
  return IncomingCallNotifier(ref.watch(conferenceServiceProvider));
});

class IncomingCallNotifier extends StateNotifier<IncomingCall?> {
  final ConferenceService _conferenceService;
  IncomingCallNotifier(this._conferenceService) : super(null);

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

/// Interest Provider
final interestServiceProvider =
    Provider<InterestService>((ref) => InterestService());
final myInterestsProvider =
    StateNotifierProvider<MyInterestsNotifier, MyInterestsState>((ref) {
  return MyInterestsNotifier(ref.watch(interestServiceProvider));
});

class MyInterestsNotifier extends StateNotifier<MyInterestsState> {
  final InterestService _interestService;
  MyInterestsNotifier(this._interestService)
      : super(const MyInterestsState.initial());

  Future<void> loadInterests({int page = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _interestService.getMyInterests(page: page);
    if (response.success) {
      state = MyInterestsState.loaded(
          interests: response.interests, total: response.total ?? 0);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> expressInterest(int listingId, {String? message}) async {
    final response = await _interestService.expressInterest(
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

/// Locale Provider
final localeProvider =
    StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(const LocaleState.initial()) {
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
    }
  }

  Future<void> setLocale(Locale locale) async {
    final box = await Hive.openBox('app_preferences');
    await box.put('locale', locale.languageCode);

    state = LocaleState.loaded(locale: locale);
    
    // Sync to API Client
    ApiClient.currentLocale = locale.languageCode;
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
