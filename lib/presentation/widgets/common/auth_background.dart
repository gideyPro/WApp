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
                  AppColors.primary50,
                  AppColors.primary100,
                  AppColors.primary200,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                opacity: isDark ? 0.06 : 0.08,
                color: isDark ? Colors.white : AppColors.primary400,
              ),
            ),
          ),

          // Top-right orb
          Positioned(
            top: -orbSize * 0.05,
            right: -orbSize * 0.05,
            child: _DecorativeOrb(
              size: orbSize,
              color: isDark ? AppColors.primary500 : AppColors.primary300,
              opacity: isDark ? 0.12 : 0.15,
              blur: 60,
            ),
          ),

          // Bottom-left orb — emerald glow for brand accent
          Positioned(
            bottom: -orbSize * 0.05,
            left: -orbSize * 0.05,
            child: _DecorativeOrb(
              size: orbSize,
              color: isDark ? AppColors.accent500 : AppColors.accent200,
              opacity: isDark ? 0.06 : 0.12,
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
  final Color color;

  _PatternPainter({required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
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
      oldDelegate.opacity != opacity || oldDelegate.color != color;
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
