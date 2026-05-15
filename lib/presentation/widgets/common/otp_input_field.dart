import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

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
    final isSmall = MediaQuery.of(context).size.width < 360;
    final boxSize = isSmall ? 40.0 : 46.0;
    const gap = 8.0;
    final totalWidth = widget.length * boxSize + (widget.length - 1) * gap;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: SizedBox(
        width: totalWidth,
        height: boxSize,
        child: Stack(
          children: [
            _buildBoxes(boxSize),
            Positioned.fill(
              child: TextField(
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
                textAlign: TextAlign.center,
                cursorColor: AppColors.accent500,
                cursorWidth: 2,
                style: const TextStyle(
                  color: Colors.transparent,
                  height: 1,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxes(double boxSize) {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    final isFocused = _focusNode.hasFocus;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        final hasDigit = index < text.length;
        final isCursor = isFocused && cursorPos == index;

        Color bgColor;
        Color borderColor;
        double borderWidth;

        if (widget.hasError) {
          bgColor = AppColors.error.withValues(alpha: 0.06);
          borderColor = AppColors.error.withValues(alpha: 0.3);
          borderWidth = 1;
        } else if (isCursor) {
          bgColor = Colors.white;
          borderColor = AppColors.accent500;
          borderWidth = 2;
        } else if (hasDigit) {
          bgColor = Colors.white;
          borderColor = AppColors.primary200;
          borderWidth = 1;
        } else {
          bgColor = Colors.white.withValues(alpha: 0.5);
          borderColor = AppColors.primary200;
          borderWidth = 1;
        }

        return Padding(
          padding: EdgeInsets.only(right: index < widget.length - 1 ? 8.0 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            alignment: Alignment.center,
            child: hasDigit
                ? Text(
                    text[index],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary900,
                    ),
                  )
                : isCursor
                    ? _BlinkingCursor()
                    : null,
          ),
        );
      }),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 24,
        color: AppColors.accent500,
      ),
    );
  }
}
