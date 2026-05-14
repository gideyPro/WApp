import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Premium consistent background for Auth screens (Splash, Login, Register)
class WaveAuthBackground extends StatelessWidget {
  final Widget? child;
  final bool showWaves;

  const WaveAuthBackground({
    super.key,
    this.child,
    this.showWaves = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.primary900,
                  AppColors.primary800,
                  AppColors.accent950,
                ]
              : [
                  AppColors.primary900,
                  AppColors.primary800,
                  AppColors.accent900,
                ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (showWaves)
            Positioned.fill(
              child: CustomPaint(
                painter: _WavePainter(),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    // Create smooth wave curves
    for (double i = 0; i <= size.width; i++) {
      final y = size.height * 0.7 +
          sin(i * 0.02) * 20 +
          sin(i * 0.01) * 10;
      path.lineTo(i, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Second wave
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    
    for (double i = 0; i <= size.width; i++) {
      final y = size.height * 0.8 +
          sin(i * 0.015 + 1) * 15 +
          sin(i * 0.008) * 8;
      path2.lineTo(i, y);
    }
    
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
