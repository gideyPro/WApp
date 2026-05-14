import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// A universal premium card component for WaveMart
/// Defaults to visual glassmorphism (translucent + shadow + border)
/// Use [useBackdropFilter] to enable real frosted blur (works best outside scroll views)
class WaveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final bool showBorder;
  final bool showShadow;
  final bool isGlass;
  final bool useBackdropFilter;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;

  const WaveCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppSpacing.borderRadiusSm,
    this.color,
    this.showBorder = true,
    this.showShadow = true,
    this.isGlass = true,
    this.useBackdropFilter = false,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor;
    List<BoxShadow>? shadows;

    if (isGlass) {
      // Visual glass: translucent white background + white border + premium shadow
      cardColor = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.7);
      shadows = AppColors.shadowPremium;
    } else {
      cardColor = color ?? (isDark ? AppColors.primary800 : Colors.white);
      shadows = showShadow
          ? (isDark
              ? AppColors.shadowDarkPremium(AppColors.accent900)
              : AppColors.shadowPremium)
          : null;
    }

    Widget cardBody = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: isGlass
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.8))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.primary200),
              )
            : null,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (isGlass && useBackdropFilter) {
      cardBody = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: cardBody,
        ),
      );
    }

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardBody,
        ),
      ),
    );
  }
}
