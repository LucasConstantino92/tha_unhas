import 'package:flutter/material.dart';

enum AppTextVariant {
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final double? height;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  });

  const AppText.titleLarge(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.titleLarge;

  const AppText.titleMedium(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.titleMedium;

  const AppText.titleSmall(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.titleSmall;

  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.bodyLarge;

  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.bodyMedium;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.bodySmall;

  const AppText.labelLarge(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.labelLarge;

  const AppText.labelMedium(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.labelMedium;

  const AppText.labelSmall(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
  }) : variant = AppTextVariant.labelSmall;

  TextStyle _getStyle(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    TextStyle style;
    switch (variant) {
      case AppTextVariant.titleLarge:
        style = textTheme.titleLarge ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
        break;
      case AppTextVariant.titleMedium:
        style = textTheme.titleMedium ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
        break;
      case AppTextVariant.titleSmall:
        style = textTheme.titleSmall ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
        break;
      case AppTextVariant.bodyLarge:
        style = textTheme.bodyLarge ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
        break;
      case AppTextVariant.bodyMedium:
        style = textTheme.bodyMedium ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
        break;
      case AppTextVariant.bodySmall:
        style = textTheme.bodySmall ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
        break;
      case AppTextVariant.labelLarge:
        style = textTheme.labelLarge ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
        break;
      case AppTextVariant.labelMedium:
        style = textTheme.labelMedium ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
        break;
      case AppTextVariant.labelSmall:
        style = textTheme.labelSmall ?? const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
        break;
    }

    return style.copyWith(
      color: color ?? theme.colorScheme.onSurface,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
