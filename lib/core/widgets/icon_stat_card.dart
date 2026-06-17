import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';

/// A compact horizontal statistic card: a tinted icon tile on the left and a
/// value/label pair on the right.
///
/// This captures the recurring "icon-tile-row" stat card variant used across
/// the app (driver earnings, profile stats, etc.). It is intentionally distinct
/// from `StatCard` in `premium_card.dart`, which uses a different layout.
///
/// Two presentations are supported via named constructors:
///
/// * [IconStatCard.elevated] — sits on an opaque [AppColors.surface] background
///   with a small drop shadow. The value is rendered *below* the label, which
///   reads as a quiet header followed by an emphasised number.
/// * [IconStatCard.tinted] — sits on a translucent tint of [color] with no
///   shadow. The value is rendered *above* the label and both lines clip with
///   an ellipsis, suited to tighter grid cells.
class IconStatCard extends StatelessWidget {
  /// Elevated variant: opaque surface background with a subtle shadow.
  ///
  /// Layout order is label (top) then value (bottom).
  const IconStatCard.elevated({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    super.key,
  }) : _padding = 16,
       _iconTilePadding = 10,
       _iconSize = 22,
       _valueFontSize = 18,
       _valueFontWeight = FontWeight.w700,
       _iconTileAlpha = 0.1,
       _backgroundAlpha = null,
       _valueAbove = false,
       _clipText = false;

  /// Tinted variant: translucent [color] background, no shadow.
  ///
  /// Layout order is value (top) then label (bottom); both lines ellipsize.
  const IconStatCard.tinted({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    super.key,
  }) : _padding = 12,
       _iconTilePadding = 8,
       _iconSize = 18,
       _valueFontSize = 16,
       _valueFontWeight = FontWeight.w800,
       _iconTileAlpha = 0.15,
       _backgroundAlpha = 0.08,
       _valueAbove = true,
       _clipText = true;

  /// Leading glyph shown inside the tinted icon tile.
  final IconData icon;

  /// Accent colour driving the icon, the icon tile tint and (for the tinted
  /// variant) the card background tint.
  final Color color;

  /// Primary, emphasised statistic value (e.g. "42", "€120").
  final String value;

  /// Secondary descriptive label (e.g. "Rides", "Earnings").
  final String label;

  final double _padding;
  final double _iconTilePadding;
  final double _iconSize;
  final double _valueFontSize;
  final FontWeight _valueFontWeight;
  final double _iconTileAlpha;
  final double? _backgroundAlpha;
  final bool _valueAbove;
  final bool _clipText;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      maxLines: _clipText ? 1 : null,
      overflow: _clipText ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: _valueFontSize.sp,
        fontWeight: _valueFontWeight,
        color: AppColors.textPrimary,
      ),
    );

    final labelText = Text(
      label,
      maxLines: _clipText ? 1 : null,
      overflow: _clipText ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: (_valueAbove ? 11 : 12).sp,
        color: AppColors.textSecondary,
      ),
    );

    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: EdgeInsets.all(_padding.w),
        decoration: BoxDecoration(
          color: _backgroundAlpha != null
              ? color.withValues(alpha: _backgroundAlpha)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(_valueAbove ? 12.r : 16.r),
          boxShadow: _backgroundAlpha == null ? AppSpacing.shadowSm : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(_iconTilePadding.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: _iconTileAlpha),
                borderRadius: BorderRadius.circular(_valueAbove ? 8.r : 12.r),
              ),
              child: Icon(icon, color: color, size: _iconSize.sp),
            ),
            SizedBox(width: (_valueAbove ? 10 : 12).w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _valueAbove
                    ? [valueText, labelText]
                    : [
                        labelText,
                        SizedBox(height: 4.h),
                        valueText,
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
