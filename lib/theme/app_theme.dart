import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const background = Color(0xFF070A12);
  static const surface = Color(0xFF111827);
  static const outline = Color(0xFF253247);
  static const cyan = Color(0xFF55DDF4);
  static const violet = Color(0xFF9678FF);
  static const magenta = Color(0xFFFF4FD8);
  static const success = Color(0xFF4DFFB8);
  static const warning = Color(0xFFFFD166);
  static const danger = Color(0xFFFF668A);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF05070D),
      Color(0xFF090E1B),
      Color(0xFF0C1324),
      Color(0xFF080C16),
    ],
    stops: [0, 0.36, 0.72, 1],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xF51A2538), Color(0xF0141C2C), Color(0xF00D1422)],
    stops: [0, 0.52, 1],
  );

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.dark,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'sans-serif',
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(color: Color(0xFFC5CEE0), height: 1.45),
        bodySmall: TextStyle(color: Color(0xFF8F9BB1), height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x66121A2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x4438E8FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x4438E8FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: cyan, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xEE172238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x332D3C55),
        thickness: 0.7,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFFDCE5F7),
          backgroundColor: const Color(0x52152030),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0x332E4262)),
          ),
        ),
      ),
    );
  }
}
