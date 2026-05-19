import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

/// SportConnect Premium Color Palette
/// Modern carpooling app design system - Light Classy Green Theme
/// Lighter Emerald, Sage, Fresh Green tones for a clean, modern, premium feel
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMARY BRAND COLORS - Light Classy Green (Fresh & Premium)
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF40916C); // Emerald Green (lighter)
  static const Color primaryLight = Color(0xFF52B788); // Fresh Emerald
  static const Color primaryDark = Color(0xFF2D6A4F); // Deep Emerald
  static const Color primarySurface = Color(0xFFE8F5E9); // Very Light Green

  // ═══════════════════════════════════════════════════════════════
  // SECONDARY - Sage Green (Elegant & Light)
  // ═══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFF74C69D); // Sage Green
  static const Color secondaryLight = Color(0xFF95D5B2); // Light Sage
  static const Color secondaryDark = Color(0xFF52B788); // Emerald Sage
  static const Color secondarySurface = Color(0xFFF0FFF4); // Mint Surface

  // ═══════════════════════════════════════════════════════════════
  // ACCENT - Mint Green (Subtle & Fresh)
  // ═══════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFF95D5B2); // Mint Green
  static const Color accentLight = Color(0xFFB7E4C7); // Light Mint
  static const Color accentDark = Color(0xFF74C69D); // Sage
  static const Color accentSurface = Color(0xFFF5FBF7); // Mint Mist

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  // Success - Fresh Green
  static const Color success = Color(0xFF40916C);
  static const Color successLight = Color(0xFF52B788);
  static const Color successDark = Color(0xFF2D6A4F);
  static const Color successSurface = Color(0xFFE8F5E9);

  // Warning - Warm Amber
  static const Color warning = Color(0xFFD4A373);
  static const Color warningLight = Color(0xFFE6BE8A);
  static const Color warningDark = Color(0xFFBC8A5F);
  static const Color warningSurface = Color(0xFFFDF6EE);

  // Error - Muted Rose
  static const Color error = Color(0xFFC1666B);
  static const Color errorLight = Color(0xFFD4878B);
  static const Color errorDark = Color(0xFFA84C51);
  static const Color errorSurface = Color(0xFFFAEBEC);

  // Info - Slate Blue
  static const Color info = Color(0xFF4A7C88);
  static const Color infoLight = Color(0xFF6B9AA6);
  static const Color infoDark = Color(0xFF3A616B);
  static const Color infoSurface = Color(0xFFEBF2F4);

  // ═══════════════════════════════════════════════════════════════
  // NEUTRAL COLORS - Clean & Modern
  // ═══════════════════════════════════════════════════════════════
  static const Color background = Color(
    0xFFF8FAF9,
  ); // Off White with green tint
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF1F5F3); // Light Gray Green
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF8FAF9);

  // Text Colors - High Contrast
  static const Color textPrimary = Color(0xFF1B2E24); // Dark Green Black
  static const Color textSecondary = Color(0xFF5C7266); // Muted Green Gray
  static const Color textTertiary = Color(0xFF8FA399); // Light Green Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8C7BF);

  // Input Field
  static const Color inputFill = Color(0xFFF5F8F6);
  static const Color inputBorder = Color(0xFFD8E0DB);
  static const Color inputFocusBorder = Color(0xFF40916C);

  // Border & Divider
  static const Color border = Color(0xFFD8E0DB);
  static const Color divider = Color(0xFFE8EDE9);
  static const Color borderLight = Color(0xFFEDF1EE);

  // Shimmer / Loading
  static const Color shimmer = Color(0xFFE8EDE9);
  static const Color shimmerHighlight = Color(0xFFF5F8F6);

  // ═══════════════════════════════════════════════════════════════
  // GAMIFICATION COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color xpGold = Color(0xFF52B788); // Emerald XP
  static const Color xpPurple = Color(0xFF7B6D8D);
  static const Color levelBronze = Color(0xFFB7E4C7); // Light Mint (Level 1)
  static const Color levelSilver = Color(0xFF95D5B2); // Soft Sage (Level 2)
  static const Color levelGold = Color(0xFF74C69D); // Sage Green (Level 3)
  static const Color levelPlatinum = Color(0xFF40916C); // Emerald (Level 4)
  static const Color levelDiamond = Color(0xFF2D6A4F); // Forest Green (Level 5)
  static const Color levelMaster = Color(0xFF1B4332); // Deep Forest

  // Rating Stars
  static const Color starFilled = Color(0xFFD4A373);
  static const Color starEmpty = Color(0xFFD8E0DB);

  // Status Colors
  static const Color online = Color(0xFF40916C);
  static const Color offline = Color(0xFF8FA399);
  static const Color busy = Color(0xFFD4A373);
  static const Color away = Color(0xFFC1666B);

  // ═══════════════════════════════════════════════════════════════
  // RIDE STATUS COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color rideActive = Color(0xFF40916C);
  static const Color ridePending = Color(0xFFD4A373);
  static const Color rideCancelled = Color(0xFFC1666B);
  static const Color rideCompleted = Color(0xFF4A7C88);
  static const Color rideScheduled = Color(0xFF7B6D8D);

  // ═══════════════════════════════════════════════════════════════
  // MAP COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color mapRoute = Color(0xFF40916C); // Emerald Green
  static const Color mapRouteAlt = Color(0xFF52B788); // Light Emerald
  static const Color mapPickup = Color(0xFF52B788);
  static const Color mapDropoff = Color(0xFFC1666B);
  static const Color mapDriver = Color(0xFF40916C); // Emerald Green

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF0A1410);
  static const Color darkSurface = Color(0xFF121F1A);
  static const Color darkSurfaceVariant = Color(0xFF1A2D25);
  static const Color darkCardBg = Color(0xFF121F1A);
  static const Color darkTextPrimary = Color(0xFFE8F0EB);
  static const Color darkTextSecondary = Color(0xFF8FA399);
  static const Color darkBorder = Color(0xFF2D4A3C);

  // ═══════════════════════════════════════════════════════════════
  // PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, success],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF74C69D), Color(0xFF52B788), Color(0xFF40916C)],
  );

  // Hero gradient for headers - Light Classy Green
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF40916C), Color(0xFF52B788), Color(0xFF74C69D)],
  );

  // Nature gradient - Fresh green tones
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D6A4F), Color(0xFF40916C), Color(0xFF52B788)],
  );

  // Alternative hero for variety - Sage tones
  static const LinearGradient heroGradientAlt = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52B788), Color(0xFF74C69D), Color(0xFF95D5B2)],
  );

  // Card shimmer gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F8F6)],
  );

  // Glass effect gradient — Liquid Glass
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
  );

  // Liquid Glass highlight gradient — for glass container top-left shimmer
  static LinearGradient get liquidGlassHighlight => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFFFFFFF).withValues(alpha: 0.30),
      const Color(0xFFFFFFFF).withValues(alpha: 0),
      const Color(0xFFFFFFFF).withValues(alpha: 0),
      const Color(0xFFFFFFFF).withValues(alpha: 0.08),
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );

  // Liquid Glass surface — translucent white for glass panels
  static Color get liquidGlassSurface =>
      const Color(0xFFFFFFFF).withValues(alpha: 0.68);

  // Liquid Glass border — subtle glass edge
  static Color get liquidGlassBorder =>
      const Color(0xFFFFFFFF).withValues(alpha: 0.20);

  // ═══════════════════════════════════════════════════════════════
  // LEVEL GRADIENTS FOR AVATARS
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient diamondGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA3C4BC), Color(0xFF7BA39A), Color(0xFFA3C4BC)],
  );

  static const LinearGradient platinumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCDD5D0), Color(0xFFADB8B3), Color(0xFFCDD5D0)],
  );

  static const LinearGradient goldGradientLevel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF52B788), Color(0xFF40916C), Color(0xFF52B788)],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF95D5B2), Color(0xFF74C69D), Color(0xFF95D5B2)],
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB7E4C7), Color(0xFF95D5B2), Color(0xFFB7E4C7)],
  );

  // ═══════════════════════════════════════════════════════════════
  // ECO-FRIENDLY COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color ecoGreen = Color(0xFF2D6A4F);
  static const Color ecoLeaf = Color(0xFF40916C);
  static const Color distanceGreen = Color(0xFF2D6A4F);

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SportConnect · Design Tokens  (app_colors.dart)
  //
  // Every dark-mode token has its contrast ratio verified against
  // all three dark surfaces via WCAG 2.2 relative-luminance formula.
  //
  // Minimum targets
  //   ≥ 4.5:1  normal text and icons
  //   ≥ 3.0:1  large text (≥ 18 pt) and UI component boundaries
  //   ≥ 1.5:1  decorative fills (nav pill, chip bg) — the icon/label is
  //            the accessible signal; the fill adds shape affordance only
  //
  // Dark surface stack
  //   backgroundDark  #0D0D12  [OLED-friendly blue-black]
  //   surfaceDark     #1C1C1E  [iOS systemBackground dark]
  //   cardBgDark      #2C2C2E  [iOS secondarySystemBackground dark]
  //   surfaceElevated #3A3A3C  [iOS tertiarySystemBackground dark]
  //
  // ── Key dark-mode contrast proofs ────────────────────────────────────
  //   primaryDarkMode (#3CC47C) on backgroundDark   = 8.66:1  ✓
  //   primaryDarkMode (#3CC47C) on surfaceDark       = 7.60:1  ✓
  //   primaryDarkMode (#3CC47C) on cardBgDark        = 6.22:1  ✓
  //   primaryContainerDark (#1A4028) — CONTAINER BG:
  //     primaryDarkMode on it                        = 5.19:1  ✓
  //     primaryLightDarkMode (#65D197) on it         = 6.15:1  ✓
  //   errorDarkMode (#FF6B6B) on backgroundDark      = 5.94:1  ✓
  //   textPrimaryDark (#F2F2F7) on backgroundDark    = 14.8:1  ✓
  //   textSecondaryDark (#8E8E93) on surfaceDark      = 4.8:1   ✓
  //
  // ── Why NOT use semi-transparent green fills in dark mode ─────────────
  //   g400 at alpha 0.20 on surfaceDark   → rendered tint vs surface =  1.46:1  ✗
  //   g400 at alpha 0.14 on surfaceDark   → rendered tint vs surface =  1.29:1  ✗
  //   Even alpha 0.50                     → tint vs surface          =  2.86:1  ✗
  //   Alpha must be ≥ 0.55 to reach 3:1 for UI component boundaries (switch track).
  //   For chip/nav fills, use primaryContainerDark (opaque) instead.
  // ─────────────────────────────────────────────────────────────────────────────

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND PRIMITIVES  (never reference these directly in widgets)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color _green300 = Color(0xFF65D197);
  static const Color _green400 = Color(0xFF3CC47C);

  // Dark-mode container: dark enough for g400 (5.19:1) and g300 (6.15:1) on top.
  // DO NOT use g700 (#0C8E47) as a container in dark mode —
  // g400 on g700 = 1.88:1. It was the root cause of the contrast failures.
  static const Color _green900dk = Color(0xFF1A4028);

  static const Color _blue200 = Color(0xFFB3CAFF);
  static const Color _amber200 = Color(0xFFFFDC82);

  static const Color _neutral300 = Color(0xFFD1D5DB);
  static const Color _neutral700 = Color(0xFF374151);
  static const Color _neutral900 = Color(0xFF111827);

  static const Color _dark50 = Color(0xFF1C1C1E);
  static const Color _dark100 = Color(0xFF2C2C2E);
  static const Color _dark200 = Color(0xFF3A3A3C);
  static const Color _dark300 = Color(0xFF48484A);
  static const Color _darkBg = Color(0xFF0D0D12);

  // Error: #FF6B6B on #0D0D12 = 5.94:1 ✓  (lighter than _red500 for dark legibility)
  static const Color _redDark = Color(0xFFFF6B6B);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC  —  LIGHT
  // ═══════════════════════════════════════════════════════════════════════════

  // static const Color primary        = _green500;   // on white = 7.46:1 ✓
  // static const Color primaryLight   = _green300;
  // static const Color primaryDark    = _green700;

  // static const Color secondary      = _blue500;
  // static const Color secondaryLight = _blue200;
  // static const Color accent         = _amber500;
  // static const Color accentLight    = _amber200;

  // static const Color error          = _red500;
  // static const Color errorLight     = _red100;
  // static const Color success        = Color(0xFF16A34A);
  // static const Color successLight   = Color(0xFFECFDF5);
  // static const Color warning        = _amber500;
  // static const Color warningLight   = Color(0xFFFFFBEB);

  // static const Color textPrimary    = _neutral900;  // 15.3:1 ✓
  // static const Color textSecondary  = _neutral600;  //  7.0:1 ✓
  // static const Color textTertiary   = _neutral400;  //  3.0:1 large text ✓
  // static const Color textOnPrimary  = Colors.white;
  static const Color textDisabled = _neutral300;

  // static const Color background     = _neutral50;
  // static const Color surface        = Colors.white;
  // static const Color surfaceVariant = _neutral100;
  // static const Color cardBg         = Colors.white;
  // static const Color border         = _neutral200;
  // static const Color divider        = _neutral100;

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC  —  DARK
  //
  // Naming convention: <role>DarkMode for colors specific to dark contexts.
  //
  // DO NOT:
  //   • Use primaryDark (_green700) as primaryContainer — CR 1.88:1 failure ✗
  //   • Use semi-transparent green fills < alpha 0.55 on dark surfaces ✗
  //   • Place green icons on green-tinted container backgrounds ✗
  //
  // DO:
  //   • Use primaryDarkMode (#3CC47C) for all icon/text brand touches ✓
  //   • Use primaryContainerDark (#1A4028) as opaque filled container ✓
  //   • Use textPrimaryDark (#F2F2F7) as icon/text on those containers ✓
  //   • For switch track use alpha ≥ 0.55 + WHITE thumb (not green thumb) ✓
  // ═══════════════════════════════════════════════════════════════════════════

  // Brand
  /// Primary action color in dark mode. Contrast: bg 8.66:1 / surf 7.60:1 / card 6.22:1
  static const Color primaryDarkMode = _green400;

  /// For gradients and highlight accents only — NOT primary text/icon.
  static const Color primaryLightDarkMode = _green300;

  /// Opaque container background for filled chips, nav pills, badges.
  /// primaryDarkMode sits on top at 5.19:1 ✓  primaryLightDarkMode at 6.15:1 ✓
  /// Appears subtle vs dark surfaces by design — icon/text carries accessibility.
  static const Color primaryContainerDark = _green900dk; // #1A4028

  static const Color secondaryDarkMode = _blue200;
  static const Color accentDarkMode = _amber200;

  /// Error: lighter red for dark bg. On backgroundDark = 5.94:1 ✓
  static const Color errorDarkMode = _redDark;
  static const Color errorLightDarkMode = Color(0xFF3D1515);

  // Text
  /// F2F2F7 on backgroundDark = 14.8:1 ✓  on surfaceDark = 13.0:1 ✓
  static const Color textPrimaryDark = Color(0xFFF2F2F7);

  /// 8E8E93 on backgroundDark = 5.5:1 ✓  on surfaceDark = 4.8:1 ✓
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  /// 636366 ≈ 3.0:1 — large text (≥ 18 pt) and secondary icons only
  static const Color textTertiaryDark = Color(0xFF636366);
  static const Color textDisabledDark = Color(0xFF3A3A3C);

  // Surfaces
  static const Color backgroundDark = _darkBg; // #0D0D12
  static const Color surfaceDark = _dark50; // #1C1C1E
  static const Color surfaceVariantDark = _dark100; // #2C2C2E
  static const Color cardBgDark = _dark100; // #2C2C2E
  static const Color surfaceElevatedDark = _dark200; // #3A3A3C
  static const Color borderDark = _dark300; // #48484A
  static const Color dividerDark = _dark200; // #3A3A3C

  // ═══════════════════════════════════════════════════════════════════════════
  // CUPERTINO ADAPTIVE COLORS (auto-resolve in CupertinoTheme tree)
  // ═══════════════════════════════════════════════════════════════════════════

  static const CupertinoDynamicColor adaptivePrimary = CupertinoDynamicColor(
    color: primary,
    darkColor: primaryDarkMode,
    highContrastColor: primaryDark,
    darkHighContrastColor: primaryLightDarkMode,
    elevatedColor: primary,
    darkElevatedColor: primaryDarkMode,
    highContrastElevatedColor: primaryDark,
    darkHighContrastElevatedColor: primaryLightDarkMode,
  );

  static const CupertinoDynamicColor adaptiveTextPrimary =
      CupertinoDynamicColor(
        color: textPrimary,
        darkColor: textPrimaryDark,
        highContrastColor: _neutral900,
        darkHighContrastColor: Colors.white,
        elevatedColor: textPrimary,
        darkElevatedColor: textPrimaryDark,
        highContrastElevatedColor: _neutral900,
        darkHighContrastElevatedColor: Colors.white,
      );

  static const CupertinoDynamicColor adaptiveTextSecondary =
      CupertinoDynamicColor(
        color: textSecondary,
        darkColor: textSecondaryDark,
        highContrastColor: _neutral700,
        darkHighContrastColor: _neutral300,
        elevatedColor: textSecondary,
        darkElevatedColor: textSecondaryDark,
        highContrastElevatedColor: _neutral700,
        darkHighContrastElevatedColor: _neutral300,
      );

  static const CupertinoDynamicColor adaptiveBackground = CupertinoDynamicColor(
    color: background,
    darkColor: backgroundDark,
    highContrastColor: Colors.white,
    darkHighContrastColor: Colors.black,
    elevatedColor: background,
    darkElevatedColor: surfaceDark,
    highContrastElevatedColor: Colors.white,
    darkHighContrastElevatedColor: _dark50,
  );

  static const CupertinoDynamicColor adaptiveSurface = CupertinoDynamicColor(
    color: surface,
    darkColor: surfaceDark,
    highContrastColor: Colors.white,
    darkHighContrastColor: _dark50,
    elevatedColor: surface,
    darkElevatedColor: surfaceVariantDark,
    highContrastElevatedColor: Colors.white,
    darkHighContrastElevatedColor: _dark100,
  );

  static const CupertinoDynamicColor adaptiveError = CupertinoDynamicColor(
    color: error,
    darkColor: errorDarkMode,
    highContrastColor: Color(0xFFCC0000),
    darkHighContrastColor: Colors.white,
    elevatedColor: error,
    darkElevatedColor: errorDarkMode,
    highContrastElevatedColor: Color(0xFFCC0000),
    darkHighContrastElevatedColor: Colors.white,
  );
}
