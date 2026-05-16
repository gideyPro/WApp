import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';

/// WaveMart Primary Button
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
  final bool isCompact;

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
    this.isCompact = false,
  });

  factory WaveTextField.compact({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextEditingController? controller,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return WaveTextField(
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      controller: controller,
      errorText: errorText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: inputFormatters,
      validator: validator,
      isCompact: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalPadding = isCompact ? AppSpacing.md : AppSpacing.lg;
    final labelSize = isCompact ? 12.0 : 14.0;
    final iconSize = isCompact ? 18.0 : 20.0;
    final fontSize = isCompact ? 14.0 : 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(fontSize: labelSize),
        ),
        SizedBox(height: isCompact ? AppSpacing.xs : AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary50.withValues(alpha: 0.5)
                : AppColors.primary100,
            borderRadius: BorderRadius.circular(isCompact ? 4 : AppSpacing.borderRadiusSm),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : enabled
                      ? AppColors.primary300
                      : AppColors.primary200,
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
              fontSize: fontSize,
              color: enabled ? AppColors.primary700 : AppColors.primary400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                fontSize: fontSize,
                color: AppColors.primary400,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
                      child: Icon(
                        prefixIcon,
                        size: iconSize,
                        color: enabled
                            ? context.theme.textMuted.withValues(alpha: 0.5)
                            : AppColors.primary300,
                      ),
                    )
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: prefixIcon != null ? 4 : (isCompact ? AppSpacing.md : AppSpacing.lg),
                right: suffixIcon != null ? 4 : (isCompact ? AppSpacing.md : AppSpacing.lg),
                top: verticalPadding,
                bottom: verticalPadding,
              ),
              errorText: null,
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
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
        backgroundColor == AppColors.primary50;

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
        borderRadius: BorderRadius.circular(4),
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
        return AppColors.primary600;
      case BadgeVariant.featured:
        return AppColors.accent600;
      case BadgeVariant.sale:
        return AppColors.accent100;
      case BadgeVariant.rent:
        return AppColors.primary100;
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
        return AppColors.accent700;
      case BadgeVariant.rent:
        return AppColors.primary700;
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
