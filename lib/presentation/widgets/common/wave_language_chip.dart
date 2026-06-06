import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';

class WaveLanguageChip extends ConsumerWidget {
  const WaveLanguageChip({super.key});

  static const _locales = [
    {'code': 'en', 'label': 'EN'},
    {'code': 'am', 'label': 'AM'},
    {'code': 'ti', 'label': 'TI'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale =
        ref.watch(localeProvider).locale?.languageCode ?? 'en';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: BackdropFilter(
        filter: const ColorFilter.mode(Color(0x33000000), BlendMode.srcOver),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _locales.map((lang) {
              final isActive = currentLocale == lang['code'];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .setLocale(Locale(lang['code']!)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.95)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    lang['label']!,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.primary900
                          : Colors.white.withValues(alpha: 0.85),
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
