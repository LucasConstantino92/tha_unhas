import 'package:flutter/material.dart';

class AppTheme {
  // Cor de fundo do splash / principal do app
  static const Color primaryBackgroundColor = Color(0xFFF7F3E7);
  static const Color primaryAccentColor = Color(0xFFE28C9B); // Tom suave de rosa/rose gold
  static const Color secondaryAccentColor = Color(0xFFC07380);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryAccentColor,
        secondary: secondaryAccentColor,
        background: primaryBackgroundColor,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFF2C2520), // Marrom muito escuro para texto
        onSurface: Color(0xFF2C2520),
      ),
      scaffoldBackgroundColor: primaryBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF2C2520)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2C2520),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryAccentColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryAccentColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: Color(0xFF2C2520).withOpacity(0.6)),
        floatingLabelStyle: const TextStyle(color: primaryAccentColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryAccentColor,
        secondary: secondaryAccentColor,
        background: const Color(0xFF1C1A16), // Tom dark com nuance marrom/quente
        surface: const Color(0xFF25231F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: const Color(0xFFF7F3E7),
        onSurface: const Color(0xFFF7F3E7),
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1A16),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1A16),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFF7F3E7)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF7F3E7),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF25231F),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryAccentColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryAccentColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: const Color(0xFFF7F3E7).withOpacity(0.6)),
        floatingLabelStyle: const TextStyle(color: primaryAccentColor),
      ),
    );
  }
}
