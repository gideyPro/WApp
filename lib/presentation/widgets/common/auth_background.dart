import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WaveAuthBackground extends StatefulWidget {
  final Widget? child;
  final bool showWaves;

  const WaveAuthBackground({
    super.key,
    this.child,
    this.showWaves = true,
  });

  @override
  State<WaveAuthBackground> createState() => _WaveAuthBackgroundState();
}

class _WaveAuthBackgroundState extends State<WaveAuthBackground> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final orbSize = size.width * 0.6;

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
                  AppColors.primary800,
                  AppColors.primary900,
                  AppColors.primary950,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay (matching web pattern.svg at ~5% opacity)
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                opacity: isDark ? 0.03 : 0.05,
              ),
            ),
          ),

          // Top-right orb (matching web: primary-500/15, blur-3xl)
          Positioned(
            top: -orbSize * 0.05,
            right: -orbSize * 0.05,
            child: _DecorativeOrb(
              size: orbSize,
              color: AppColors.primary500,
              opacity: isDark ? 0.1 : 0.15,
              blur: 60,
            ),
          ),

          // Bottom-left orb (matching web: primary-700/10, blur-3xl)
          Positioned(
            bottom: -orbSize * 0.05,
            left: -orbSize * 0.05,
            child: _DecorativeOrb(
              size: orbSize,
              color: AppColors.primary700,
              opacity: isDark ? 0.06 : 0.1,
              blur: 60,
            ),
          ),

          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final double opacity;

  _PatternPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Subtle diamond pattern matching web pattern.svg aesthetic
    const spacing = 40.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 8)
          ..lineTo(x + 8, y)
          ..lineTo(x, y + 8)
          ..lineTo(x - 8, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _DecorativeOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double blur;

  const _DecorativeOrb({
    required this.size,
    required this.color,
    required this.opacity,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.5),
            blurRadius: blur,
            spreadRadius: blur * 0.3,
          ),
        ],
      ),
    );
  }
}
