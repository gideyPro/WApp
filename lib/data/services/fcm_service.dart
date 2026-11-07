import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/local_notification_service.dart';
import '../../core/router/app_router.dart';
import '../../presentation/providers/app_providers.dart';
import 'fcm_api_service.dart';

final fcmApiServiceProvider = Provider<FcmApiService>((ref) => FcmApiService());

class FcmService {
  static final Map<int, int> _notificationIdMap = {};

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Ref _ref;
  Timer? _convRefreshDebounce;
  Timer? _badgeRefreshDebounce;

  FcmService(this._ref);

  Future<void> initialize() async {
    // 1. Request permissions (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else {
      log('User declined or has not accepted permission');
    }

    // 2. Register local notification tap handler
    LocalNotificationService.onNotificationTapped = (payload) {
      if (payload == null || payload.isEmpty) return;
      if (payload.startsWith('/')) {
        goRouter.push(payload);
      } else {
        final convId = int.tryParse(payload);
        if (convId != null) {
          goRouter.push('/chat/$convId');
        }
      }
    };

    // 3. Get and Register Token
    await _updateToken();

    // 4. Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      log('FCM Token Refreshed: $newToken');
      await _ref.read(fcmApiServiceProvider).registerToken(newToken);
    });

    // 5. Check if app was opened from a terminated state via notification
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        log('App launched from terminated state via notification: ${initialMessage.data}');
        _navigateFromData(initialMessage.data);
      }
    } catch (e) {
      log('Error checking initial FCM message: $e');
    }

    // 6. Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      final type = message.data['type'];
      final notification = message.notification;

      // Update Providers
      if (type == 'incoming_call') {
        _handleIncomingCall(message.data);
      } else if (type == 'message') {
        _debounceRefreshBadges();
        _debounceRefreshConversations();

        // Trigger the specific active ChatMessagesNotifier to fetch incrementally
        final conversationIdStr = message.data['conversation_id'];
        if (conversationIdStr != null) {
          final convId = int.tryParse(conversationIdStr.toString());
          if (convId != null) {
            _ref.read(chatMessagesProvider(convId).notifier).fetchNewMessages();
          }
        }
      } else {
        // General Notification
        _ref.read(unreadCountProvider.notifier).refresh();

        // Refresh the notifications list if the user is on that screen
        _ref.read(notificationsProvider.notifier).loadNotifications();
      }

      // Show local notification for foreground visibility if available
      if (notification != null && type != 'incoming_call') {
        // Suppress notification if user is already on the relevant chat page
        final activeConvId = _ref.read(activeConversationIdProvider);
        final msgConvId =
            int.tryParse(message.data['conversation_id']?.toString() ?? '');

        if (type == 'message' &&
            activeConvId != null &&
            activeConvId == msgConvId) {
          log('Suppressing duplicate notification for active chat: $msgConvId');
          return;
        }

        final localId = message.hashCode;
        LocalNotificationService.showNotification(
          id: localId,
          title: notification.title ?? 'Wavemart',
          body: notification.body ?? '',
          payload: type == 'message'
              ? message.data['conversation_id']?.toString()
              : null,
        );

        final notifIdStr = message.data['notification_id'];
        if (notifIdStr != null) {
          final backendId = int.tryParse(notifIdStr.toString());
          if (backendId != null) {
            _notificationIdMap[backendId] = localId;
          }
        }
      }
    });

    // 7. Handle messages when app is in background but opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from notification!');
      final type = message.data['type'];

      if (type == 'incoming_call') {
        _handleIncomingCall(message.data);
      } else if (type == 'message') {
        _ref.read(unreadMessagesCountProvider.notifier).refresh();
        _navigateFromData(message.data);
      } else {
        _ref.invalidate(unreadCountProvider);
        _navigateFromData(message.data);
      }
    });
  }

  void _debounceRefreshConversations() {
    _convRefreshDebounce?.cancel();
    _convRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
      _ref.read(conversationsProvider.notifier).refreshConversations();
    });
  }

  void _debounceRefreshBadges() {
    _badgeRefreshDebounce?.cancel();
    _badgeRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
      _ref.read(unreadMessagesCountProvider.notifier).refresh();
    });
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (type == 'incoming_call') {
      _handleIncomingCall(data);
      return;
    }

    final convIdStr = data['conversation_id'] ?? data['chat_id'];
    if (convIdStr != null) {
      final convId = int.tryParse(convIdStr.toString());
      if (convId != null) {
        goRouter.push('/chat/$convId');
        return;
      }
    }

    final listingIdStr = data['listing_id'];
    if (listingIdStr != null) {
      final id = int.tryParse(listingIdStr.toString());
      if (id != null) {
        goRouter.push('/listings/$id');
        return;
      }
    }

    final orderIdStr = data['order_id'];
    if (orderIdStr != null) {
      final id = int.tryParse(orderIdStr.toString());
      if (id != null) {
        goRouter.push('/orders/$id');
        return;
      }
    }

    final actionUrl = data['action_url']?.toString();
    if (actionUrl != null && actionUrl.startsWith('/')) {
      goRouter.push(actionUrl);
    }
  }

  Future<void> _updateToken() async {
    try {
      await _fcm.deleteToken();
      String? token = await _fcm.getToken();
      log('FCM Token (fresh): $token');
      if (token != null) {
        await _ref.read(fcmApiServiceProvider).registerToken(token);
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    _ref.read(incomingCallProvider.notifier).setIncomingCall(IncomingCall(
          conferenceId: int.tryParse(data['conference_id'].toString()) ?? 0,
          callerName: data['caller_name'] ?? 'Unknown',
          callerAvatar: data['caller_avatar'],
          callerInitials: data['caller_initials'],
          listingTitle: data['listing_title'],
          isVideo: data['is_video'] == '1' ||
              data['is_video'] == true ||
              data['is_video'] == 'true',
        ));
  }

  /// Clean up FCM on logout — delete token so logged-out user stops receiving pushes
  Future<void> cleanup() async {
    try {
      _convRefreshDebounce?.cancel();
      _badgeRefreshDebounce?.cancel();
      await _fcm.deleteToken();
      log('FCM token deleted on logout');
    } catch (e) {
      log('Error deleting FCM token: $e');
    }
  }

  static void dismissShadeNotification(int backendId) {
    final localId = _notificationIdMap.remove(backendId);
    if (localId != null) {
      LocalNotificationService.cancel(localId);
    }
  }

  static void dismissAllShadeNotifications() {
    LocalNotificationService.cancelAll();
    _notificationIdMap.clear();
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));
