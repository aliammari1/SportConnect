import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';

/// A compact section header for forms and grouped settings.
///
/// Renders a small leading [icon] followed by an uppercased [title] using the
/// app's "label" typography (11sp, w700, 1.1 letter spacing). The icon is tinted
/// with [color] (defaults to [AppColors.primary]) while the label uses
/// [AppColors.textSecondary].
///
/// Use [padding] to inset the whole row — e.g. `EdgeInsets.only(left: 4.w)` to
/// align the header with card content.
class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({
    required this.icon,
    required this.title,
    this.color,
    this.padding,
    super.key,
  });

  /// Leading icon rendered at 16sp.
  final IconData icon;

  /// Header label. Automatically uppercased when displayed.
  final String title;

  /// Tint applied to the icon. Defaults to [AppColors.primary].
  final Color? color;

  /// Optional padding wrapping the entire header row.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(icon, size: 16.sp, color: color ?? AppColors.primary),
        SizedBox(width: AppSpacing.iconTextSpacing),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    if (padding == null) return row;
    return Padding(padding: padding!, child: row);
  }
}
