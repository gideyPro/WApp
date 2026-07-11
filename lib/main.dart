import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/version_provider.dart';
import 'presentation/screens/calls/incoming_call_screen.dart';
import 'l10n/app_localizations.dart';
import 'core/constants/app_colors.dart';
import 'core/network/local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'data/services/fcm_service.dart';
import 'presentation/widgets/common/wave_connectivity_banner.dart';
import 'core/router/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (it might already be initialized by the system)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  log("Handling a background message: ${message.messageId}");
  // Note: Most logic for background messages (like showing a notification) 
  // is handled automatically by Firebase if the payload contains a 'notification' block.
  // For 'data' only messages, you would handle them here.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    log('Firebase initialization failed: $e. Make sure to run flutterfire configure.');
  }

  // Initialize Notifications
  await LocalNotificationService.initialize();

  // Initialize Intl
  await initializeDateFormatting();

  // Initialize Hive for draft persistence
  await Hive.initFlutter();
  await Hive.openBox('listing_drafts');
  await Hive.openBox('app_preferences');

  // Fonts are bundled locally in assets/fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // Configure video cache: max 10 cached videos
  CachedVideoPlayerPlus.cacheManager = cache.CacheManager(
    cache.Config(
      'libCachedVideoPlayerPlusData',
      maxNrOfCacheObjects: 10,
    ),
  );

  // Global error handler for crash logging
  FlutterError.onError = (details) {
    log('Flutter Error: ${details.exceptionAsString()}', name: 'Wavemart');
    if (kReleaseMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log('Platform Error: $error\nStack: $stack', name: 'Wavemart');
    return true;
  };

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Wrap with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: WavemartApp(),
    ),
  );
}

class WavemartApp extends ConsumerStatefulWidget {
  const WavemartApp({super.key});

  @override
  ConsumerState<WavemartApp> createState() => _WavemartAppState();
}

class _WavemartAppState extends ConsumerState<WavemartApp> {
  bool _fcmStarted = false;
  bool _nonBlockingDialogShown = false;
  Timer? _incomingCallTimer;

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final authState = ref.watch(authStateProvider);
    final incomingCall = ref.watch(incomingCallProvider);
    final themeMode = ref.watch(themeModeProvider);
    final versionState = ref.watch(versionProvider);
    
    // Activate lifecycle listener for real-time sync on app resume
    ref.watch(appLifecycleProvider);

    // Start FCM only once when authenticated
    if (authState.isAuthenticated && !_fcmStarted) {
      _fcmStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(fcmServiceProvider).initialize();
      });
    } else if (!authState.isAuthenticated) {
      _fcmStarted = false;
    }

    // Poll for incoming calls when authenticated (backup for delayed FCM)
    if (authState.isAuthenticated) {
      _incomingCallTimer ??= Timer.periodic(
        const Duration(seconds: 15),
        (_) => _checkIncomingCalls(),
      );
    } else {
      _incomingCallTimer?.cancel();
      _incomingCallTimer = null;
    }

    // Show non-blocking update dialog once per app lifecycle
    if (versionState.updateType == UpdateType.nonBlocking && !_nonBlockingDialogShown) {
      _nonBlockingDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog(context, versionState);
      });
    }

    return MaterialApp.router(
      title: 'Wavemart',
      debugShowCheckedModeBanner: false,
      theme: getThemeData(themeMode),
      routerConfig: goRouter,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            child,
            // Global Connectivity Banner
            const WaveConnectivityBanner(),
            if (authState.isAuthenticated && incomingCall != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: IncomingCallScreen(
                    conferenceId: incomingCall.conferenceId,
                    callerName: incomingCall.callerName,
                    callerAvatar: incomingCall.callerAvatar,
                    callerInitials: incomingCall.callerInitials,
                    listingTitle: incomingCall.listingTitle,
                    isVideo: incomingCall.isVideo,
                  ),
                ),
              ),
            // Blocking update overlay
            if (versionState.updateType == UpdateType.blocking)
              Positioned.fill(
                child: _BlockingUpdateOverlay(state: versionState),
              ),
          ],
        );
      },
      locale: localeState.locale ?? const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        _TigrinyaFallbackDelegate<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
        _TigrinyaFallbackDelegate<WidgetsLocalizations>(GlobalWidgetsLocalizations.delegate),
        _TigrinyaFallbackDelegate<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('ti'),
      ],
    );
  }

  @override
  void dispose() {
    _incomingCallTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkIncomingCalls() async {
    if (ref.read(incomingCallProvider) != null) return;

    try {
      final result = await ref.read(conferenceServiceProvider).checkIncomingCall();
      if (result.hasIncoming && result.callData != null) {
        final data = result.callData!;
        ref.read(incomingCallProvider.notifier).setIncomingCall(IncomingCall(
          conferenceId: data['conference_id'] as int,
          callerName: data['caller_name'] as String? ?? 'Unknown',
          callerAvatar: data['caller_avatar']?.toString(),
          callerInitials: data['caller_initials']?.toString(),
          listingTitle: data['listing_title']?.toString(),
          isVideo: data['is_video'] == true,
        ));
      }
    } catch (_) {}
  }

  void _showUpdateDialog(BuildContext context, VersionState state) {
    final isBlocking = state.updateType == UpdateType.blocking;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: !isBlocking,
      builder: (ctx) => PopScope(
        canPop: !isBlocking,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
          title: Row(
            children: [
              Icon(isBlocking ? Icons.warning_amber_rounded : Icons.system_update,
                   color: AppColors.amber, size: 28),
              const SizedBox(width: 8),
              Text(isBlocking ? l10n.updateRequired : l10n.updateAvailable),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBlocking
                    ? l10n.updateBlockingMessage
                    : l10n.updateAvailableMessage(
                        state.latestVersion.isNotEmpty ? ' (${state.latestVersion})' : '',
                      ),
              ),
              if (state.whatsNew.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.updateWhatsNew, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(state.whatsNew, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
              ],
              if (state.latestVersion.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Text(l10n.updateVersionLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(state.latestVersion),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            if (!isBlocking)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.updateLater),
              ),
            ElevatedButton(
              onPressed: () => _openUpdateUrl(state.updateUrl, ctx),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(l10n.updateNow),
            ),
          ],
        ),
      ),
    );
  }

  void _openUpdateUrl(String url, BuildContext ctx) async {
    if (url.isEmpty) return;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

class _BlockingUpdateOverlay extends StatelessWidget {
  final VersionState state;

  const _BlockingUpdateOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update, size: 64, color: AppColors.amber),
                const SizedBox(height: 24),
                Text(
                  'Update Required',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  'This version of the app is no longer supported. Please update to continue using Wavemart.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                if (state.whatsNew.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text("What's New", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(state.whatsNew, textAlign: TextAlign.center,
                       style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                ],
                if (state.latestVersion.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Version: ${state.latestVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (state.updateUrl.isEmpty) return;
                      if (await canLaunchUrl(Uri.parse(state.updateUrl))) {
                        await launchUrl(Uri.parse(state.updateUrl), mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Update Now', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TigrinyaFallbackDelegate<T> extends LocalizationsDelegate<T> {
  final LocalizationsDelegate<T> source;
  const _TigrinyaFallbackDelegate(this.source);

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<T> load(Locale locale) => source.load(const Locale('am'));

  @override
  bool shouldReload(_TigrinyaFallbackDelegate<T> old) => false;
}
