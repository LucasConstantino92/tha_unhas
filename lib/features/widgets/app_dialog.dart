import 'package:flutter/material.dart';
import 'app_button.dart';
import 'app_text.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget? icon;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.icon,
    this.isDestructive = false,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Widget? icon,
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          onConfirm: onConfirm,
          onCancel: onCancel,
          icon: icon,
          isDestructive: isDestructive,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 16),
            ],
            AppText.titleMedium(
              title,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            AppText.bodyMedium(
              message,
              textAlign: TextAlign.center,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: AppButton.outlined(
                      text: cancelLabel!,
                      height: 48,
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onCancel != null) onCancel!();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppButton.filled(
                    text: confirmLabel,
                    height: 48,
                    backgroundColor: isDestructive ? const Color(0xFFC0392B) : theme.colorScheme.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
