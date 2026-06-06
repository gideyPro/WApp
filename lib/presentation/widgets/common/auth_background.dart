import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WaveAuthBackground extends StatefulWidget {
  final Widget? child;

  const WaveAuthBackground({super.key, this.child});

  @override
  State<WaveAuthBackground> createState() => _WaveAuthBackgroundState();
}

class _WaveAuthBackgroundState extends State<WaveAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (8 * (0.5 - (t - 0.25).abs() * 2)),
                    right: -80 + (10 * (0.5 - (t - 0.75).abs() * 2)),
                    child: Container(
                      width: 384,
                      height: 384,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary500.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom:
                        -80 + (10 * (0.5 - (t - 0.5).abs() * 2)),
                    left: -80 + (8 * (0.5 - (t).abs() * 2)),
                    child: Container(
                      width: 384,
                      height: 384,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary700.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
