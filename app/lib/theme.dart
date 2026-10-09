import 'package:flutter/material.dart';

// CRED-style dark UI: near-black surfaces, bold type, amber accent (matches
// the website brand), pill buttons, rounded bordered cards instead of elevation shadows.
const _bg = Color(0xFF0B0B0D);
const _surface = Color(0xFF17171A);
const _accent = Color(0xFFE8A33D);
const _border = Color(0xFF2A2A2E);

ThemeData jugaadiTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: _bg,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: _accent,
      onPrimary: Colors.black,
      secondary: _accent,
      surface: _surface,
      onSurface: Colors.white,
      error: const Color(0xFFFF6B6B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _bg,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Colors.white),
    ),
    textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white).copyWith(
          headlineSmall: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
          titleLarge: const TextStyle(fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(fontWeight: FontWeight.w600),
        ),
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: _border)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _accent, textStyle: const TextStyle(fontWeight: FontWeight.w700)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _accent, width: 1.5)),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: _surface,
      side: const BorderSide(color: _border),
      labelStyle: const TextStyle(color: Colors.white),
      selectedColor: _accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    dividerTheme: const DividerThemeData(color: _border, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _surface,
      indicatorColor: _accent.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: states.contains(WidgetState.selected) ? _accent : Colors.white54),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _surface,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
