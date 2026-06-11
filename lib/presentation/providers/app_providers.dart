import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/services/conference_service.dart';
import 'auth_provider.dart';
import 'notification_providers.dart';
import 'message_providers.dart';
import 'settings_providers.dart';
import 'payment_providers.dart';

export 'auth_providers.dart';
export 'listing_provider.dart';
export 'listing_providers.dart';
export 'order_providers.dart';
export 'payment_providers.dart';
export 'message_providers.dart';
export 'notification_providers.dart';
export 'settings_providers.dart';

/// Global Navigator Key for context-less navigation (useful for overlays)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global Route Observer for navigation tracking
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

/// Selected Tab Provider for MainNavigationShell
final selectedTabProvider = StateProvider<int>((ref) => 0);

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

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final conferenceServiceProvider = Provider<ConferenceService>((ref) => ConferenceService());
