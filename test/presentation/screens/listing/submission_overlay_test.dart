import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/constants/app_colors.dart';
import 'package:wavemart/core/theme/app_theme.dart';
import 'package:wavemart/l10n/app_localizations.dart';
import 'package:wavemart/presentation/screens/listing/widgets/submission_overlay.dart';

void main() {
  Widget wrap(Widget child, ThemeData theme) {
    return MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('success actions are forwarded to the caller', (tester) async {
    final actions = <SubmissionDismissAction?>[];

    await tester.pumpWidget(
      wrap(
        SubmissionOverlay(
          state: SubmissionState.success(message: 'Submitted'),
          onDismiss: actions.add,
        ),
        AppTheme.lightTheme,
      ),
    );

    await tester.tap(find.text('View My Listings'));
    await tester.tap(find.text('Create Another'));

    expect(actions, [
      SubmissionDismissAction.viewListings,
      SubmissionDismissAction.createAnother,
    ]);
  });

  testWidgets('error actions are forwarded and retry stays interactive',
      (tester) async {
    final actions = <SubmissionDismissAction?>[];
    var retried = false;

    await tester.pumpWidget(
      wrap(
        SubmissionOverlay(
          state: SubmissionState.error(
            message: 'Failed',
            canSaveDraft: true,
            onRetry: () => retried = true,
          ),
          onDismiss: actions.add,
        ),
        AppTheme.lightTheme,
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.tap(find.text('Save Draft & Exit'));
    await tester.tap(find.text('Go Back'));

    expect(retried, isTrue);
    expect(actions, [
      SubmissionDismissAction.saveDraftAndExit,
      SubmissionDismissAction.goBack,
    ]);
  });

  testWidgets('non-draft flows show Exit instead of Save Draft', (tester) async {
    await tester.pumpWidget(
      wrap(
        SubmissionOverlay(
          state: SubmissionState.error(message: 'Failed'),
          onDismiss: (_) {},
        ),
        AppTheme.lightTheme,
      ),
    );

    expect(find.text('Exit'), findsOneWidget);
    expect(find.text('Save Draft & Exit'), findsNothing);
  });

  testWidgets('loader adapts to light and dark themes', (tester) async {
    Future<void> pump(ThemeData theme) {
      return tester.pumpWidget(
        wrap(
          SubmissionOverlay(
            state: SubmissionState.submitting(
              phase: SubmissionPhase.uploading,
              label: 'Uploading',
            ),
          ),
          theme,
        ),
      );
    }

    await pump(AppTheme.lightTheme);
    var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    var spinner =
        tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    var statusBar = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );

    expect(scaffold.backgroundColor, AppColors.stone100);
    expect(spinner.valueColor!.value, AppColors.primary900);
    expect(statusBar.value.statusBarIconBrightness, Brightness.dark);

    await pump(AppTheme.darkTheme);
    scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    spinner = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    statusBar = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );

    expect(scaffold.backgroundColor, const Color(0xFF080C14));
    expect(spinner.valueColor!.value, AppColors.accent500);
    expect(statusBar.value.statusBarIconBrightness, Brightness.light);
  });

  testWidgets('theme switch applies while the overlay is mounted',
      (tester) async {
    // Regression guard: the overlay must not keep the previous theme's
    // colors while the route is open.
    await tester.pumpWidget(
      wrap(
        SubmissionOverlay(
          state: SubmissionState.success(message: 'Submitted'),
        ),
        AppTheme.lightTheme,
      ),
    );

    await tester.pumpWidget(
      wrap(
        SubmissionOverlay(
          state: SubmissionState.success(message: 'Submitted'),
        ),
        AppTheme.darkTheme,
      ),
    );
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF080C14));
  });
}
