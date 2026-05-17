import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WaveAuthBackground extends StatelessWidget {
  final Widget? child;

  const WaveAuthBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary800,
                  AppColors.primary900,
                  AppColors.primary950,
                ]
              : [
                  AppColors.primary50,
                  AppColors.primary100,
                  AppColors.primary200,
                ],
        ),
      ),
      child: child,
    );
  }
}
