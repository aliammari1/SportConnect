import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

class OfferSummaryRow extends StatelessWidget {
  const OfferSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.primary.withValues(alpha: 0.7),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class OfferStepItem extends StatelessWidget {
  const OfferStepItem({
    required this.step,
    required this.label,
    required this.currentStep,
    super.key,
  });

  final int step;
  final String label;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class OfferStepConnector extends StatelessWidget {
  const OfferStepConnector({
    required this.step,
    required this.currentStep,
    super.key,
  });

  final int step;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 22.h),
        color: currentStep > step ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

class OfferPreferenceSwitch extends StatelessWidget {
  const OfferPreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(left: 28.w),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }
}
