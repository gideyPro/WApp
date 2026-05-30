import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'wave_button.dart';

enum DialogType { alert, confirm, action }

class WaveDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final DialogType type;
  final bool dismissible;

  const WaveDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.type = DialogType.alert,
    this.dismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    DialogType type = DialogType.alert,
    bool dismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: Colors.black54,
      builder: (context) => WaveDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        type: type,
        dismissible: dismissible,
      ),
    );
  }

  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
    bool dismissible = true,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await show<bool>(
      context: context,
      title: title,
      message: message,
      type: DialogType.confirm,
      dismissible: dismissible,
      actions: [
        WaveButton(
          text: cancelLabel ?? l10n.commonCancel,
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        WaveButton(
          text: confirmLabel ?? l10n.commonOk,
          variant: destructive ? ButtonVariant.danger : ButtonVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary800 : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          boxShadow: AppColors.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Text(
                  title!,
                  style: AppTextStyles.title.copyWith(
                    color: isDark ? Colors.white : AppColors.primary900,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: content ??
                  Text(
                    message ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.primary300 : AppColors.primary600,
                    ),
                  ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActions(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return actions!.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;
      return Padding(
        padding: EdgeInsets.only(left: index > 0 ? AppSpacing.sm : 0),
        child: action,
      );
    }).toList();
  }

}

class WaveBottomSheet extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double? height;
  final bool isDismissible;
  final bool isGlass;

  const WaveBottomSheet({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.height,
    this.isDismissible = true,
    this.isGlass = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    double? height,
    bool isDismissible = true,
    bool isGlass = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WaveBottomSheet(
        title: title,
        content: content,
        actions: actions,
        height: height,
        isDismissible: isDismissible,
        isGlass: isGlass,
      ),
    );
  }

  static Future<T?> showGlass<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    double? height,
    bool isDismissible = true,
  }) {
    return show<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
      height: height,
      isDismissible: isDismissible,
      isGlass: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final bottomInset = mediaQuery.viewInsets.bottom;

    Widget sheetContent = Container(
      height: height ?? (screenHeight * 0.7),
      decoration: BoxDecoration(
        color: isGlass 
            ? (isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.85))
            : (isDark ? AppColors.primary800 : Colors.white),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadiusSm),
        ),
        border: isGlass 
            ? Border.all(color: Colors.white.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isGlass 
                  ? (isDark ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.5))
                  : (isDark ? AppColors.primary700 : AppColors.primary300),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTextStyles.title.copyWith(
                        color: isDark ? Colors.white : AppColors.primary900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isGlass 
                          ? (isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.primary700)
                          : (isDark ? AppColors.primary500 : AppColors.primary500),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.lg),
              child: content,
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isGlass 
                        ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
                        : (isDark ? AppColors.primary800 : AppColors.primary100),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(children: actions!),
              ),
            ),
        ],
      ),
    );

    if (isGlass) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadiusSm),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: sheetContent,
        ),
      );
    }

    return sheetContent;
  }
}