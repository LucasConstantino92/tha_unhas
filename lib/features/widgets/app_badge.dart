import 'package:flutter/material.dart';

enum AppBadgeType {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppBadge({
    super.key,
    required this.label,
    this.type = AppBadgeType.primary,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  const AppBadge.primary({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppBadgeType.primary;

  const AppBadge.secondary({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppBadgeType.secondary;

  const AppBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppBadgeType.success;

  const AppBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppBadgeType.warning;

  const AppBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppBadgeType.error;

  const AppBadge.info({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : type = AppBadgeType.info;

  Color _getBackgroundColor(ThemeData theme) {
    if (backgroundColor != null) return backgroundColor!;
    
    switch (type) {
      case AppBadgeType.primary:
        return theme.colorScheme.primary.withValues(alpha: 0.12);
      case AppBadgeType.secondary:
        return theme.colorScheme.secondary.withValues(alpha: 0.12);
      case AppBadgeType.success:
        return const Color(0xFFE2F4E6);
      case AppBadgeType.warning:
        return const Color(0xFFFEF3D6);
      case AppBadgeType.error:
        return const Color(0xFFFBEBEB);
      case AppBadgeType.info:
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (textColor != null) return textColor!;

    switch (type) {
      case AppBadgeType.primary:
        return theme.colorScheme.primary;
      case AppBadgeType.secondary:
        return theme.colorScheme.secondary;
      case AppBadgeType.success:
        return const Color(0xFF1E6B30);
      case AppBadgeType.warning:
        return const Color(0xFFB7791F);
      case AppBadgeType.error:
        return const Color(0xFFC0392B);
      case AppBadgeType.info:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _getBackgroundColor(theme);
    final txtColor = _getTextColor(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: txtColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
