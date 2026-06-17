import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// A horizontal label/value detail row.
///
/// Renders a [Row] with a left-aligned [label] and a right-aligned [value].
/// The value is wrapped in a [Flexible]/[Expanded] so it can wrap or ellipsize
/// instead of overflowing.
///
/// Used in detail cards (payment summaries, vehicle details, etc.) to show a
/// list of key/value pairs.
///
/// Variations are exposed as parameters so the same widget can cover slightly
/// different call sites:
/// - [bold] emphasizes both label and value (e.g. a total row).
/// - [valueColor] overrides the value color (e.g. a status/amount color).
/// - [labelFontSize] / [verticalPadding] / [horizontalPadding] allow matching
///   the spacing of different surrounding layouts.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    required this.label,
    required this.value,
    super.key,
    this.bold = false,
    this.valueColor,
    this.labelFontSize,
    this.valueFontSize,
    this.valueFontWeight,
    this.verticalPadding,
    this.horizontalPadding,
    this.expandLabel = false,
  });

  /// The descriptive label shown on the left.
  final String label;

  /// The value shown on the right (right-aligned).
  final String value;

  /// When true, the label uses the primary color with a semi-bold weight and
  /// the value uses an extra-bold weight. Used for emphasized rows like totals.
  final bool bold;

  /// Optional override for the value text color. Defaults to the primary text
  /// color.
  final Color? valueColor;

  /// Optional override for the label font size. Defaults to `14.sp`.
  final double? labelFontSize;

  /// Optional override for the value font size. Defaults to `14.sp`.
  final double? valueFontSize;

  /// Optional override for the value font weight. Defaults to `FontWeight.w700`
  /// when [bold] is true, otherwise `FontWeight.w600`.
  final FontWeight? valueFontWeight;

  /// Optional override for the vertical padding. Defaults to `12.h`.
  final double? verticalPadding;

  /// Optional override for the horizontal padding. Defaults to `0`.
  final double? horizontalPadding;

  /// When true, the label is wrapped in an [Expanded] (pushing the value to the
  /// far right) instead of relying on [MainAxisAlignment.spaceBetween].
  final bool expandLabel;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: labelFontSize ?? 14.sp,
        color: bold ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 0,
        vertical: verticalPadding ?? 12.h,
      ),
      child: Row(
        mainAxisAlignment:
            expandLabel ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: [
          if (expandLabel) Expanded(child: labelWidget) else labelWidget,
          if (expandLabel) SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: valueFontSize ?? 14.sp,
                fontWeight:
                    valueFontWeight ?? (bold ? FontWeight.w700 : FontWeight.w600),
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
