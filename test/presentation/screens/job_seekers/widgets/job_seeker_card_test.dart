import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/theme/app_theme.dart';
import 'package:wavemart/data/models/job_requirement_item.dart';
import 'package:wavemart/data/models/job_seeker_profile.dart';
import 'package:wavemart/l10n/app_localizations.dart';
import 'package:wavemart/presentation/screens/job_seekers/widgets/job_seeker_card.dart';

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

  JobSeekerProfile createSampleProfile({
    String fullName = 'Dawit Bekele',
    String title = 'Senior Flutter Developer',
    String category = 'it_software',
    String educationLevel = 'bachelors',
    double experienceYears = 5.0,
    String? cv = 'resumes/dawit_cv.pdf',
    String? description =
        'Experienced mobile engineer specializing in Flutter, Dart & Riverpod.',
    String? location = 'Addis Ababa, Bole',
    bool isVerified = true,
  }) {
    return JobSeekerProfile(
      id: 42,
      userId: 10,
      fullName: fullName,
      professionalTitle: title,
      jobCategory: category,
      educationLevel: educationLevel,
      experiences: [
        ExperienceItem(
          jobTitle: 'Flutter Dev',
          company: 'Acme',
          years: experienceYears,
        ),
      ],
      cv: cv,
      description: description,
      location: location,
      isVerified: isVerified,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  testWidgets('JobSeekerCard displays candidate identity, monogram, verified badge, and chips', (tester) async {
    final profile = createSampleProfile();
    bool cardTapped = false;
    bool favoriteTapped = false;

    await tester.pumpWidget(
      buildTestableWidget(
        JobSeekerCard(
          profile: profile,
          onTap: () => cardTapped = true,
          onFavorite: () => favoriteTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify candidate name and professional title
    expect(find.text('Dawit Bekele'), findsOneWidget);
    expect(find.text('Senior Flutter Developer'), findsOneWidget);

    // Verify initials monogram ("DB")
    expect(find.text('DB'), findsOneWidget);

    // Verify verified badge text
    expect(find.text('VERIFIED'), findsOneWidget);

    // Verify qualification chips
    expect(find.text('5+ yrs exp'), findsOneWidget);
    expect(find.text('Bachelors Degree'), findsOneWidget);
    expect(find.text('IT & Software'), findsOneWidget);
    expect(find.text('CV Attached'), findsOneWidget);

    // Verify bio preview
    expect(
      find.text('"Experienced mobile engineer specializing in Flutter, Dart & Riverpod."'),
      findsOneWidget,
    );

    // Verify footer location & availability badge
    expect(find.textContaining('Addis Ababa, Bole'), findsOneWidget);
    expect(find.text('Available for Hire'), findsOneWidget);

    // Verify favorite heart button tap
    final heartFinder = find.byIcon(Icons.favorite_border);
    expect(heartFinder, findsOneWidget);
    await tester.tap(heartFinder);
    expect(favoriteTapped, isTrue);

    // Verify card tap
    await tester.tap(find.text('Dawit Bekele'));
    expect(cardTapped, isTrue);
  });

  testWidgets('JobSeekerCard renders cleanly when optional fields are omitted', (tester) async {
    final profile = JobSeekerProfile(
      id: 99,
      userId: 12,
      fullName: 'Abebe Kebede',
      professionalTitle: 'Accountant',
      educationLevel: 'none',
      isPublic: true,
      isVerified: false,
    );

    await tester.pumpWidget(
      buildTestableWidget(
        JobSeekerCard(
          profile: profile,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Abebe Kebede'), findsOneWidget);
    expect(find.text('Accountant'), findsOneWidget);
    expect(find.text('AK'), findsOneWidget);
    expect(find.text('VERIFIED'), findsNothing);
    expect(find.text('CV Attached'), findsNothing);
    expect(find.text('Available for Hire'), findsOneWidget);
  });

  testWidgets('JobSeekerCardSkeleton renders placeholder shimmer', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        const JobSeekerCardSkeleton(),
      ),
    );
    expect(find.byType(JobSeekerCardSkeleton), findsOneWidget);
  });
}
