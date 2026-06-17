import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// A compact star-icon + numeric rating display.
///
/// Renders a [Row] (sized to its children) containing a filled star icon
/// followed by the rating formatted to one decimal place, e.g. `★ 4.5`.
///
/// This consolidates the repeated `Icon(Icons.star_rounded) + Text(
/// rating.toStringAsFixed(1))` pattern used across ride cards, search
/// results and profile rows. Per-site variations (star color, text style,
/// icon size and the gap between icon and value) are exposed as parameters
/// so the output is visually identical to the inline code it replaces.
class RatingValue extends StatelessWidget {
  const RatingValue({
    required this.rating,
    this.iconSize = 14,
    this.starColor,
    this.valueStyle,
    this.gap = 4,
    super.key,
  });

  /// The rating to display; formatted with [num.toStringAsFixed] to 1 decimal.
  final double rating;

  /// Star icon size in logical (`.sp`-scaled) pixels. Defaults to 14.
  final double iconSize;

  /// Star icon color. Defaults to [AppColors.starFilled] when null.
  final Color? starColor;

  /// Text style for the rating value. When null, a default style sized to
  /// match [iconSize] using [AppColors.textSecondary] is used.
  final TextStyle? valueStyle;

  /// Horizontal spacing between the star and the value. Defaults to 4.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: starColor ?? AppColors.starFilled,
          size: iconSize.sp,
        ),
        SizedBox(width: gap.w),
        Text(
          rating.toStringAsFixed(1),
          style:
              valueStyle ??
              TextStyle(
                fontSize: iconSize.sp,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
