import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/theme/app_theme.dart';
import 'package:wavemart/data/models/listing.dart';
import 'package:wavemart/l10n/app_localizations.dart';
import 'package:wavemart/presentation/screens/jobs/widgets/job_listing_card.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  Listing createSampleJob({
    String title = 'Senior Flutter Developer',
    String company = 'Telebirr Tech Hub',
    String? category = 'it_software',
    String? type = 'full_time',
    String? salaryType = 'range',
    double? salaryMin = 35000,
    double? salaryMax = 55000,
    int? positions = 3,
    DateTime? deadline,
  }) {
    return Listing(
      id: 101,
      jobTitle: title,
      jobCompanyName: company,
      jobCategory: category,
      jobType: type,
      jobSalaryType: salaryType,
      jobSalaryMin: salaryMin,
      jobSalaryMax: salaryMax,
      jobSalaryCurrency: 'ETB',
      jobPositionsCount: positions,
      jobDeadline: deadline,
      propertyType: PropertyType.job,
      listingType: ListingType.rental,
      status: ListingStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  testWidgets('JobListingCard displays title, company, monogram, and salary range', (tester) async {
    final job = createSampleJob();
    bool favoriteTapped = false;

    await tester.pumpWidget(
      buildTestableWidget(
        JobListingCard(
          job: job,
          onFavorite: () => favoriteTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and company
    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(find.text('Telebirr Tech Hub'), findsOneWidget);

    // Verify company monogram initials ("TT" for Telebirr Tech)
    expect(find.text('TT'), findsOneWidget);

    // Verify prominent salary spotlight
    expect(find.textContaining('ETB 35,000 – 55,000'), findsOneWidget);
    expect(find.text('/ mo'), findsOneWidget);

    // Verify metadata pills
    expect(find.text('Full Time'), findsOneWidget);
    expect(find.text('3 Positions'), findsOneWidget);

    // Verify favorite heart button tap
    final favoriteFinder = find.byIcon(Icons.favorite_border);
    expect(favoriteFinder, findsOneWidget);
    await tester.tap(favoriteFinder);
    expect(favoriteTapped, isTrue);
  });

  testWidgets('JobListingCard renders per agreement when salary is agreement', (tester) async {
    final job = createSampleJob(
      salaryType: 'per_agreement',
      salaryMin: null,
      salaryMax: null,
    );

    await tester.pumpWidget(
      buildTestableWidget(
        JobListingCard(job: job),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Per Agreement'), findsOneWidget);
  });

  testWidgets('JobListingCard displays urgency badge for close deadline', (tester) async {
    final job = createSampleJob(
      deadline: DateTime.now().add(const Duration(days: 4)),
    );

    await tester.pumpWidget(
      buildTestableWidget(
        JobListingCard(job: job),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('days left'), findsOneWidget);
  });
}
