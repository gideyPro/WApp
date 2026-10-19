import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/constants/app_colors.dart';
import 'package:wavemart/core/theme/app_theme.dart';

/// Regression tests for theme-aware text colors.
///
/// A colorless `titleTextStyle`/`subtitleTextStyle` in `listTileTheme`
/// shadows the Material 3 defaults and leaves ListTile text with no color —
/// which rendered white on white cards in light mode (see job seeker
/// profile edit form: education/experience entry rows).
void main() {
  group('AppTheme component text styles carry explicit colors', () {
    test('light theme', () {
      final tile = AppTheme.lightTheme.listTileTheme;
      expect(tile.titleTextStyle?.color, AppColors.stone900);
      expect(tile.subtitleTextStyle?.color, AppColors.stone600);
      expect(
        AppTheme.lightTheme.chipTheme.labelStyle?.color,
        AppColors.stone900,
      );
    });

    test('dark theme', () {
      final tile = AppTheme.darkTheme.listTileTheme;
      expect(tile.titleTextStyle?.color, Colors.white);
      expect(tile.subtitleTextStyle?.color, AppColors.primary300);
      expect(AppTheme.darkTheme.chipTheme.labelStyle?.color, Colors.white);
    });
  });

  group('ListTile renders with explicit text colors', () {
    Future<Color?> renderedTitleColor(WidgetTester tester, ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Card(
              child: ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Entry title'),
                subtitle: const Text('Entry subtitle'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );
      return tester
          .renderObject<RenderParagraph>(find.text('Entry title'))
          .text
          .style
          ?.color;
    }

    testWidgets('light: title is dark on the white card', (tester) async {
      expect(
        await renderedTitleColor(tester, AppTheme.lightTheme),
        AppColors.stone900,
      );
    });

    testWidgets('dark: title is light on the navy card', (tester) async {
      expect(
        await renderedTitleColor(tester, AppTheme.darkTheme),
        Colors.white,
      );
    });
  });
}
