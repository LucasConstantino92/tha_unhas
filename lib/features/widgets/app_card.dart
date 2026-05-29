import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;
  final bool showBorder;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderRadius = 20.0,
    this.elevation = 0,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBorderColor = isDark 
        ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
        : theme.colorScheme.primary.withValues(alpha: 0.12);

    final widgetBorder = showBorder 
        ? Border.all(color: borderColor ?? defaultBorderColor, width: 1)
        : null;

    final decoration = BoxDecoration(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: widgetBorder,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: elevation * 4,
                spreadRadius: elevation,
                offset: Offset(0, elevation * 1.5),
              ),
            ]
          : null,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}
