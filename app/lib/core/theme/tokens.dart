import 'package:flutter/material.dart';

/// Design tokens, CRED-inspired, dark-first with an opt-in light theme (Profile toggle).
/// Feature code reads these — never a literal Color/EdgeInsets/Duration.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceTop,
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
    this.brightness = Brightness.dark,
  });

  final Brightness brightness;
  bool get isDark => brightness == Brightness.dark;

  final Color bg;
  final Color surface;
  final Color surfaceHigh;

  /// Topmost layer: menus, chips on sheets. One step above [surfaceHigh].
  final Color surfaceTop;
  final Color surfaceLow;
  final Color outline;
  final Color shadowDark;
  final Color shadowLight;
  final Color accent;
  final Color accentDeep;

  /// Text on [accent]. Near-black on the dark amber fill; white on the deep light-theme amber.
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;

  /// Decorative / >=18px only, never body text (contrast too low).
  final Color textTertiary;
  final Color live;
  final Color danger;
  final Color dangerSoft;
  final Color warning;

  /// Semantic alias — new code reads [success]; [live] stays for existing call sites.
  Color get success => live;

  Color get accentSoft => accent.withValues(alpha: 0.14);
  LinearGradient get accentGradient => LinearGradient(
    colors: [accent, accentDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Edges are pure white on dark; on light they derive from the text colour so a card
  /// still shows a visible 1 px edge on a white surface.
  Color get _edgeBase => isDark ? Colors.white : textPrimary;

  /// Flat 1 px edge for bars and sheets.
  Color get edge => _edgeBase.withValues(alpha: 0.08);

  /// 1 px hairline: lighter at the top-left, fading out bottom-right.
  LinearGradient get hairline => LinearGradient(
    colors: [
      _edgeBase.withValues(alpha: 0.14),
      _edgeBase.withValues(alpha: 0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dark = AppColors(
    bg: Color(0xFF0B0B0F),
    surface: Color(0xFF17171A),
    surfaceHigh: Color(0xFF1E1E22),
    surfaceTop: Color(0xFF26262C),
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

  /// Light: warm off-white, white cards with soft sand shadows. The amber deepens to a
  /// burnt amber so accent text keeps 4.5:1 on white (E8A33D itself is ~1.9:1 and only
  /// survives as a fill); gradients still read as the same brand.
  static const light = AppColors(
    brightness: Brightness.light,
    bg: Color(0xFFF6F4F0),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFFAF8F3),
    surfaceTop: Color(0xFFF1ECE3),
    surfaceLow: Color(0xFFEFEBE3),
    outline: Color(0xFFE3DDD1),
    shadowDark: Color(0xFFD9D1C3),
    shadowLight: Color(0xFFFFFFFF),
    accent: Color(0xFF8F5A00),
    accentDeep: Color(0xFF724700),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF17171C),
    textSecondary: Color(0xFF5A5A66),
    textTertiary: Color(0xFF62626E),
    live: Color(0xFF1E8F60),
    danger: Color(0xFFC4303A),
    dangerSoft: Color(0xFFFBE9EA),
    warning: Color(0xFF9A6000),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? dark;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

extension AppColorsX on BuildContext {
  AppColors get colors => AppColors.of(this);
}

class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double sheet = 32;
  static const double pill = 999;
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
  static BorderRadius get sheetTop =>
      const BorderRadius.vertical(top: Radius.circular(sheet));
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal screen gutter.
  static const double gutter = 20;

  /// Minimum tap target (a11y).
  static const double minTap = 48;
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: gutter);
  static const EdgeInsets card = EdgeInsets.all(md + xs);
}

class AppShadows {
  AppShadows._();

  /// Neumorphic raised: dark bottom-right + light top-left.
  static List<BoxShadow> raised(AppColors c) => [
    BoxShadow(
      color: c.shadowDark.withValues(alpha: 0.9),
      offset: const Offset(6, 6),
      blurRadius: 18,
    ),
    BoxShadow(
      color: c.shadowLight.withValues(alpha: 0.55),
      offset: const Offset(-4, -4),
      blurRadius: 14,
    ),
  ];

  /// Pressed: the raised shadows compress.
  static List<BoxShadow> compressed(AppColors c) => [
    BoxShadow(
      color: c.shadowDark.withValues(alpha: 0.9),
      offset: const Offset(2, 2),
      blurRadius: 6,
    ),
    BoxShadow(
      color: c.shadowLight.withValues(alpha: 0.4),
      offset: const Offset(-1, -1),
      blurRadius: 4,
    ),
  ];

  /// Floating (sheets, glass bars): one soft drop.
  static List<BoxShadow> floating(AppColors c) => [
    BoxShadow(
      color: c.shadowDark.withValues(alpha: 0.7),
      offset: const Offset(0, 10),
      blurRadius: 30,
    ),
  ];

  static List<BoxShadow> accentGlow(AppColors c) => [
    BoxShadow(
      color: c.accent.withValues(alpha: 0.35),
      offset: const Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> none = [];
}

class AppDurations {
  AppDurations._();
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 300);
  static const pulse = Duration(milliseconds: 1400);

  /// Skeleton shimmer sweep.
  static const shimmer = pulse;
  static const curve = Curves.easeOutCubic;

  static Duration of(BuildContext context, [Duration d = base]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;

  static Duration stagger(int index) =>
      Duration(milliseconds: 40 * index.clamp(0, 6));
}

class AppText {
  AppText._();

  static const display = TextStyle(
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
  );
  static const headline = TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
  static const bodySmall = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  /// Small tracked-out uppercase label above content. Callers pass an already upper-cased string.
  static const label = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );
  static const button = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  /// Hero numbers (wages, counts): oversized, tabular so digits align.
  static const figure = TextStyle(
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
