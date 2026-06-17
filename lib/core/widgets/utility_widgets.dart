import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Empty State Widget
class EmptyState extends StatelessWidget {
  // Alias for onButtonPressed

  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.description,
    this.subtitle,
    this.buttonText,
    this.actionText,
    this.onButtonPressed,
    this.onActionPressed,
  });
  final IconData icon;
  final String title;
  final String? description;
  final String? subtitle; // Alias for description
  final String? buttonText;
  final String? actionText; // Alias for buttonText
  final VoidCallback? onButtonPressed;
  final VoidCallback? onActionPressed;

  String? get _description => description ?? subtitle;
  String? get _buttonText => buttonText ?? actionText;
  VoidCallback? get _onButtonPressed => onButtonPressed ?? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64.sp,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_description != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_buttonText != null) ...[
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _onButtonPressed,
                  child: Text(_buttonText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading Shimmer
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = 10,
  });
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      containersColor: AppColors.surfaceVariant,
      child: Container(
        width: width.isFinite ? width.w : width,
        height: height.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

/// Skeleton Card Loader
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoading(width: 48, height: 48, borderRadius: 24),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading(width: 120, height: 14),
                  SizedBox(height: 8.h),
                  const ShimmerLoading(width: 80, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const ShimmerLoading(width: double.infinity, height: 12),
          SizedBox(height: 8.h),
          const ShimmerLoading(width: 200, height: 12),
        ],
      ),
    );
  }
}

/// Success Checkmark Animation
class SuccessCheckmark extends StatefulWidget {
  const SuccessCheckmark({super.key, this.size = 80, this.color});
  final double size;
  final Color? color;

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: BoxDecoration(
          color: (widget.color ?? AppColors.success).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle_rounded,
          size: (widget.size * 0.6).sp,
          color: widget.color ?? AppColors.success,
        ),
      ),
    );
  }
}

/// Tag/Chip Widget
class PremiumTag extends StatelessWidget {
  const PremiumTag({
    required this.label,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
    this.onRemove,
    this.isSelected = false,
  });
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (backgroundColor ?? AppColors.primary.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.sp,
                color: isSelected
                    ? Colors.white
                    : (textColor ?? AppColors.primary),
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (textColor ?? AppColors.primary),
              ),
            ),
            if (onRemove != null) ...[
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 14.sp,
                  color: isSelected
                      ? Colors.white
                      : (textColor ?? AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Divider with text
class TextDivider extends StatelessWidget {
  const TextDivider({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// Status Badge
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.type, super.key});
  final String label;
  final StatusType type;

  Color get _color {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
      case StatusType.pending:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        // Platform-adaptive status badge
        borderRadius: BorderRadius.circular(
          PlatformAdaptive.isApple ? 10.r : 8.r,
        ),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

enum StatusType { success, warning, error, info, pending }

/// Info Banner
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    super.key,
    this.icon = Icons.info_outline_rounded,
    this.backgroundColor,
    this.iconColor,
    this.onDismiss,
  });
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.info.withValues(alpha: 0.1),
        // Platform-adaptive info banner
        borderRadius: BorderRadius.circular(
          PlatformAdaptive.isApple ? 14.r : 12.r,
        ),
        border: Border.all(
          color: (iconColor ?? AppColors.info).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.info, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
