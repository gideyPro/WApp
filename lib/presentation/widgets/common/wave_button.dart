import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Wavemart Primary Button
/// Gradient accent button with shadow effects
class WaveButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final List<TextInputFormatter>? inputFormatters;
  final ButtonSize size;

  const WaveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 40,
    this.inputFormatters,
    this.size = ButtonSize.medium,
  });

  factory WaveButton.compact({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    ButtonVariant variant = ButtonVariant.primary,
    double? width,
  }) {
    return WaveButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      variant: variant,
      width: width,
      height: 40,
      size: ButtonSize.compact,
    );
  }

  factory WaveButton.small({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    ButtonVariant variant = ButtonVariant.primary,
    double? width,
  }) {
    return WaveButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      variant: variant,
      width: width,
      height: 36,
      size: ButtonSize.small,
    );
  }

  @override
  State<WaveButton> createState() => _WaveButtonState();
}

enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  success,
  danger,
}

enum ButtonSize {
  small,
  compact,
  medium,
}

class _WaveButtonState extends State<WaveButton> {
  bool _isPressed = false;

  void _handleTap() {
    if (widget.isLoading || widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = widget.isFullWidth
        ? double.infinity
        : widget.width;

    return SizedBox(
      width: buttonWidth,
      height: widget.height,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              splashColor: _getSplashColor(),
              highlightColor: _getHighlightColor(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: _isPressed ? null : _getGradient(),
                  color: _isPressed ? _getPressedColor() : _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _isPressed ? null : _getShadow(),
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getLoadingColor(),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: _getIconSize(),
                                color: _getTextColor(),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              widget.text.toUpperCase(),
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: _getTextColor(),
                                fontSize: _getFontSize(),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient? _getGradient() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.gradientAccent;
      case ButtonVariant.success:
        return AppColors.gradientEmerald;
      default:
        return null;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.compact:
        return 16;
      case ButtonSize.medium:
        return 18;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 10;
      case ButtonSize.compact:
        return 11;
      case ButtonSize.medium:
        return 14;
    }
  }

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case ButtonVariant.secondary:
        return AppColors.accent100;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.error;
      default:
        return AppColors.accent600;
    }
  }

  Color _getPressedColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.accent700;
      case ButtonVariant.secondary:
        return AppColors.accent200;
      case ButtonVariant.outline:
        return AppColors.primary50;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.success:
        return AppColors.emerald600;
      case ButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case ButtonVariant.secondary:
        return AppColors.accent700;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.primary700;
      default:
        return Colors.white;
    }
  }

  Color _getLoadingColor() {
    switch (widget.variant) {
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.primary700;
      default:
        return Colors.white;
    }
  }

  List<BoxShadow>? _getShadow() {
    if (widget.variant == ButtonVariant.primary ||
        widget.variant == ButtonVariant.success) {
      return [
        BoxShadow(
          color: (widget.variant == ButtonVariant.primary
                  ? AppColors.accent600
                  : AppColors.emerald600)
              .withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
    }
    return null;
  }

  Color _getSplashColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.accent500.withValues(alpha: 0.3);
      case ButtonVariant.success:
        return AppColors.emerald500.withValues(alpha: 0.3);
      default:
        return AppColors.primary500.withValues(alpha: 0.1);
    }
  }

  Color _getHighlightColor() {
    return AppColors.primary500.withValues(alpha: 0.05);
  }
}
