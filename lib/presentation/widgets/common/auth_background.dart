import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WaveAuthBackground extends StatelessWidget {
  final Widget? child;

  const WaveAuthBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary800,
            AppColors.primary900,
            AppColors.primary950,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Top-right decorative orb
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary500.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Bottom-left decorative orb
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary700.withValues(alpha: 0.10),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
