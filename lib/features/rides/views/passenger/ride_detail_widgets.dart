import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';

class RideMatchChip extends StatelessWidget {
  const RideMatchChip({
    required this.icon,
    required this.label,
    required this.positive,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: positive
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.textTertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14.sp,
            color: positive ? AppColors.success : AppColors.textTertiary,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: positive ? AppColors.success : AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SeatCounterButton extends StatelessWidget {
  const SeatCounterButton({
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Icon(
          icon,
          color: isEnabled ? AppColors.primary : AppColors.textTertiary,
          size: 22.sp,
        ),
      ),
    );
  }
}

class BookingPriceRow extends StatelessWidget {
  const BookingPriceRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
