import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'wave_button.dart';

enum DialogType { alert, confirm }

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
    final items = <Widget>[];
    for (int i = 0; i < actions!.length; i++) {
      if (i > 0) {
        items.add(const SizedBox(width: AppSpacing.sm));
      }
      items.add(actions![i]);
    }
    return items;
  }
}