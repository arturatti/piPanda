import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFFFF7EF);
  static const Color primary = Color(0xFFFF7B5C);
  static const Color primaryDark = Color(0xFFE85F40);
  static const Color secondary = Color(0xFFE8527A);
  static const Color mint = Color(0xFF4FD1C5);
  static const Color sunshine = Color(0xFFFFC93C);
  static const Color sky = Color(0xFF4A90E2);
  static const Color violet = Color(0xFFA78BFA);
  static const Color success = Color(0xFF5FCB6E);

  static const Color softYellow = Color(0xFFFFE5A0);
  static const Color accent = mint;

  static const Color slotEmpty = Color(0xFFFBE7D0);
  static const Color slotFilled = Color(0xFFFFB997);

  static const Color textDark = Color(0xFF2D2A2A);
  static const Color textMuted = Color(0xFF7A6F6A);

  static const Color starGold = Color(0xFFFFC93C);
  static const Color starEmpty = Color(0xFFE5DDD3);

  static List<BoxShadow> softShadow({double y = 5, double blur = 15, double alpha = 0.20}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: alpha),
          offset: Offset(0, y),
          blurRadius: blur,
        ),
      ];

  static List<BoxShadow> chunkyShadow({Color? color}) => [
        BoxShadow(
          color: (color ?? Colors.black).withValues(alpha: 0.25),
          offset: const Offset(0, 6),
          blurRadius: 0,
        ),
      ];

  static LinearGradient cardGradient({Color? base}) {
    final b = base ?? Colors.white;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Color.alphaBlend(b.withValues(alpha: 0.18), Colors.white)],
    );
  }

  static LinearGradient modeGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color,
        Color.alphaBlend(Colors.black.withValues(alpha: 0.12), color),
      ],
    );
  }

  static LinearGradient buttonGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.alphaBlend(Colors.white.withValues(alpha: 0.18), color),
        color,
      ],
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: background,
      primary: primary,
      secondary: secondary,
    );
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.comfortaaTextTheme(base.textTheme).apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.comfortaa(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
    );
  }
}
