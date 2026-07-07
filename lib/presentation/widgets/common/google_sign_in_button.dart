import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                final response = await ref
                    .read(authStateProvider.notifier)
                    .loginWithGoogle();
                if (response.success && context.mounted) {
                  context.go('/');
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1F1F1F),
          disabledBackgroundColor: (isDark ? const Color(0xFF2D2D2D) : Colors.white).withValues(alpha: 0.6),
          elevation: 0,
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFDADCE0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleGIcon(),
            const SizedBox(width: 12),
            Text(
              isLoading ? AppLocalizations.of(context).commonSigningIn : AppLocalizations.of(context).commonSignInWithGoogle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : const Color(0xFF3C4043),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sc = size.width / 48;

    // Blue (top-left section)
    _drawPath(canvas, _bluePath(sc), const Color(0xFF4285F4));
    // Red (top-right section)
    _drawPath(canvas, _redPath(sc), const Color(0xFFEA4335));
    // Yellow (bottom-left section)
    _drawPath(canvas, _yellowPath(sc), const Color(0xFFFBBC05));
    // Green (bottom-right section)
    _drawPath(canvas, _greenPath(sc), const Color(0xFF34A853));
  }

  void _drawPath(Canvas canvas, Path path, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawPath(path, paint);
  }

  static Path _bluePath(double s) {
    return Path()
      ..moveTo(24 * s, 9.5 * s)
      ..cubicTo(27.54 * s, 9.5 * s, 30.71 * s, 10.72 * s, 33.21 * s, 13.1 * s)
      ..lineTo(40.06 * s, 6.25 * s)
      ..cubicTo(35.9 * s, 2.38 * s, 30.47 * s, 0 * s, 24 * s, 0 * s)
      ..cubicTo(14.62 * s, 0 * s, 6.51 * s, 5.38 * s, 2.56 * s, 13.22 * s)
      ..lineTo(10.54 * s, 19.41 * s)
      ..cubicTo(12.43 * s, 13.72 * s, 17.74 * s, 9.5 * s, 24 * s, 9.5 * s)
      ..close();
  }

  static Path _redPath(double s) {
    return Path()
      ..moveTo(46.98 * s, 24.55 * s)
      ..cubicTo(46.98 * s, 22.98 * s, 46.83 * s, 21.46 * s, 46.6 * s, 20 * s)
      ..lineTo(24 * s, 20 * s)
      ..lineTo(24 * s, 29.02 * s)
      ..lineTo(36.94 * s, 29.02 * s)
      ..cubicTo(36.36 * s, 31.98 * s, 34.68 * s, 34.5 * s, 32.16 * s, 36.2 * s)
      ..lineTo(39.89 * s, 42.2 * s)
      ..cubicTo(44.4 * s, 38.02 * s, 46.98 * s, 31.84 * s, 46.98 * s, 24.55 * s)
      ..close();
  }

  static Path _yellowPath(double s) {
    return Path()
      ..moveTo(10.54 * s, 28.59 * s)
      ..cubicTo(10.04 * s, 27.14 * s, 9.5 * s, 25.59 * s, 9.5 * s, 24 * s)
      ..cubicTo(9.5 * s, 22.41 * s, 9.78 * s, 20.86 * s, 10.26 * s, 19.41 * s)
      ..lineTo(2.28 * s, 13.22 * s)
      ..cubicTo(0.82 * s, 16.52 * s, 0 * s, 20.17 * s, 0 * s, 24 * s)
      ..cubicTo(0 * s, 27.77 * s, 0.87 * s, 31.35 * s, 2.56 * s, 34.56 * s)
      ..lineTo(10.54 * s, 28.59 * s)
      ..close();
  }

  static Path _greenPath(double s) {
    return Path()
      ..moveTo(24 * s, 48 * s)
      ..cubicTo(30.48 * s, 48 * s, 35.93 * s, 45.87 * s, 39.89 * s, 42.19 * s)
      ..lineTo(32.16 * s, 36.19 * s)
      ..cubicTo(30.01 * s, 37.64 * s, 27.24 * s, 38.49 * s, 24 * s, 38.49 * s)
      ..cubicTo(17.74 * s, 38.49 * s, 12.43 * s, 34.27 * s, 10.53 * s, 28.59 * s)
      ..lineTo(2.55 * s, 34.56 * s)
      ..cubicTo(6.51 * s, 42.62 * s, 14.62 * s, 48 * s, 24 * s, 48 * s)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
