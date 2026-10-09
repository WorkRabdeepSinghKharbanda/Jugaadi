import 'package:flutter/material.dart';

/// Design tokens, CRED-inspired, dark-first. Feature code reads these —
/// never a literal Color/EdgeInsets/Duration.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceLow,
    required this.outline,
    required this.shadowDark,
    required this.shadowLight,
    required this.accent,
    required this.accentDeep,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.live,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
  });

  final Color bg;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceLow;
  final Color outline;
  final Color shadowDark;
  final Color shadowLight;
  final Color accent;
  final Color accentDeep;

  /// Text on [accent]. Near-black: amber is light, so dark text reads best.
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;

  /// Decorative / >=18px only, never body text (contrast too low).
  final Color textTertiary;
  final Color live;
  final Color danger;
  final Color dangerSoft;
  final Color warning;

  Color get accentSoft => accent.withValues(alpha: 0.14);
  LinearGradient get accentGradient => LinearGradient(
        colors: [accent, accentDeep],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const dark = AppColors(
    bg: Color(0xFF0B0B0F),
    surface: Color(0xFF17171A),
    surfaceHigh: Color(0xFF1E1E22),
    surfaceLow: Color(0xFF111113),
    outline: Color(0xFF2A2A2E),
    shadowDark: Color(0xFF050506),
    shadowLight: Color(0xFF2E2A22),
    accent: Color(0xFFE8A33D),
    accentDeep: Color(0xFFC17B1D),
    onAccent: Color(0xFF0B0B0F),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA6A6B3),
    textTertiary: Color(0xFF6E6E7A),
    live: Color(0xFF3DDC97),
    danger: Color(0xFFFF5A5F),
    dangerSoft: Color(0xFF2A1416),
    warning: Color(0xFFFFB547),
  );

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>() ?? dark;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension AppColorsX on BuildContext {
  AppColors get colors => AppColors.of(this);
}

class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 999;
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double gutter = 20;
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: gutter);
  static const EdgeInsets card = EdgeInsets.all(md + xs);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> raised(AppColors c) => [
        BoxShadow(color: c.shadowDark.withValues(alpha: 0.9), offset: const Offset(6, 6), blurRadius: 18),
        BoxShadow(color: c.shadowLight.withValues(alpha: 0.5), offset: const Offset(-4, -4), blurRadius: 14),
      ];

  static List<BoxShadow> floating(AppColors c) => [
        BoxShadow(color: c.shadowDark.withValues(alpha: 0.7), offset: const Offset(0, 10), blurRadius: 30),
      ];

  static List<BoxShadow> accentGlow(AppColors c) => [
        BoxShadow(color: c.accent.withValues(alpha: 0.35), offset: const Offset(0, 8), blurRadius: 24),
      ];

  static const List<BoxShadow> none = [];
}

class AppDurations {
  AppDurations._();
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 300);
  static const pulse = Duration(milliseconds: 1400);
  static const curve = Curves.easeOutCubic;

  static Duration of(BuildContext context, [Duration d = base]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;

  static Duration stagger(int index) => Duration(milliseconds: 40 * index.clamp(0, 6));
}

class AppText {
  AppText._();

  static const display = TextStyle(fontSize: 40, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1.0);
  static const headline = TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.6);
  static const title = TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static const body = TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500);
  static const bodySmall = TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500);
  static const label = TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 0.6);
  static const button = TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 0.1);
}
