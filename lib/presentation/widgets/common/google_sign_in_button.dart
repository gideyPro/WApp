import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';

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
              isLoading ? 'Signing in...' : 'Sign in with Google',
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
    final paint = Paint()..style = PaintingStyle.fill;
    final sc = size.width / 18;

    // Google Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(_gPath(sc), paint);
  }

  static Path _gPath(double sc) {
    final p = Path();
    // Simplified Google "G" letterform — clean sans-serif capital G
    p.moveTo(12.3 * sc, 14.3 * sc);
    p.lineTo(13.8 * sc, 15.8 * sc);
    p.cubicTo(12.9 * sc, 16.6 * sc, 11.6 * sc, 17.1 * sc, 10.1 * sc, 17.1 * sc);
    p.cubicTo(7.1 * sc, 17.1 * sc, 4.6 * sc, 14.7 * sc, 4.6 * sc, 11.7 * sc);
    p.cubicTo(4.6 * sc, 8.7 * sc, 7.1 * sc, 6.3 * sc, 10.1 * sc, 6.3 * sc);
    p.cubicTo(11.8 * sc, 6.3 * sc, 13.3 * sc, 7.1 * sc, 14.3 * sc, 8.3 * sc);
    p.lineTo(12.8 * sc, 9.8 * sc);
    p.cubicTo(12.2 * sc, 9.0 * sc, 11.2 * sc, 8.5 * sc, 10.1 * sc, 8.5 * sc);
    p.cubicTo(8.3 * sc, 8.5 * sc, 6.8 * sc, 9.9 * sc, 6.8 * sc, 11.7 * sc);
    p.cubicTo(6.8 * sc, 13.5 * sc, 8.3 * sc, 14.9 * sc, 10.1 * sc, 14.9 * sc);
    p.cubicTo(11.0 * sc, 14.9 * sc, 11.7 * sc, 14.6 * sc, 12.3 * sc, 14.3 * sc);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
