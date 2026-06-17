import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// A compact, inline icon + label chip / pill.
///
/// Renders a tight `Row` of a small leading [Icon] followed by a [Text] label,
/// wrapped in a rounded, padded container. It is intentionally lightweight and
/// content-hugging (`MainAxisSize.min`), making it suitable for metadata rows,
/// status overlays on gradients, and inline tags.
///
/// This is distinct from `StatusBadge` / `PremiumTag`, which are label-only.
///
/// Defaults match the most common usage (a bordered "info chip" sitting on a
/// surface background with secondary-colored content). Override [background],
/// [foreground], [borderRadius] and [bordered] to produce other variants such
/// as a translucent pill on a colored / gradient background.
class IconLabelChip extends StatelessWidget {
  const IconLabelChip({
    required this.icon,
    required this.label,
    super.key,
    this.background,
    this.foreground,
    this.borderColor,
    this.borderRadius = 8,
    this.bordered = true,
    this.iconSize = 14,
    this.fontSize = 12,
    this.gap = 6,
    this.fontWeight,
    this.horizontalPadding = 10,
    this.verticalPadding = 6,
  });

  /// Leading icon.
  final IconData icon;

  /// Trailing text label.
  final String label;

  /// Background fill. Defaults to [AppColors.surface].
  final Color? background;

  /// Color applied to both the icon and the label text.
  /// Defaults to [AppColors.textSecondary].
  final Color? foreground;

  /// Border color used when [bordered] is true. Defaults to [AppColors.border].
  final Color? borderColor;

  /// Corner radius (logical, scaled with `.r`).
  final double borderRadius;

  /// Whether to draw a 1px border. Defaults to true.
  final bool bordered;

  /// Icon size (sp).
  final double iconSize;

  /// Label font size (sp).
  final double fontSize;

  /// Horizontal gap between icon and label (w).
  final double gap;

  /// Optional label font weight.
  final FontWeight? fontWeight;

  /// Horizontal inner padding (w).
  final double horizontalPadding;

  /// Vertical inner padding (h).
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppColors.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.w,
        vertical: verticalPadding.h,
      ),
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: bordered
            ? Border.all(color: borderColor ?? AppColors.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize.sp, color: fg),
          SizedBox(width: gap.w),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize.sp,
              fontWeight: fontWeight,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
