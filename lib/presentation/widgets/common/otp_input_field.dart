import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool hasError;
  final bool autofocus;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.hasError = false,
    this.autofocus = false,
  });

  @override
  OtpInputFieldState createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _onValueChanged() {
    final text = _controller.text;
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.length),
      ],
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      enableSuggestions: false,
      autofillHints: const [AutofillHints.oneTimeCode],
      textAlign: TextAlign.center,
      cursorColor: AppColors.accent500,
      cursorWidth: 2,
      style: AppTextStyles.bodyLarge.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: context.textPrimary,
        letterSpacing: 8,
        height: 1.2,
      ),
      decoration: InputDecoration(
        hintText: '0' * widget.length,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: context.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          height: 1.2,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.primary900
            : AppColors.primary50.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: widget.hasError
                ? AppColors.error.withValues(alpha: 0.4)
                : (isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.primary200),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.primary200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: widget.hasError
                ? AppColors.error
                : AppColors.accent500,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),
    );
  }
}
