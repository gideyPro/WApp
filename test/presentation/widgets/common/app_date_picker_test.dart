import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/theme/app_theme.dart';
import 'package:wavemart/presentation/widgets/common/app_date_field.dart';
import 'package:wavemart/presentation/widgets/common/app_date_picker.dart';

void main() {
  testWidgets('AppDateField displays dual formatted date and opens picker', (tester) async {
    final testDate = DateTime(2024, 10, 29); // Tikimt 19, 2017
    DateTime? selectedDate = testDate;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('am'),
        supportedLocales: const [Locale('am'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppDateField(
              label: 'Job Deadline',
              value: selectedDate,
              onChanged: (newVal) => setState(() => selectedDate = newVal),
            ),
          ),
        ),
      ),
    );

    // Verify formatted date text appears
    expect(find.text('Job Deadline'), findsOneWidget);
    expect(find.textContaining('ጥቅምት 19, 2017'), findsOneWidget);
    expect(find.textContaining('2024-10-29'), findsOneWidget);

    // Tap on the field to open AppDatePicker
    await tester.tap(find.byType(AppDateField));
    await tester.pumpAndSettle();

    // Verify dialog with toggle options appears
    expect(find.text('ኢትዮጵያ'), findsOneWidget);
    expect(find.text('GC'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Still selected
    expect(selectedDate, equals(testDate));

    // Clear date using clear icon
    await tester.tap(find.byTooltip('Clear date'));
    await tester.pump();
    expect(selectedDate, isNull);
  });

  testWidgets('AppDatePicker toggles between Ethiopian and Gregorian modes', (tester) async {
    final testDate = DateTime(2024, 10, 29);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('am'),
        supportedLocales: const [Locale('am'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppDatePicker.show(
              context: context,
              initialDate: testDate,
            ),
            child: const Text('Open Picker'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    // Initially in Ethiopian mode
    expect(find.textContaining('ጥቅምት 19, 2017'), findsWidgets);

    // Switch to Gregorian mode
    await tester.tap(find.text('GC'));
    await tester.pumpAndSettle();

    // Gregorian days/month should be visible
    expect(find.textContaining('October 2024'), findsOneWidget);

    // Switch back to Ethiopian mode
    await tester.tap(find.text('ኢትዮጵያ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ጥቅምት 2017'), findsOneWidget);
  });
}
