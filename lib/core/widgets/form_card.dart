import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// A rounded surface container used to group related form fields.
///
/// Renders a [Container] with the app surface background, a rounded border
/// ([AppColors.border] at a configurable alpha) and an optional subtle drop
/// shadow, wrapping its [children] in a stretch-aligned [Column].
///
/// The sizing parameters ([padding], [radius], [borderAlpha]) and [boxShadow]
/// are exposed so the single widget can cover the slight visual variations
/// found across screens (e.g. the edit-profile card vs. the vehicle form card).
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.children,
    this.padding,
    this.radius = 18,
    this.borderAlpha = 0.5,
    this.boxShadow,
  });

  /// The widgets stacked vertically inside the card.
  final List<Widget> children;

  /// Inner padding. Defaults to `EdgeInsets.all(16.w)` when null.
  final EdgeInsets? padding;

  /// Corner radius in logical pixels (passed through `.r`).
  final double radius;

  /// Opacity applied to [AppColors.border] for the card outline.
  final double borderAlpha;

  /// Optional drop shadow. When null, a subtle default shadow is applied.
  /// Pass an empty list to render the card with no shadow.
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: AppColors.border.withValues(alpha: borderAlpha)),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
