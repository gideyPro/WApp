import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/theme_provider.dart';
import '../../screens/help/help_center_screen.dart';
import '../../../../l10n/app_localizations.dart';

class AuthTopBar extends ConsumerWidget {
  const AuthTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 180),
          onSelected: (value) {
            switch (value) {
              case 'language':
                _showLanguageSelectionDialog(context, ref);
                break;
              case 'help':
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                );
                break;
              case 'theme':
                ref.read(themeModeProvider.notifier).toggle();
                break;
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'language',
              child: Row(
                children: [
                  const Icon(Icons.language, size: 18),
                  const SizedBox(width: 12),
                  Text(l10n.settingsLanguage),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  const Icon(Icons.help_outline, size: 18),
                  const SizedBox(width: 12),
                  Text(l10n.profileHelp),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'theme',
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.settingsDarkMode),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLanguageSelectionDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.languageTitle, style: AppTextStyles.title),
            const SizedBox(height: 24),
            _buildLanguageOption(context, ref, languageCode: 'en', languageName: l10n.languageEnglish, currentLocale: currentLocale),
            _buildLanguageOption(context, ref, languageCode: 'am', languageName: l10n.languageAmharic, currentLocale: currentLocale),
            _buildLanguageOption(context, ref, languageCode: 'ti', languageName: l10n.languageTigrinya, currentLocale: currentLocale),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, {required String languageCode, required String languageName, required String currentLocale}) {
    final isSelected = currentLocale == languageCode;
    return ListTile(
      onTap: () async {
        await ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
        if (context.mounted) Navigator.pop(context);
      },
      leading: isSelected ? const Icon(Icons.check_circle, color: AppColors.accent500) : const Icon(Icons.radio_button_unchecked),
      title: Text(languageName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
    );
  }
}
