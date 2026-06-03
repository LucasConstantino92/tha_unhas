import 'package:flutter/material.dart';

enum AppButtonVariant {
  filled,
  outlined,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54.0,
  });

  const AppButton.filled({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54.0,
  }) : variant = AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54.0,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54.0,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClickable = enabled && !isLoading && onPressed != null;

    final Widget content = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.filled
                    ? Colors.white
                    : (textColor ?? theme.colorScheme.primary),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: variant == AppButtonVariant.filled
                      ? Colors.white
                      : (textColor ?? theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      minimumSize: Size(width ?? double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    switch (variant) {
      case AppButtonVariant.filled:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isClickable ? onPressed : null,
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return theme.colorScheme.primary.withValues(alpha: 0.5);
                }
                return backgroundColor ?? theme.colorScheme.primary;
              }),
              foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
              elevation: WidgetStateProperty.all(0),
            ),
            child: content,
          ),
        );

      case AppButtonVariant.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isClickable ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? theme.colorScheme.primary,
              side: BorderSide(
                color: isClickable
                    ? (backgroundColor ?? theme.colorScheme.primary)
                    : theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: Size(width ?? double.infinity, height),
            ),
            child: content,
          ),
        );

      case AppButtonVariant.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isClickable ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: width != null ? Size(width!, height) : null,
            ),
            child: content,
          ),
        );
    }
  }
}
