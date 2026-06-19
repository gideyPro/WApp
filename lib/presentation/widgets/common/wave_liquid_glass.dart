import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum LiquidGlassVariant { regular, prominent }

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? tint;
  final bool interactive;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final LiquidGlassVariant variant;
  final VoidCallback? onTap;

  const LiquidGlass({
    super.key,
    required this.child,
    this.blur = 24,
    this.borderRadius = 4,
    this.tint,
    this.interactive = false,
    this.padding,
    this.margin,
    this.variant = LiquidGlassVariant.regular,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tintColor = tint ?? AppColors.accent500;

    Color glassBg;
    Color glassBorder;
    List<BoxShadow> shadows;

    if (variant == LiquidGlassVariant.prominent) {
      glassBg = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.82);
      glassBorder = isDark
          ? Colors.white.withValues(alpha: 0.22)
          : Colors.black.withValues(alpha: 0.10);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: tintColor.withValues(alpha: isDark ? 0.25 : 0.10),
          blurRadius: 48,
          offset: const Offset(0, 20),
        ),
      ];
    } else {
      glassBg = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.65);
      glassBorder = isDark
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.black.withValues(alpha: 0.08);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
    }

    Widget glassBody = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: glassBorder),
        boxShadow: shadows,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor.withValues(alpha: isDark ? 0.15 : 0.08),
            Colors.transparent,
            tintColor.withValues(alpha: isDark ? 0.06 : 0.03),
          ],
        ),
      ),
      child: child,
    );

    glassBody = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: glassBody,
      ),
    );

    if (interactive || onTap != null) {
      return _InteractiveGlass(
        margin: margin,
        borderRadius: borderRadius,
        onTap: onTap,
        child: glassBody,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: glassBody,
    );
  }
}

class _InteractiveGlass extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const _InteractiveGlass({
    required this.child,
    this.margin,
    required this.borderRadius,
    this.onTap,
  });

  @override
  State<_InteractiveGlass> createState() => _InteractiveGlassState();
}

class _InteractiveGlassState extends State<_InteractiveGlass>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
