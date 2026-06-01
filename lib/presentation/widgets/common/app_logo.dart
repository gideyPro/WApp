import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GlassLogoContainer extends StatelessWidget {
  final double size;
  final double logoSize;

  const GlassLogoContainer({
    super.key,
    this.size = 100,
    this.logoSize = 70,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.accent500.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.98),
                    Colors.white.withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(logoSize * 0.22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: logoSize * 0.15,
                    offset: Offset(0, logoSize * 0.05),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(logoSize * 0.2),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                  color: AppColors.primary900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
