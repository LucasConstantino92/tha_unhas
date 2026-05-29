import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Retorna a cor com a opacidade desejada de forma segura contra depreciações.
  Color appOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
}
