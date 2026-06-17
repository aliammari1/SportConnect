import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Wraps [child] with a red circular badge showing [count].
/// Renders [child] unchanged when [count] is zero.
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    required this.count,
    required this.child,
    super.key,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
