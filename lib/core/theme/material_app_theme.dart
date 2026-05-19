import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// SportConnect — Material Theme  (light + dark)
///
/// Usage:
///   MaterialApp(
///     theme:     AppMaterialTheme.lightTheme,
///     darkTheme: AppMaterialTheme.darkTheme,
///     themeMode: ThemeMode.system,
///   )
///
/// ── Dark-mode contrast fixes applied ─────────────────────────────────
///
/// PROBLEM 1 — primaryContainer was g700 (#0C8E47):
///   g400 on g700 = 1.88:1. Completely unreadable.
///   FIX: primaryContainer dark = #1A4028. g400 on it = 5.19:1 ✓
///
/// PROBLEM 2 — semi-transparent green fills were invisible:
///   g400 at alpha 0.14-0.20 on surfaceDark = 1.29-1.46:1. Invisible.
///   FIX: nav indicator  → primaryContainerDark (#1A4028, opaque)
///        chip selected  → primaryContainerDark (#1A4028, opaque)
///        chip label/icon stays g400 → 5.19:1 ✓
///
/// PROBLEM 3 — switch thumb was g400 on a g400-tinted track:
///   g400 on g400@0.3 track ≈ 1.0:1. Completely invisible.
///   FIX: active thumb  = white (textPrimaryDark)
///        active track  = g400 at alpha 0.55 on card → track CR=2.91:1 ✓
///                        white thumb on track = 4.29:1 ✓
///
/// PROBLEM 4 — progress indicator track was near-invisible:
///   g400 at alpha 0.12 on dark surface = ~1.2:1.
///   FIX: track alpha bumped to 0.28 in dark mode → ~1.9:1 (decorative) ✓
///        bar itself is always solid g400 = 7.60:1 ✓

class AppMaterialTheme {
  AppMaterialTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLOR SCHEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static ColorScheme get _lightColorScheme => ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryLight,
    onSecondary: AppColors.textOnPrimary,
    onSecondaryContainer: AppColors.secondary,
    tertiary: AppColors.accent,
    tertiaryContainer: AppColors.accentLight,
    onTertiary: AppColors.textOnPrimary,
    onTertiaryContainer: AppColors.accent,
    error: AppColors.error,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.error,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    surfaceContainerHighest: AppColors.surfaceVariant,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primaryLight,
    shadow: Colors.black.withValues(alpha: 0.08),
    scrim: Colors.black.withValues(alpha: 0.4),
  );

  static ColorScheme get _darkColorScheme => ColorScheme.dark(
    // ── Core brand ───────────────────────────────────────────────────────────
    // primary: g400 (#3CC47C). Contrast on all 3 dark surfaces ≥ 6.22:1 ✓
    primary: AppColors.primaryDarkMode,
    // onPrimary sits on the brand primary button. backgroundDark on g400 = 8.66:1 ✓
    onPrimary: AppColors.backgroundDark,
    // primaryContainer: #1A4028 — dark forest green.
    // DO NOT restore g700 — g400 on g700 = 1.88:1, which is why greens were invisible.
    primaryContainer: AppColors.primaryContainerDark,
    // onPrimaryContainer: g400 on #1A4028 = 5.19:1 ✓
    onPrimaryContainer: AppColors.primaryDarkMode,

    secondary: AppColors.secondaryDarkMode,
    secondaryContainer: AppColors.secondary.withValues(alpha: 0.25),
    onSecondary: AppColors.backgroundDark,
    onSecondaryContainer: AppColors.secondaryDarkMode,

    tertiary: AppColors.accentDarkMode,
    tertiaryContainer: AppColors.accent.withValues(alpha: 0.25),
    onTertiary: AppColors.backgroundDark,
    onTertiaryContainer: AppColors.accentDarkMode,

    // ── Status ────────────────────────────────────────────────────────────────
    // errorDarkMode (#FF6B6B) on backgroundDark = 5.94:1 ✓
    error: AppColors.errorDarkMode,
    errorContainer: AppColors.errorLightDarkMode,
    onError: AppColors.backgroundDark,
    onErrorContainer: AppColors.errorDarkMode,

    // ── Surfaces ──────────────────────────────────────────────────────────────
    surface: AppColors.surfaceDark,
    // textPrimaryDark (#F2F2F7) on surfaceDark = 13.0:1 ✓
    onSurface: AppColors.textPrimaryDark,
    // textSecondaryDark (#8E8E93) on surfaceDark = 4.8:1 ✓
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.dividerDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    inverseSurface: AppColors.textPrimaryDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.primaryContainerDark,

    shadow: Colors.black.withValues(alpha: 0.3),
    scrim: Colors.black.withValues(alpha: 0.6),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    const base = TextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.12,
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.16,
        color: primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.20,
        color: primary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.30,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.38,
        letterSpacing: 0.15,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.10,
        color: primary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: secondary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: tertiary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.5,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.5,
        color: secondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.45,
        letterSpacing: 0.5,
        color: tertiary,
      ),
    );
  }

  static TextTheme get _lightTextTheme => _buildTextTheme(
    primary: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
    tertiary: AppColors.textTertiary,
  );

  static TextTheme get _darkTextTheme => _buildTextTheme(
    primary: AppColors.textPrimaryDark,
    secondary: AppColors.textSecondaryDark,
    tertiary: AppColors.textTertiaryDark,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme cs) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return cs.primary.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.pressed)) {
            return cs.primary.withValues(alpha: 0.88);
          }
          return cs.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return cs.onPrimary.withValues(alpha: 0.6);
          }
          return cs.onPrimary;
        }),
        // White overlay on any brightness — green-on-green overlay is invisible in dark
        overlayColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.10),
        ),
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        ),
        minimumSize: WidgetStateProperty.all(Size(double.infinity, 56.h)),
        maximumSize: WidgetStateProperty.all(const Size(double.infinity, 64)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlatformAdaptive.buttonRadiusMd,
            ),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
        animationDuration: const Duration(milliseconds: 180),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme cs) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return cs.primary.withValues(alpha: 0.38);
          }
          return cs.primary;
        }),
        overlayColor: WidgetStateProperty.all(
          cs.primary.withValues(alpha: 0.08),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        ),
        minimumSize: WidgetStateProperty.all(Size(0, 56.h)),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: cs.primary.withValues(alpha: 0.2),
              width: PlatformAdaptive.outlineBorderWidth,
            );
          }
          return BorderSide(
            color: cs.primary,
            width: PlatformAdaptive.outlineBorderWidth,
          );
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              PlatformAdaptive.buttonRadiusMd,
            ),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme cs) {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return cs.primary.withValues(alpha: 0.38);
          }
          return cs.primary;
        }),
        overlayColor: WidgetStateProperty.all(
          cs.primary.withValues(alpha: 0.08),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  static IconButtonThemeData _buildIconButtonTheme(Color iconColor) {
    return IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return iconColor.withValues(alpha: 0.38);
          }
          return iconColor;
        }),
        overlayColor: WidgetStateProperty.all(
          iconColor.withValues(alpha: 0.08),
        ),
        iconSize: WidgetStateProperty.all(24.sp),
        minimumSize: WidgetStateProperty.all(Size(44.w, 44.w)),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATION
  // ═══════════════════════════════════════════════════════════════════════════

  static InputDecorationTheme _buildInputDecorationTheme({
    required Color fillColor,
    required Color focusColor,
    required Color errorColor,
    required Color hintColor,
    required Color labelColor,
    required Color prefixDefault,
  }) {
    final radius = BorderRadius.circular(PlatformAdaptive.inputRadius);
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: labelColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: focusColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      errorStyle: TextStyle(
        color: errorColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
      helperStyle: TextStyle(color: hintColor, fontSize: 12.sp),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return focusColor;
        if (states.contains(WidgetState.error)) return errorColor;
        return prefixDefault;
      }),
      suffixIconColor: prefixDefault,
      isDense: false,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOGGLE CONTROLS
  //
  // DARK-MODE SWITCH RULES (verified):
  //   active track:  g400 at alpha 0.55 on card   → track CR=2.91:1 ✓ (UI component)
  //   active thumb:  WHITE (#F2F2F7)               → white on track  = 4.29:1 ✓
  //   DO NOT use g400 as the active thumb — g400 on g400-tinted track ≈ 1.0:1 ✗
  //   inactive track: grey at 0.25 alpha on card   → subtle but readable shape ✓
  //   inactive thumb: textTertiaryDark (#636366)   → 3.0:1 on card ✓
  // ═══════════════════════════════════════════════════════════════════════════

  static SwitchThemeData _buildSwitchTheme({
    required Color primary,
    required bool isDark,
  }) {
    return SwitchThemeData(
      // Active thumb: white in dark mode (contrasts with green track); green in light (on white track it's fine)
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return isDark ? AppColors.textPrimaryDark : AppColors.textOnPrimary;
        }
        return isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
      }),
      // Active track: alpha 0.55 in dark → 2.91:1 vs card ✓; alpha 0.30 in light
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: isDark ? 0.55 : 0.30);
        }
        return (isDark ? AppColors.textTertiaryDark : AppColors.textTertiary)
            .withValues(alpha: isDark ? 0.25 : 0.15);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  static CheckboxThemeData _buildCheckboxTheme(Color primary, Color border) =>
      CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      );

  static RadioThemeData _buildRadioTheme(Color primary, Color inactive) =>
      RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : inactive,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // PROGRESS INDICATORS
  //
  // Track alpha:  0.28 in dark → ~1.9:1 vs surface (decorative shape only) ✓
  //              0.12 in light → fine on white background
  // Bar itself: always solid primary → 7.60:1 in dark ✓
  // ═══════════════════════════════════════════════════════════════════════════

  static ProgressIndicatorThemeData _buildProgressTheme(
    Color primary,
    Color surface,
    bool isDark,
  ) => ProgressIndicatorThemeData(
    color: primary,
    linearTrackColor: primary.withValues(alpha: isDark ? 0.28 : 0.12),
    circularTrackColor: primary.withValues(alpha: isDark ? 0.28 : 0.12),
    linearMinHeight: 4.h,
    refreshBackgroundColor: surface,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TRANSITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // ASSEMBLY
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData _build({required ColorScheme cs, required TextTheme tt}) {
    final isDark = cs.brightness == Brightness.dark;

    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final textTertiary = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;
    final surfaceBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;

    return ThemeData(
      useMaterial3: true,
      brightness: cs.brightness,
      fontFamily: 'Inter',
      colorScheme: cs,
      scaffoldBackgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.background,
      textTheme: tt,
      pageTransitionsTheme: _pageTransitionsTheme,

      // ─── App Bar ───
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: PlatformAdaptive.isApple ? 0 : 0.5,
        centerTitle: PlatformAdaptive.isApple,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 24.sp),
        actionsIconTheme: IconThemeData(color: textPrimary, size: 24.sp),
        toolbarHeight: PlatformAdaptive.isApple ? 44 : 56,
      ),

      // ─── Buttons ───
      elevatedButtonTheme: _buildElevatedButtonTheme(cs),
      outlinedButtonTheme: _buildOutlinedButtonTheme(cs),
      textButtonTheme: _buildTextButtonTheme(cs),
      iconButtonTheme: _buildIconButtonTheme(textPrimary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: PlatformAdaptive.isApple ? 0 : 4,
        focusElevation: PlatformAdaptive.isApple ? 0 : 6,
        hoverElevation: PlatformAdaptive.isApple ? 0 : 8,
        highlightElevation: PlatformAdaptive.isApple ? 0 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            PlatformAdaptive.isApple ? 20.r : 16.r,
          ),
        ),
      ),

      // ─── Inputs ───
      inputDecorationTheme: _buildInputDecorationTheme(
        fillColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariant,
        focusColor: cs.primary,
        errorColor: cs.error,
        hintColor: textTertiary,
        labelColor: textSecondary,
        prefixDefault: textSecondary,
      ),

      // ─── Cards ───
      cardTheme: CardThemeData(
        elevation: PlatformAdaptive.isApple ? 0 : (isDark ? 0 : 1),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusLg),
          side: BorderSide(
            color: borderColor.withValues(
              alpha: PlatformAdaptive.isApple ? 0.5 : 0.8,
            ),
            width: 0.5,
          ),
        ),
        color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        margin: EdgeInsets.zero,
      ),

      // ─── Toggles ───
      switchTheme: _buildSwitchTheme(primary: cs.primary, isDark: isDark),
      checkboxTheme: _buildCheckboxTheme(cs.primary, borderColor),
      radioTheme: _buildRadioTheme(cs.primary, textTertiary),

      // ─── Navigation bar ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceBg,
        selectedItemColor: cs.primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceBg.withValues(
          alpha: PlatformAdaptive.navBarAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        // FIX: opaque container instead of invisible semi-transparent tint.
        // In dark mode: #1A4028 indicator bg with g400 icon on top = 5.19:1 ✓
        // In light mode: primary at 14% alpha on white ≈ light-green pill (fine on light)
        indicatorColor: isDark
            ? AppColors.primaryContainerDark
            : cs.primary.withValues(alpha: 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: PlatformAdaptive.isApple ? 49 : 72.h,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: PlatformAdaptive.isApple ? 11.sp : 12.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? cs.primary : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? cs.primary : textSecondary,
            size: 24.sp,
          );
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: textTertiary,
        indicatorColor: cs.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: dividerColor,
        dividerHeight: 1,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.all(
          cs.primary.withValues(alpha: 0.08),
        ),
        splashFactory: PlatformAdaptive.isApple
            ? NoSplash.splashFactory
            : InkSparkle.splashFactory,
      ),

      // ─── Chips ───
      chipTheme: ChipThemeData(
        backgroundColor:
            (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant)
                .withValues(alpha: PlatformAdaptive.isApple ? 0.72 : 1.0),
        // FIX: opaque container instead of nearly-invisible alpha tint in dark mode.
        // g400 label/checkmark on #1A4028 = 5.19:1 ✓
        selectedColor: isDark
            ? AppColors.primaryContainerDark
            : cs.primary.withValues(alpha: 0.15),
        disabledColor:
            (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant)
                .withValues(alpha: 0.5),
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: cs.primary,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.chipRadius),
          side: PlatformAdaptive.isApple
              ? BorderSide(
                  color: borderColor.withValues(alpha: 0.15),
                  width: 0.5,
                )
              : BorderSide.none,
        ),
        showCheckmark: true,
        checkmarkColor: cs.primary,
      ),

      // ─── Surfaces ───
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceElevatedDark.withValues(
                alpha: PlatformAdaptive.isApple ? 0.95 : 1.0,
              )
            : AppColors.textPrimary.withValues(
                alpha: PlatformAdaptive.isApple ? 0.9 : 1.0,
              ),
        contentTextStyle: TextStyle(color: textPrimary, fontSize: 14.sp),
        actionTextColor: cs.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: PlatformAdaptive.snackBarElevation,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceBg.withValues(
          alpha: PlatformAdaptive.sheetAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PlatformAdaptive.sheetRadius),
          ),
        ),
        elevation: PlatformAdaptive.sheetElevation,
        showDragHandle: true,
        dragHandleColor: textTertiary.withValues(alpha: 0.4),
        dragHandleSize: Size(36.w, 4.h),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceBg.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        elevation: PlatformAdaptive.dialogElevation,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textSecondary,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surface,
        elevation: PlatformAdaptive.isApple ? 0 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
          side: PlatformAdaptive.isApple
              ? BorderSide(color: borderColor.withValues(alpha: 0.3))
              : BorderSide.none,
        ),
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color:
              (isDark ? AppColors.surfaceElevatedDark : AppColors.textPrimary)
                  .withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: TextStyle(
          color: isDark ? textPrimary : Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
      ),
      progressIndicatorTheme: _buildProgressTheme(
        cs.primary,
        surfaceBg,
        isDark,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          textTertiary.withValues(alpha: 0.35),
        ),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: Radius.circular(4.r),
        thickness: WidgetStateProperty.all(
          PlatformAdaptive.isApple ? 3.0 : 4.0,
        ),
        thumbVisibility: WidgetStateProperty.all(false),
        interactive: true,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        minVerticalPadding: 12.h,
        iconColor: textSecondary,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.radiusMd),
        ),
        titleTextStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: cs.error,
        textColor: Colors.white,
        textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
        smallSize: 8.w,
        largeSize: 18.w,
      ),
      splashFactory: PlatformAdaptive.isApple
          ? NoSplash.splashFactory
          : InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  // ─── Public entrypoints ───────────────────────────────────────────────────
  static ThemeData get lightTheme =>
      _build(cs: _lightColorScheme, tt: _lightTextTheme);
  static ThemeData get darkTheme =>
      _build(cs: _darkColorScheme, tt: _darkTextTheme);
}

// ─────────────────────────────────────────────────────────────────────────────
// BUILD-CONTEXT EXTENSIONS
// ─────────────────────────────────────────────────────────────────────────────

extension AppMaterialThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  TextStyle get textDisplayLg => textTheme.displayLarge!;
  TextStyle get textHeadlineMd => textTheme.headlineMedium!;
  TextStyle get textTitleLg => textTheme.titleLarge!;
  TextStyle get textTitleMd => textTheme.titleMedium!;
  TextStyle get textTitleSm => textTheme.titleSmall!;
  TextStyle get textBodyLg => textTheme.bodyLarge!;
  TextStyle get textBodyMd => textTheme.bodyMedium!;
  TextStyle get textBodySm => textTheme.bodySmall!;
  TextStyle get textLabelLg => textTheme.labelLarge!;
  TextStyle get textLabelMd => textTheme.labelMedium!;
  TextStyle get textLabelSm => textTheme.labelSmall!;

  TextStyle get textSmallBold =>
      textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700);
  TextStyle get textCaption => textTheme.labelSmall!;
  TextStyle get textOverline => textTheme.labelSmall!.copyWith(
    letterSpacing: 1,
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
  );

  LinearGradient get greenGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
  );
}
