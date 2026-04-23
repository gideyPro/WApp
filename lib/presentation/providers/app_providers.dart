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
import '../../core/network/connectivity_service.dart';
import '../../core/network/api_client.dart';
import '../../data/models/message.dart' as msg;

/// Connectivity Provider
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
  return NotificationNotifier(ref.watch(notificationServiceProvider));
});
final unreadCountProvider = StreamProvider<int>((ref) async* {
  final service = ref.watch(notificationServiceProvider);
  while (true) {
    try {
      final response =
          await service.getNotifications(filter: 'unread', page: 1);
      if (response.success) {
        yield response.unreadCount;
      } else {
        yield 0;
      }
    } catch (e) {
      yield 0;
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  NotificationNotifier(this._notificationService)
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
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    state = state.copyWith(
        notifications:
            state.notifications.map((n) => n.copyWith(isRead: true)).toList());
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
final unreadMessagesCountProvider = StreamProvider<int>((ref) async* {
  final service = ref.watch(messageServiceProvider);
  while (true) {
    try {
      final response = await service.getConversations(page: 1, perPage: 100);
      if (response.success) {
        final totalUnread = response.conversations.fold<int>(
          0,
          (sum, conv) => sum + (conv.unreadCount ?? 0),
        );
        yield totalUnread;
      } else {
        yield 0;
      }
    } catch (e) {
      yield 0;
    }
    await Future.delayed(const Duration(seconds: 15));
  }
});

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
  return ChatMessagesNotifier(
      ref.watch(messageServiceProvider), conversationId);
});

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final MessageService _messageService;
  final int conversationId;
  Timer? _pollTimer;

  ChatMessagesNotifier(this._messageService, this.conversationId)
      : super(const ChatMessagesState.initial()) {
    loadMessages();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _pollNewMessages());
  }

  Future<void> loadMessages({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final response = await _messageService.getConversationMessages(
      conversationId: conversationId,
      page: page,
    );

    if (response.success) {
      final newMessages = page == 1
          ? response.messages
          : [...state.messages, ...response.messages];

      state = ChatMessagesState.loaded(
        messages: newMessages,
        hasMore: response.messages.length >= 50,
      );
    } else {
      // Graceful error handling - don't show error if no data yet
      if (state.messages.isEmpty) {
        state = const ChatMessagesState.loaded(messages: [], hasMore: false);
      }
    }
  }

  Future<void> _pollNewMessages() async {
    if (state.messages.isEmpty) return;
    try {
      final lastMessage = state.messages.last;
      final response = await _messageService.fetchNewMessages(
        conversationId: conversationId,
        after: lastMessage.createdAt,
      );
      if (response.success && response.messages.isNotEmpty) {
        state =
            state.copyWith(messages: [...state.messages, ...response.messages]);
      }
    } catch (_) {
      // Silently ignore polling errors
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
    _pollTimer?.cancel();
    super.dispose();
  }
}

class ChatMessagesState {
  final bool isLoading;
  final List<msg.Message> messages;
  final bool hasMore;
  final String? errorMessage;

  const ChatMessagesState({
    required this.isLoading,
    this.messages = const [],
    this.hasMore = false,
    this.errorMessage,
  });

  const ChatMessagesState.initial()
      : isLoading = true,
        messages = const [],
        hasMore = false,
        errorMessage = null;

  const ChatMessagesState.loaded({
    required this.messages,
    this.hasMore = false,
  })  : isLoading = false,
        errorMessage = null;

  ChatMessagesState copyWith({
    bool? isLoading,
    List<msg.Message>? messages,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
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

/// Subscription Provider
final subscriptionServiceProvider =
    Provider<SubscriptionServiceApi>((ref) => SubscriptionServiceApi());
final subscriptionPlansProvider = FutureProvider((ref) async {
  return ref.watch(subscriptionServiceProvider).getPlans();
});
final currentSubscriptionProvider = StateNotifierProvider<
    CurrentSubscriptionNotifier, CurrentSubscriptionState>((ref) {
  return CurrentSubscriptionNotifier(ref.watch(subscriptionServiceProvider));
});

class CurrentSubscriptionNotifier
    extends StateNotifier<CurrentSubscriptionState> {
  final SubscriptionServiceApi _subscriptionService;
  CurrentSubscriptionNotifier(this._subscriptionService)
      : super(const CurrentSubscriptionState.initial());

  Future<void> loadCurrentSubscription() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _subscriptionService.getCurrentSubscription();
    if (response.success) {
      state = CurrentSubscriptionState.loaded(
        subscription: response.subscription,
        canCreateListing: response.canCreateListing,
        canFeatureListing: response.canFeatureListing,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }
}

class CurrentSubscriptionState {
  final bool isLoading;
  final dynamic subscription;
  final bool canCreateListing;
  final bool canFeatureListing;
  final String? errorMessage;
  const CurrentSubscriptionState(
      {required this.isLoading,
      this.subscription,
      this.canCreateListing = true,
      this.canFeatureListing = true,
      this.errorMessage});
  const CurrentSubscriptionState.initial()
      : isLoading = true,
        subscription = null,
        canCreateListing = true,
        canFeatureListing = true,
        errorMessage = null;
  const CurrentSubscriptionState.loaded(
      {this.subscription,
      this.canCreateListing = true,
      this.canFeatureListing = true})
      : isLoading = false,
        errorMessage = null;
  CurrentSubscriptionState copyWith(
      {bool? isLoading,
      dynamic subscription,
      bool? canCreateListing,
      bool? canFeatureListing,
      String? errorMessage}) {
    return CurrentSubscriptionState(
        isLoading: isLoading ?? this.isLoading,
        subscription: subscription ?? this.subscription,
        canCreateListing: canCreateListing ?? this.canCreateListing,
        canFeatureListing: canFeatureListing ?? this.canFeatureListing,
        errorMessage: errorMessage);
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
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 3);

  IncomingCallNotifier(this._conferenceService) : super(null);

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(_pollingInterval, (_) => _checkForIncomingCall());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkForIncomingCall() async {
    if (state != null) return;

    try {
      final response = await _conferenceService.checkIncomingCall();

      if (response.hasIncoming && response.callData != null) {
        final callData = response.callData!;
        state = IncomingCall(
          conferenceId: callData['conference_id'] ?? 0,
          callerName: callData['caller_name'] ?? 'Unknown',
          callerAvatar: callData['caller_avatar'],
          callerInitials: callData['caller_initials'],
          listingTitle: callData['listing_title'],
        );
      }
    } catch (_) {}
  }

  void clearIncomingCall() {
    state = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
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
      final supportedLocales = const ['en', 'am', 'ti'];

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
