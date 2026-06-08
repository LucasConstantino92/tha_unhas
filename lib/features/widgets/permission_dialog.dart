import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'app_button.dart';
import 'app_text.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.primaryAccentColor),
          const SizedBox(height: 16),
          AppText.titleMedium(title, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
        ],
      ),
      content: AppText.bodyMedium(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        AppButton.outlined(
          text: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton.filled(
          text: 'Permitir',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

Future<bool> showPermissionDialog({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => PermissionDialog(
      title: title,
      message: message,
      icon: icon,
    ),
  );
  return result ?? false;
}
