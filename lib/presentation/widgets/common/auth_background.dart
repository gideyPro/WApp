import 'dart:math';
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

class _WaveAuthBackgroundState extends State<WaveAuthBackground>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _floatController1;
  late AnimationController _floatController2;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _floatController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A1929),
                  AppColors.primary900,
                  const Color(0xFF0D2137),
                ]
              : [
                  const Color(0xFF0A416B),
                  const Color(0xFF0C4D7D),
                  const Color(0xFF063552),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Geometric pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(
                opacity: isDark ? 0.03 : 0.04,
              ),
            ),
          ),

          // Animated aurora glow
          if (widget.showWaves)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _auroraController,
                builder: (context, _) => _AuroraOverlay(value: _auroraController.value),
              ),
            ),

          // Floating decorative orbs
          if (widget.showWaves) ...[
            AnimatedBuilder(
              animation: _floatController1,
              builder: (context, _) => Positioned(
                top: size.height * 0.15 + _floatController1.value * 30,
                right: -40,
                child: _DecorativeOrb(
                  size: 180,
                  color: AppColors.accent500,
                  opacity: isDark ? 0.06 : 0.08,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _floatController2,
              builder: (context, _) => Positioned(
                bottom: size.height * 0.2 + _floatController2.value * 20,
                left: -60,
                child: _DecorativeOrb(
                  size: 220,
                  color: AppColors.cta500,
                  opacity: isDark ? 0.04 : 0.06,
                ),
              ),
            ),
          ],

          // Top decorative wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _TopWavePainter(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
          ),

          // Bottom decorative wave
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 160,
              child: CustomPaint(
                painter: _BottomWavePainter(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),

          // Subtle grid lines
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                opacity: isDark ? 0.015 : 0.02,
              ),
            ),
          ),

          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  final double opacity;

  _GeometricPatternPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Diamond patterns
    const spacing = 60.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 12)
          ..lineTo(x + 12, y)
          ..lineTo(x, y + 12)
          ..lineTo(x - 12, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricPatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _GridPainter extends CustomPainter {
  final double opacity;

  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    const spacing = 80.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _TopWavePainter extends CustomPainter {
  final Color color;

  _TopWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.25, 40,
        size.width * 0.5, 20,
      )
      ..quadraticBezierTo(
        size.width * 0.75, 0,
        size.width, 30,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TopWavePainter oldDelegate) => false;
}

class _BottomWavePainter extends CustomPainter {
  final Color color;

  _BottomWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.3, size.height - 50,
        size.width * 0.5, size.height - 30,
      )
      ..quadraticBezierTo(
        size.width * 0.7, size.height - 10,
        size.width, size.height - 40,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomWavePainter oldDelegate) => false;
}

class _DecorativeOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _DecorativeOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _AuroraOverlay extends StatelessWidget {
  final double value;

  const _AuroraOverlay({required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = value;
    final centerX = sin(t * 2 * pi) * 0.3;
    final centerY = cos(t * 2 * pi) * 0.2 - 0.1;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(centerX, centerY),
          radius: 0.6 + t * 0.4,
          colors: isDark
              ? [
                  AppColors.accent500.withValues(alpha: 0.0),
                  AppColors.accent500.withValues(alpha: 0.08),
                  AppColors.cta500.withValues(alpha: 0.05),
                  Colors.transparent,
                ]
              : [
                  AppColors.accent500.withValues(alpha: 0.0),
                  AppColors.accent500.withValues(alpha: 0.12),
                  AppColors.cta500.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }
}
