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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          if (widget.showWaves)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _AuroraOverlay(value: _controller.value),
              ),
            ),
          if (widget.child != null) widget.child!,
        ],
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
    final centerX = sin(t * 2 * pi) * 0.4;
    final centerY = cos(t * 2 * pi) * 0.25 - 0.15;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(centerX, centerY),
          radius: 0.7 + t * 0.3,
          colors: isDark
              ? [
                  AppColors.accent500.withValues(alpha: 0.0),
                  AppColors.accent500.withValues(alpha: 0.06),
                  AppColors.cta500.withValues(alpha: 0.04),
                  Colors.transparent,
                ]
              : [
                  AppColors.accent500.withValues(alpha: 0.0),
                  AppColors.accent500.withValues(alpha: 0.09),
                  AppColors.cta500.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
          stops: const [0.0, 0.25, 0.55, 1.0],
        ),
      ),
    );
  }
}
