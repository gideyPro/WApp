import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool hasError;
  final bool autofocus;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.hasError = false,
    this.autofocus = false,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onValueChanged);
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void clear() {
    _controller.clear();
    _completed = false;
  }

  String get code => _controller.text;

  bool get isComplete => _completed;

  void _handleTapUp(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 360;
    final double fieldWidth = isSmall ? 38.0 : 42.0;
    final double gap = isSmall ? 3.0 : 4.0;

    final double rawIndex = details.localPosition.dx / (fieldWidth + gap);
    final int index = rawIndex.floor().clamp(0, widget.length);
    _controller.selection = TextSelection.collapsed(offset: index);
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _onValueChanged() {
    setState(() {});

    final text = _controller.text;
    widget.onChanged?.call(text);

    if (text.length == widget.length) {
      if (!_completed) {
        _completed = true;
        widget.onCompleted?.call(text);
      }
    } else {
      _completed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 360;
    final double fieldWidth = isSmall ? 38.0 : 42.0;
    final double fieldHeight = isSmall ? 46.0 : 50.0;
    final double gap = isSmall ? 3.0 : 4.0;
    final double totalWidth =
        widget.length * fieldWidth + (widget.length - 1) * gap;
    final double borderRadius = isSmall ? 8.0 : 10.0;
    final double fontSize = isSmall ? 18.0 : 20.0;

    return SizedBox(
      width: totalWidth,
      height: fieldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBoxes(fieldWidth, fieldHeight, gap, borderRadius, fontSize),
          Positioned.fill(
            child: GestureDetector(
              onTapUp: _handleTapUp,
              child: Container(color: Colors.transparent),
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              width: totalWidth,
              height: fieldHeight,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                enableSuggestions: false,
                cursorColor: Colors.transparent,
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 1,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxes(
    double fieldWidth,
    double fieldHeight,
    double gap,
    double borderRadius,
    double fontSize,
  ) {
    final String text = _controller.text;
    final bool isFocused = _focusNode.hasFocus;
    final int cursorPos = _controller.selection.baseOffset;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.length, (int index) {
        final String digit = index < text.length ? text[index] : '';
        final bool isActive = isFocused && cursorPos == index;

        return Padding(
          padding:
              EdgeInsets.only(right: index < widget.length - 1 ? gap : 0),
          child: _OtpBox(
            digit: digit,
            isActive: isActive,
            isFocused: isFocused,
            hasError: widget.hasError,
            enabled: widget.enabled,
            borderRadius: borderRadius,
            fontSize: fontSize,
            fieldWidth: fieldWidth,
            fieldHeight: fieldHeight,
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String digit;
  final bool isActive;
  final bool isFocused;
  final bool hasError;
  final bool enabled;
  final double borderRadius;
  final double fontSize;
  final double fieldWidth;
  final double fieldHeight;

  const _OtpBox({
    required this.digit,
    required this.isActive,
    required this.isFocused,
    required this.hasError,
    required this.enabled,
    required this.borderRadius,
    required this.fontSize,
    required this.fieldWidth,
    required this.fieldHeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDigit = digit.isNotEmpty;

    Color bgColor;
    Color borderColor;
    double borderWidth;

    if (hasError) {
      bgColor = AppColors.errorLight;
      borderColor = AppColors.error;
      borderWidth = 1.5;
    } else if (isActive) {
      bgColor = AppColors.primary50;
      borderColor = AppColors.accent500;
      borderWidth = 2;
    } else if (isFocused || hasDigit) {
      bgColor = AppColors.primary50;
      borderColor = AppColors.primary200;
      borderWidth = 1;
    } else {
      bgColor = AppColors.primary50.withValues(alpha: 0.5);
      borderColor = AppColors.primary200;
      borderWidth = 1;
    }

    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (hasDigit)
              Text(
                digit,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary900,
                ),
              ),
            if (isActive)
              const Center(child: _BlinkingCursor()),
          ],
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 1.5,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.accent500,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
