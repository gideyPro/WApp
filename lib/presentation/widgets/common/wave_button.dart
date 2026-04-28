import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';

/// WaveMart Primary Button
/// Gradient navy button with shadow effects
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

  const WaveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 48,
    this.inputFormatters,
  });

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
        : (widget.width ?? null);

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
              borderRadius: BorderRadius.circular(8),
              splashColor: _getSplashColor(),
              highlightColor: _getHighlightColor(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: _isPressed ? null : _getGradient(),
                  color: _isPressed ? _getPressedColor() : _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
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
                                size: 18,
                                color: _getTextColor(),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text.toUpperCase(),
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: _getTextColor(),
                                fontSize: widget.height < 48 ? 12 : 14,
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
        return AppColors.gradientNavy;
      case ButtonVariant.success:
        return AppColors.gradientEmerald;
      default:
        return null;
    }
  }

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case ButtonVariant.secondary:
        return AppColors.navy100;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.error;
      default:
        return AppColors.navy950;
    }
  }

  Color _getPressedColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.navy900;
      case ButtonVariant.secondary:
        return AppColors.navy200;
      case ButtonVariant.outline:
        return AppColors.zinc50;
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
        return AppColors.navy700;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.navy700;
      default:
        return Colors.white;
    }
  }

  Color _getLoadingColor() {
    switch (widget.variant) {
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.navy700;
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
                  ? AppColors.navy950
                  : AppColors.emerald600)
              .withOpacity(0.25),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    }
    return null;
  }

  Color _getSplashColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.wave500.withOpacity(0.3);
      case ButtonVariant.success:
        return AppColors.emerald500.withOpacity(0.3);
      default:
        return AppColors.navy500.withOpacity(0.1);
    }
  }

  Color _getHighlightColor() {
    return AppColors.navy500.withOpacity(0.05);
  }
}

/// WaveMart Text Field
class WaveTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const WaveTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),

        // Input Field
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.zinc50.withOpacity(0.5)
                : AppColors.zinc100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : enabled
                      ? AppColors.zinc300
                      : AppColors.zinc200,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            enabled: enabled,
            onChanged: onChanged,
            onTap: onTap,
            inputFormatters: inputFormatters,
            validator: validator,
            style: AppTextStyles.bodyMedium.copyWith(
              color: enabled ? AppColors.zinc700 : AppColors.zinc400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.navy400,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        prefixIcon,
                        size: 20,
                         color: enabled
                             ? context.theme.textMuted.withOpacity(0.5)
                             : AppColors.zinc300,
                      ),
                    )
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: prefixIcon != null ? 8 : 16,
                right: suffixIcon != null ? 8 : 16,
                top: 16,
                bottom: 16,
              ),
              errorText: null,
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),

        // Error Text
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// WaveMart App Bar
class WaveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isScrolled;
  final double elevation;

  const WaveAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.isScrolled = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = backgroundColor == Colors.white ||
        backgroundColor == AppColors.background;

    return AppBar(
      elevation: elevation,
      scrolledUnderElevation: isScrolled ? 4 : 0,
      backgroundColor: backgroundColor ?? context.scaffoldBg,
      foregroundColor: foregroundColor ??
          (isLight ? context.theme.textPrimary : Colors.white),
      centerTitle: false,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: Text(
        title,
        style: AppTextStyles.title.copyWith(
          color: foregroundColor ??
              (isLight ? context.theme.textPrimary : Colors.white),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// WaveMart Card
class WaveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool enableHover;

  const WaveCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.enableHover = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divider.withOpacity(0.5)),
          boxShadow: enableHover ? AppColors.shadowMd : AppColors.shadowSm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// WaveMart Badge
class WaveBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final bool animated;

  const WaveBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.defaultVariant,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (animated)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            text,
            style: AppTextStyles.badge.copyWith(
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case BadgeVariant.newItem:
        return AppColors.emerald500;
      case BadgeVariant.featured:
        return AppColors.wave500;
      case BadgeVariant.sale:
        return AppColors.emerald100;
      case BadgeVariant.rent:
        return AppColors.wave100;
      case BadgeVariant.pending:
        return AppColors.warning;
      case BadgeVariant.error:
        return AppColors.error;
      default:
        return AppColors.zinc200;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case BadgeVariant.newItem:
      case BadgeVariant.featured:
      case BadgeVariant.pending:
      case BadgeVariant.error:
        return Colors.white;
      case BadgeVariant.sale:
        return AppColors.emerald700;
      case BadgeVariant.rent:
        return AppColors.wave700;
      default:
        return AppColors.zinc700;
    }
  }
}

enum BadgeVariant {
  defaultVariant,
  newItem,
  featured,
  sale,
  rent,
  pending,
  error,
}
