
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Ops-console design tokens.
///
/// Every visual constant lives here so screens stay consistent and theme
/// changes propagate from one place. Dark mode is first-class: all surface
/// and text reads go through [AppColors] brightness-aware getters.
abstract final class OpsDS {
  // ── Radius ──
  static const double rXs = 8;
  static const double rSm = 10;
  static const double rCard = 14;
  static const double rLg = 18;
  static const double rSheet = 24;
  static const double rPill = 999;

  // ── Spacing ──
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double padScreen = 16;

  // ── Elevation ──
  /// Resting card: barely-there lift.
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark ? 0.30 : 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Raised content (hero, sheets, popovers).
  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark ? 0.35 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Floating overlays.
  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark ? 0.45 : 0.10),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  // ── Motion ──
  static const Duration durFast = Duration(milliseconds: 150);
  static const Duration durMed = Duration(milliseconds: 250);
  static const Duration durSlow = Duration(milliseconds: 400);
  static const Curve curveEase = Curves.easeOutCubic;

  // ── Semantic status system ──
  static Color statusBg(Color c) => c.withValues(alpha: 0.10);

  static BoxDecoration card({Color? accent}) => BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(rCard),
        border: Border.all(
          color: accent?.withValues(alpha: 0.25) ??
              AppColors.border.withValues(alpha: 0.30),
        ),
        boxShadow: elevation1,
      );

  static BoxDecoration heroGradient() => BoxDecoration(
        borderRadius: BorderRadius.circular(rLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: elevation2,
      );

  /// Diagonal white sheen laid over the hero for a glass highlight.
  static LinearGradient heroSheen() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.45, 1.0],
      );

  // ── Text styles ──

  /// Page-level display numerals.
  static TextStyle display(BuildContext c) => TextStyle(
        fontSize: 30.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  /// KPI values; tabular figures keep digit columns aligned.
  static TextStyle kpiValue(BuildContext c) => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  static TextStyle cardTitle(BuildContext c) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle body(BuildContext c) => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle meta(BuildContext c) => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// Uppercase section labels.
  static TextStyle sectionHeader(BuildContext c) => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      );

  static TextStyle chipText(Color color) => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: color,
      );
}

/// Semantic status used across pills, rails, and badges.
enum KitStatus { live, pending, danger, info, neutral, premium }

extension KitStatusX on KitStatus {
  Color get color => switch (this) {
        KitStatus.live => const Color(0xFF16A34A),
        KitStatus.pending => const Color(0xFFD97706),
        KitStatus.danger => const Color(0xFFDC2626),
        KitStatus.info => const Color(0xFF4A7C88),
        KitStatus.neutral => const Color(0xFF94A3B8),
        KitStatus.premium => const Color(0xFF7C3AED),
      };

  Color get bg => color.withValues(alpha: 0.10);

  String get label => switch (this) {
        KitStatus.live => 'Live',
        KitStatus.pending => 'Pending',
        KitStatus.danger => 'Danger',
        KitStatus.info => 'Info',
        KitStatus.neutral => 'Neutral',
        KitStatus.premium => 'Premium',
      };
}

/// Maps a raw ride/payment/issue status string to the semantic kit status.
KitStatus kitStatusFrom(String raw) => switch (raw) {
      'completed' => KitStatus.info,
      'inProgress' ||
      'active' ||
      'live' ||
      'approved' ||
      'resolved' =>
        KitStatus.live,
      'pending' || 'open' || 'refunding' => KitStatus.pending,
      'cancelled' || 'rejected' || 'failed' || 'banned' => KitStatus.danger,
      _ => KitStatus.neutral,
    };
