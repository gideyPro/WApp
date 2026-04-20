import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/calls/incoming_call_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for draft persistence
  await Hive.initFlutter();
  await Hive.openBox('listing_drafts');
  await Hive.openBox('app_preferences');

  // Disable google_fonts runtime fetching - fonts are bundled locally
  GoogleFonts.config.allowRuntimeFetching = false;

  // Global error handler for crash logging
  FlutterError.onError = (details) {
    log('Flutter Error: ${details.exceptionAsString()}', name: 'WaveMart');
    if (kReleaseMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log('Platform Error: $error\nStack: $stack', name: 'WaveMart');
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
      child: WaveMartApp(),
    ),
  );
}

class WaveMartApp extends ConsumerWidget {
  const WaveMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final authState = ref.watch(authStateProvider);
    final incomingCall = ref.watch(incomingCallProvider);

    if (authState.isAuthenticated) {
      ref.read(incomingCallProvider.notifier).startPolling();
    }

    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            child,
            if (authState.isAuthenticated && incomingCall != null)
              IncomingCallScreen(
                conferenceId: incomingCall.conferenceId,
                callerName: incomingCall.callerName,
                callerAvatar: incomingCall.callerAvatar,
                callerInitials: incomingCall.callerInitials,
                listingTitle: incomingCall.listingTitle,
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
        _TigrinyaMaterialLocalizationsDelegate(),
        _TigrinyaWidgetsLocalizationsDelegate(),
        _TigrinyaCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('ti'),
      ],
    );
  }
}

/// Fallback delegate to provide Amharic Material localizations for Tigrinya
class _TigrinyaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _TigrinyaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('am'));

  @override
  bool shouldReload(_TigrinyaMaterialLocalizationsDelegate old) => false;
}

/// Fallback delegate to provide Amharic Widgets localizations for Tigrinya
class _TigrinyaWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _TigrinyaWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('am'));

  @override
  bool shouldReload(_TigrinyaWidgetsLocalizationsDelegate old) => false;
}

/// Fallback delegate to provide Amharic Cupertino localizations for Tigrinya
class _TigrinyaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _TigrinyaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('am'));

  @override
  bool shouldReload(_TigrinyaCupertinoLocalizationsDelegate old) => false;
}
