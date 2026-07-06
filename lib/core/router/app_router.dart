import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/app_providers.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/otp_login_screen.dart';
import '../../presentation/screens/auth/registration_screen.dart';
import '../../presentation/screens/navigation/main_navigation_shell.dart';
import '../../presentation/screens/orders/create_order_screen.dart';
import '../../presentation/screens/orders/order_details_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/interests/my_interests_screen.dart';
import '../../presentation/screens/messages/messages_screen.dart';
import '../../presentation/screens/listing/create_listing_screen.dart';
import '../../presentation/screens/listing/edit_listing_screen.dart';
import '../../presentation/screens/listing/listing_detail_screen.dart';
import '../../presentation/screens/listing/my_listings_screen.dart';
import '../../presentation/screens/payments/payment_history_screen.dart';
import '../../presentation/screens/payments/payment_detail_screen.dart';
import '../../presentation/screens/subscriptions/subscription_plans_screen.dart';
import '../../presentation/screens/kyc/kyc_verification_screen.dart';
import '../../presentation/screens/help/help_center_screen.dart';
import '../../presentation/screens/calls/webview_jitsi_screen.dart';
import '../../presentation/screens/video/full_screen_video_screen.dart';
import '../../presentation/screens/listing/widgets/listing_step3_media.dart';

final goRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [routeObserver],
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OtpLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const MainNavigationShell(),
    ),
    GoRoute(
      path: '/listings/create',
      builder: (_, __) => const CreateListingScreen(),
    ),
    GoRoute(
      path: '/listings/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ListingDetailScreen(listingId: id);
      },
    ),
    GoRoute(
      path: '/listings/:id/edit',
      builder: (_, state) {
        final listing = state.extra as dynamic;
        return EditListingScreen(listing: listing);
      },
    ),
    GoRoute(
      path: '/my-listings',
      builder: (_, __) => const MyListingsScreen(),
    ),
    GoRoute(
      path: '/my-interests',
      builder: (_, __) => const MyInterestsScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (_, __) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/messages',
      builder: (_, __) => const MessagesScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        final conv = state.extra as dynamic;
        return ChatScreen(conversationId: id, conversation: conv);
      },
    ),
    GoRoute(
      path: '/orders/create',
      builder: (_, __) => const CreateOrderScreen(),
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/payments',
      builder: (_, __) => const PaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/payments/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PaymentDetailScreen(paymentId: id);
      },
    ),
    GoRoute(
      path: '/subscriptions',
      builder: (_, __) => const SubscriptionPlansScreen(),
    ),
    GoRoute(
      path: '/kyc',
      builder: (_, __) => const KycVerificationScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (_, __) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/video',
      builder: (_, state) {
        final url = state.extra as String;
        return FullScreenVideoScreen(videoUrl: url);
      },
    ),
    GoRoute(
      path: '/call/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        final extra = state.extra as Map<String, dynamic>?;
        return WebViewJitsiScreen(
          conferenceId: id,
          jitsiUrl: extra?['url'] as String?,
          jitsiToken: extra?['token'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/video-preview',
      builder: (_, state) {
        final filePath = state.extra as String;
        return VideoPlayerPreviewScreen(filePath: filePath);
      },
    ),
  ],
);
