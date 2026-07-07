import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/app_providers.dart';
import '../constants/app_colors.dart';
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

Page<void> _buildPageTransition<T>({
  required LocalKey key,
  required Widget child,
}) =>
    CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.35, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: child,
        ),
      ),
    );

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
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const OtpLoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const RegistrationScreen(),
      ),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const MainNavigationShell(),
      ),
    ),
    GoRoute(
      path: '/listings/create',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const CreateListingScreen(),
      ),
    ),
    GoRoute(
      path: '/listings/:id',
      pageBuilder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _buildPageTransition(
            key: state.pageKey,
            child: const _InvalidRouteScreen(),
          );
        }
        return _buildPageTransition(
          key: state.pageKey,
          child: ListingDetailScreen(listingId: id),
        );
      },
    ),
    GoRoute(
      path: '/listings/:id/edit',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: EditListingScreen(listing: state.extra as dynamic),
      ),
    ),
    GoRoute(
      path: '/my-listings',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const MyListingsScreen(),
      ),
    ),
    GoRoute(
      path: '/my-interests',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const MyInterestsScreen(),
      ),
    ),
    GoRoute(
      path: '/favorites',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: '/messages',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const MessagesScreen(),
      ),
    ),
    GoRoute(
      path: '/chat/:id',
      pageBuilder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _buildPageTransition(
            key: state.pageKey,
            child: const _InvalidRouteScreen(),
          );
        }
        return _buildPageTransition(
          key: state.pageKey,
          child: ChatScreen(
            conversationId: id,
            conversation: state.extra as dynamic,
          ),
        );
      },
    ),
    GoRoute(
      path: '/orders/create',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const CreateOrderScreen(),
      ),
    ),
    GoRoute(
      path: '/orders/:id',
      pageBuilder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _buildPageTransition(
            key: state.pageKey,
            child: const _InvalidRouteScreen(),
          );
        }
        return _buildPageTransition(
          key: state.pageKey,
          child: OrderDetailsScreen(orderId: id),
        );
      },
    ),
    GoRoute(
      path: '/payments',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const PaymentHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/payments/:id',
      pageBuilder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _buildPageTransition(
            key: state.pageKey,
            child: const _InvalidRouteScreen(),
          );
        }
        return _buildPageTransition(
          key: state.pageKey,
          child: PaymentDetailScreen(paymentId: id),
        );
      },
    ),
    GoRoute(
      path: '/subscriptions',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const SubscriptionPlansScreen(),
      ),
    ),
    GoRoute(
      path: '/kyc',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const KycVerificationScreen(),
      ),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: const HelpCenterScreen(),
      ),
    ),
    GoRoute(
      path: '/video',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: FullScreenVideoScreen(videoUrl: state.extra as String),
      ),
    ),
    GoRoute(
      path: '/call/:id',
      pageBuilder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _buildPageTransition(
            key: state.pageKey,
            child: const _InvalidRouteScreen(),
          );
        }
        final extra = state.extra as Map<String, dynamic>?;
        return _buildPageTransition(
          key: state.pageKey,
          child: WebViewJitsiScreen(
            conferenceId: id,
            jitsiUrl: extra?['url'] as String?,
            jitsiToken: extra?['token'] as String?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/video-preview',
      pageBuilder: (_, state) => _buildPageTransition(
        key: state.pageKey,
        child: VideoPlayerPreviewScreen(filePath: state.extra as String),
      ),
    ),
  ],
);

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 64, color: AppColors.stone400),
            const SizedBox(height: 16),
            Text(
              'Invalid route',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
