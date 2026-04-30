import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// A universal premium card component for WaveMart
/// Supports glassmorphism effects, tap feedback, and theme-aware shadows
class WaveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final bool showBorder;
  final bool showShadow;
  final bool isGlass;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;

  const WaveCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppSpacing.borderRadiusXxl,
    this.color,
    this.showBorder = true,
    this.showShadow = true,
    this.isGlass = false,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget content = Container(
      padding: padding,
      child: child,
    );

    if (isGlass) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: context.glassBg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: context.glassBorder),
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isGlass ? Colors.transparent : (color ?? context.cardBg),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder && !isGlass
            ? Border.all(
                color: isDark 
                  ? Colors.white.withOpacity(0.05) 
                  : const Color(0xFFF1F5F9)
              )
            : null,
        boxShadow: showShadow && !isGlass
            ? (isDark ? AppColors.shadowDarkPremium(AppColors.wave900) : AppColors.shadowPremium)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: isGlass ? content : Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
