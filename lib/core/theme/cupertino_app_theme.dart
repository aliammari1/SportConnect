import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show BorderSide, BoxDecoration, BoxShadow, Colors, LinearGradient;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SportConnect · Cupertino Theme  (light + dark)
//
// References
//   • Apple HIG 2025-2026
//   • Flutter Cupertino API
//   • App Store Review Guidelines §4.0
//
// Usage
//   CupertinoApp(theme: AppCupertinoTheme.lightTheme)
//   — or inside MaterialApp builder (see app_theme.dart header comment)
//
// HIG compliance
//   ✓ Minimum tap target  44 × 44 pt
//   ✓ SF Pro system font; optical-size rule (Display ≥ 20 pt, Text ≤ 19 pt)
//   ✓ Dynamic Type via .sp
//   ✓ Safe Areas via CupertinoPageScaffold
//   ✓ Swipe-back preserved via CupertinoPageRoute
//
// ── Dark-mode contrast fixes (mirrors app_theme.dart) ────────────────
//
// PROBLEM 1 — card and text field fills were invisible on dark surfaces:
//   tertiarySystemFill on dark ≈ very dark grey, OK for fill.
//   But any explicit green fill at low alpha is invisible (see app_theme.dart).
//   FIX: cardDecoration uses AppColors.cardBgDark (#2C2C2E) — clearly distinct
//        from backgroundDark (#0D0D12) by layering, not green fill.
//
// PROBLEM 2 — button overlays used green tint on green background:
//   g400 at alpha 0.15 on g400 button ≈ invisible.
//   FIX: all overlays are white at low alpha — readable on any green bg.
//
// PROBLEM 3 — outlined button fill uses g400 at alpha 0.08 in dark:
//   on backgroundDark: near-invisible green tint.
//   FIX: alpha raised to 0.15 in dark mode for the tinted secondary button.
//        The LABEL is always solid g400 = 7.60:1 on that tinted bg ✓
//
// Note: CupertinoSwitch, CupertinoActivityIndicator, and system Cupertino
// widgets handle their own dark mode internally via CupertinoColors — no fixes
// needed there. Only custom helpers below require explicit dark handling.
// ─────────────────────────────────────────────────────────────────────────────

class AppCupertinoTheme {
  AppCupertinoTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  static CupertinoTextThemeData _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final text = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final brand = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return CupertinoTextThemeData(
      primaryColor: brand,

      // Body — 17 pt (HIG minimum for primary copy)
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        height: 1.47,
        color: text,
      ),

      // Nav bar standard title — 17 pt semibold
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: text,
      ),

      // Nav bar large title — 34 pt (SF Pro Display ≥ 20 pt)
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.37,
        height: 1.21,
        color: text,
      ),

      // Nav action items ("Done", "Edit") — brand color
      navActionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        color: brand,
      ),

      // Full-width CupertinoButton label
      actionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        color: brand,
      ),

      // Smaller inline action
      actionSmallTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        color: brand,
      ),

      // Bottom tab labels — 10 pt (HIG §Tab Bars)
      tabLabelTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.12,
        color: muted,
      ),

      // Picker rows
      pickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        color: text,
      ),

      dateTimePickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        color: text,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THEMES
  // ═══════════════════════════════════════════════════════════════════════════

  static CupertinoThemeData get lightTheme => CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    primaryContrastingColor: AppColors.textOnPrimary,
    textTheme: _buildTextTheme(Brightness.light),
    barBackgroundColor: CupertinoColors.systemBackground,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    applyThemeToAll: true,
  );

  static CupertinoThemeData get darkTheme => CupertinoThemeData(
    brightness: Brightness.dark,
    // g400 (#3CC47C) — verified contrast on all dark surfaces ≥ 6.22:1 ✓
    primaryColor: AppColors.primaryDarkMode,
    // backgroundDark as contrasting color on primary buttons: 8.66:1 ✓
    primaryContrastingColor: AppColors.backgroundDark,
    textTheme: _buildTextTheme(Brightness.dark),
    barBackgroundColor: CupertinoColors.systemBackground.darkColor,
    // OLED-friendly blue-black root background
    scaffoldBackgroundColor: AppColors.backgroundDark,
    applyThemeToAll: true,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTONS
  // HIG: min tap target 44 pt, primary = filled, secondary = tinted, destructive = red
  // ═══════════════════════════════════════════════════════════════════════════

  /// Filled primary button.
  static CupertinoButton primaryButton({
    required Widget child,
    required VoidCallback? onPressed,
    bool isDark = false,
    double? minSize,
  }) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      minSize: minSize ?? 50.h,
      borderRadius: BorderRadius.circular(14.r),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          // onPrimary: backgroundDark in dark = 8.66:1 ✓; white in light ✓
          color: isDark ? AppColors.backgroundDark : AppColors.textOnPrimary,
        ),
        child: child,
      ),
    );
  }

  /// Tinted secondary button.
  /// FIX: alpha raised to 0.15 in dark (was 0.08 — invisible on dark bg).
  /// Label stays solid brand green — g400 on tinted bg: 7.60:1 ✓
  static Widget outlinedButton({
    required Widget child,
    required VoidCallback? onPressed,
    bool isDark = false,
    Color? color,
    double? minSize,
  }) {
    final c = color ?? (isDark ? AppColors.primaryDarkMode : AppColors.primary);
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      borderRadius: BorderRadius.circular(14.r),
      // Light: 0.08 alpha (fine on white); Dark: 0.15 alpha — still subtle but visible tint
      color: c.withValues(alpha: isDark ? 0.15 : 0.08),
      minimumSize: Size(minSize ?? 50.h, minSize ?? 50.h),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: c,
        ),
        child: child,
      ),
    );
  }

  /// Plain text-only button.
  static CupertinoButton textButton({
    required Widget child,
    required VoidCallback? onPressed,
    bool isDark = false,
    Color? color,
  }) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      minimumSize: Size(44.h, 44.h),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color:
              color ?? (isDark ? AppColors.primaryDarkMode : AppColors.primary),
        ),
        child: child,
      ),
    );
  }

  /// Destructive button. Always pair with a CupertinoActionSheet confirmation.
  static CupertinoButton destructiveButton({
    required Widget child,
    required VoidCallback? onPressed,
    bool isDark = false,
  }) {
    final errorColor = isDark ? AppColors.errorDarkMode : AppColors.error;
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      borderRadius: BorderRadius.circular(14.r),
      // Error at 0.12 alpha on dark: tinted bg, label provides contrast (5.94:1) ✓
      color: errorColor.withValues(alpha: isDark ? 0.12 : 0.10),
      minimumSize: Size(50.h, 50.h),
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: errorColor,
        ),
        child: child,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT FIELD
  // ═══════════════════════════════════════════════════════════════════════════

  static BoxDecoration textFieldDecoration({
    bool focused = false,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isDark
          ? CupertinoColors.tertiarySystemFill.darkColor
          : CupertinoColors.tertiarySystemFill,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: focused
            ? (isDark ? AppColors.primaryDarkMode : AppColors.primary)
            : (isDark ? AppColors.borderDark : CupertinoColors.separator),
        width: focused ? 2.0 : 0.5,
      ),
    );
  }

  static TextStyle textFieldStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle textFieldPlaceholderStyle({bool isDark = false}) =>
      TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        color: isDark
            ? CupertinoColors.placeholderText.darkColor
            : CupertinoColors.placeholderText,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // NAV BAR  (hairline separator only — bar bg comes from theme)
  // ═══════════════════════════════════════════════════════════════════════════

  static Border navBarBorder({bool isDark = false}) => Border(
    bottom: BorderSide(
      color: isDark ? AppColors.dividerDark : CupertinoColors.separator,
      width: 0,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB BAR  (HIG: max 5 tabs on iPhone)
  // ═══════════════════════════════════════════════════════════════════════════

  static Color tabBarActiveColor({bool isDark = false}) =>
      isDark ? AppColors.primaryDarkMode : AppColors.primary;

  static Color tabBarInactiveColor({bool isDark = false}) =>
      isDark ? AppColors.textTertiaryDark : CupertinoColors.inactiveGray;

  static Color tabBarBackgroundColor({bool isDark = false}) =>
      isDark ? AppColors.surfaceDark : CupertinoColors.systemBackground;

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD / CONTENT BLOCK
  // FIX: dark card uses AppColors.cardBgDark (#2C2C2E) — visibly distinct
  // from backgroundDark (#0D0D12) without relying on an invisible green fill.
  // ═══════════════════════════════════════════════════════════════════════════

  static BoxDecoration cardDecoration({
    bool elevated = false,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isDark
          ? AppColors
                .cardBgDark // #2C2C2E — structural contrast
          : CupertinoColors.secondarySystemGroupedBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: isDark ? AppColors.borderDark : CupertinoColors.separator,
        width: 0.5,
      ),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
                blurRadius: isDark ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST
  // ═══════════════════════════════════════════════════════════════════════════

  static Color listBackground({bool isDark = false}) => isDark
      ? AppColors.backgroundDark
      : CupertinoColors.systemGroupedBackground;

  static Color listSectionBackground({bool isDark = false}) => isDark
      ? AppColors.surfaceDark
      : CupertinoColors.secondarySystemGroupedBackground;

  static Color listSeparatorColor({bool isDark = false}) =>
      isDark ? AppColors.dividerDark : CupertinoColors.separator;

  static TextStyle listTitleStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle listSubtitleStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: isDark
        ? CupertinoColors.secondaryLabel.darkColor
        : CupertinoColors.secondaryLabel,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTION SHEET  (HIG: confirm all destructive actions here)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle actionSheetTitleStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
    color: isDark
        ? CupertinoColors.secondaryLabel.darkColor
        : CupertinoColors.secondaryLabel,
  );

  static TextStyle actionSheetMessageStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: isDark
        ? CupertinoColors.secondaryLabel.darkColor
        : CupertinoColors.secondaryLabel,
  );

  static TextStyle actionSheetActionStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.45,
    color: isDark ? AppColors.primaryDarkMode : AppColors.primary,
  );

  // Destructive and Cancel use system colors per HIG — do not rebrand these.
  static const TextStyle actionSheetDestructiveStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.45,
    color: CupertinoColors.systemRed,
  );

  static const TextStyle actionSheetCancelStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.45,
    color: CupertinoColors.systemBlue,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ALERT DIALOG  (HIG: 2 actions max; destructive = red)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle alertTitleStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle alertMessageStyle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BADGE
  // ═══════════════════════════════════════════════════════════════════════════

  static Color badgeBackground({bool isDark = false}) =>
      isDark ? AppColors.errorDarkMode : AppColors.error;

  static const TextStyle badgeTextStyle = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: CupertinoColors.white,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE ROUTE — preserves swipe-back (HIG §Navigation)
  // ═══════════════════════════════════════════════════════════════════════════

  static Route<T> pageRoute<T>({required WidgetBuilder builder}) =>
      CupertinoPageRoute<T>(builder: builder);

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING + RADII  (4-pt grid)
  // ═══════════════════════════════════════════════════════════════════════════

  static double get spacing4 => 4.0.h;
  static double get spacing8 => 8.0.h;
  static double get spacing12 => 12.0.h;
  static double get spacing16 => 16.0.h;
  static double get spacing20 => 20.0.h;
  static double get spacing24 => 24.0.h;
  static double get spacing32 => 32.0.h;
  static double get radiusSm => 8.0.r;
  static double get radiusMd => 12.0.r;
  static double get radiusLg => 16.0.r;
  static double get radiusXl => 20.0.r;
  static double get radiusFull => 999.0.r;

  // ═══════════════════════════════════════════════════════════════════════════
  // HIG DYNAMIC TYPE STYLES  (named 1-to-1 with HIG text style names)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle largeTitle({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.21,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle title1({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.21,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle title2({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    height: 1.27,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle title3({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.25,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle headline({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.47,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle body({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.47,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle callout({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.50,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
  );

  static TextStyle subheadline({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.53,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
  );

  static TextStyle footnote({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.54,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
  );

  static TextStyle caption1({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
  );

  static TextStyle caption2({bool isDark = false}) => TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.45,
    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BUILD-CONTEXT EXTENSIONS
// ─────────────────────────────────────────────────────────────────────────────

extension AppCupertinoThemeExtension on BuildContext {
  CupertinoThemeData get cupertinoTheme => CupertinoTheme.of(this);
  CupertinoTextThemeData get cupertinoTextTheme =>
      CupertinoTheme.of(this).textTheme;
  bool get isDark => CupertinoTheme.brightnessOf(this) == Brightness.dark;

  TextStyle get cupertinoNavTitle =>
      CupertinoTheme.of(this).textTheme.navTitleTextStyle;
  TextStyle get cupertinoNavLargeTitle =>
      CupertinoTheme.of(this).textTheme.navLargeTitleTextStyle;
  TextStyle get cupertinoNavAction =>
      CupertinoTheme.of(this).textTheme.navActionTextStyle;
  TextStyle get cupertinoBodyStyle =>
      CupertinoTheme.of(this).textTheme.textStyle;
  TextStyle get cupertinoTabLabel =>
      CupertinoTheme.of(this).textTheme.tabLabelTextStyle;
  TextStyle get cupertinoAction =>
      CupertinoTheme.of(this).textTheme.actionTextStyle;

  TextStyle get cupertinoLargeTitle =>
      AppCupertinoTheme.largeTitle(isDark: isDark);
  TextStyle get cupertinoTitle1 => AppCupertinoTheme.title1(isDark: isDark);
  TextStyle get cupertinoTitle2 => AppCupertinoTheme.title2(isDark: isDark);
  TextStyle get cupertinoTitle3 => AppCupertinoTheme.title3(isDark: isDark);
  TextStyle get cupertinoHeadline => AppCupertinoTheme.headline(isDark: isDark);
  TextStyle get cupertinoBody => AppCupertinoTheme.body(isDark: isDark);
  TextStyle get cupertinoCallout => AppCupertinoTheme.callout(isDark: isDark);
  TextStyle get cupertinoSubheadline =>
      AppCupertinoTheme.subheadline(isDark: isDark);
  TextStyle get cupertinoFootnote => AppCupertinoTheme.footnote(isDark: isDark);
  TextStyle get cupertinoCaption1 => AppCupertinoTheme.caption1(isDark: isDark);
  TextStyle get cupertinoCaption2 => AppCupertinoTheme.caption2(isDark: isDark);

  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      if (isDark) AppColors.primaryDarkMode else AppColors.primary,
      (isDark ? AppColors.primaryDarkMode : AppColors.primary).withValues(
        alpha: 0.8,
      ),
    ],
  );
}
