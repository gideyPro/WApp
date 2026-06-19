import 'package:flutter/material.dart';
import 'wave_liquid_glass.dart';

class WaveGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const WaveGlass({
    super.key,
    required this.child,
    this.blur = 20,
    this.borderRadius = 4,
    this.color,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      blur: blur,
      borderRadius: borderRadius,
      tint: color,
      variant: LiquidGlassVariant.regular,
      padding: padding,
      child: child,
    );
  }
}
