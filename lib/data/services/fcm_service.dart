import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fcm_api_service.dart';
import '../../presentation/providers/app_providers.dart';
import '../../core/network/local_notification_service.dart';

final fcmApiServiceProvider = Provider<FcmApiService>((ref) => FcmApiService());

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Ref _ref;

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

    // 2. Get the token
    String? token = await _fcm.getToken();
    log('FCM Token: $token');
    if (token != null) {
      await _ref.read(fcmApiServiceProvider).registerToken(token);
    }

    // 3. Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      final type = message.data['type'];
      final notification = message.notification;
      
      // Update Providers
      if (type == 'incoming_call') {
        _handleIncomingCall(message.data);
      } else if (type == 'message') {
        _ref.invalidate(unreadMessagesCountProvider);
      } else {
        _ref.invalidate(unreadCountProvider);
      }

      // Show local notification for foreground visibility if available
      if (notification != null && type != 'incoming_call') {
        LocalNotificationService.showNotification(
          id: message.hashCode,
          title: notification.title ?? 'WaveMart',
          body: notification.body ?? '',
        );
      }
    });

    // 4. Handle messages when app is in background but opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from notification!');
      final type = message.data['type'];
      
      if (type == 'incoming_call') {
        _handleIncomingCall(message.data);
      } else {
        // Invalidate to show latest data when navigated back
        _ref.invalidate(unreadCountProvider);
        _ref.invalidate(unreadMessagesCountProvider);
      }
    });
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    // This manually updates the incomingCallProvider
    // which triggers the overlay in main.dart
    _ref.read(incomingCallProvider.notifier).setIncomingCall(IncomingCall(
      conferenceId: int.tryParse(data['conference_id'].toString()) ?? 0,
      callerName: data['caller_name'] ?? 'Unknown',
      callerAvatar: data['caller_avatar'],
      callerInitials: data['caller_initials'],
      listingTitle: data['listing_title'],
    ));
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));
