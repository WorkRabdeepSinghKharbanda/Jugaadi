import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens.dart';

/// Dark-only theme built from [AppColors].
class AppTheme {
  AppTheme._();

  static ThemeData get dark => build(AppColors.dark);

  static SystemUiOverlayStyle overlay(AppColors c) => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: c.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  static ThemeData build(AppColors c) {
    final scheme = ColorScheme.dark(
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      surface: c.bg,
      onSurface: c.textPrimary,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceHigh,
      surfaceContainerLow: c.surfaceLow,
      onSurfaceVariant: c.textSecondary,
      outline: c.outline,
      error: c.danger,
      onError: c.textPrimary,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
    );
    final text = TextTheme(
      displayLarge: AppText.display,
      displayMedium: AppText.display,
      displaySmall: AppText.display,
      headlineLarge: AppText.headline,
      headlineMedium: AppText.headline,
      headlineSmall: AppText.headline,
      titleLarge: AppText.title,
      titleMedium: AppText.title.copyWith(fontSize: 17),
      titleSmall: AppText.bodySmall.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      bodySmall: AppText.bodySmall,
      labelLarge: AppText.button,
      labelMedium: AppText.label,
      labelSmall: AppText.label,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: text,
      extensions: [c],
      iconTheme: IconThemeData(color: c.textPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceLow,
        hintStyle: AppText.body.copyWith(color: c.textTertiary),
        labelStyle: AppText.bodySmall.copyWith(color: c.textSecondary),
        errorStyle: AppText.bodySmall.copyWith(color: c.danger),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: AppRadius.smAll, borderSide: BorderSide(color: c.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.smAll, borderSide: BorderSide(color: c.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.smAll, borderSide: BorderSide(color: c.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.smAll, borderSide: BorderSide(color: c.danger)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppRadius.smAll, borderSide: BorderSide(color: c.danger, width: 1.5)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
        dragHandleColor: c.outline,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceHigh,
        contentTextStyle: AppText.bodySmall.copyWith(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.accent,
        labelStyle: AppText.bodySmall.copyWith(color: c.textPrimary),
        side: BorderSide(color: c.outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onAccent : c.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : c.surfaceLow),
        trackOutlineColor: WidgetStateProperty.all(c.outline),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
      dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.accent, selectionColor: c.accentSoft, selectionHandleColor: c.accent),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: overlay(c),
        titleTextStyle: AppText.title.copyWith(color: c.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accentSoft,
        labelTextStyle: WidgetStateProperty.all(AppText.bodySmall.copyWith(color: c.textPrimary)),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? c.accent : c.textTertiary),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
