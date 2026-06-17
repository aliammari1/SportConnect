import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Premium loading indicator with multiple styles
class PremiumLoader extends StatelessWidget {
  const PremiumLoader({
    super.key,
    this.size = 40,
    this.color,
    this.style = LoaderStyle.spinner,
  });
  final double size;
  final Color? color;
  final LoaderStyle style;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LoaderStyle.spinner:
        return _buildSpinner();
      case LoaderStyle.dots:
        return _buildDots();
      case LoaderStyle.pulse:
        return _buildPulse();
      case LoaderStyle.ring:
        return _buildRing();
    }
  }

  Widget _buildSpinner() {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final dot = Container(
          width: (size / 4).w,
          height: (size / 4).w,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            shape: BoxShape.circle,
          ),
        );

        return dot
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .fadeIn(
              delay: Duration(milliseconds: index * 150),
              duration: 400.ms,
            )
            .scale(
              delay: Duration(milliseconds: index * 150),
              duration: 400.ms,
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
            );
      }),
    );
  }

  Widget _buildPulse() {
    final pulse = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (color ?? AppColors.primary).withValues(alpha: 0.15),
      ),
      child: Center(
        child: Container(
          width: (size * 0.5).w,
          height: (size * 0.5).w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? AppColors.primary,
          ),
        ),
      ),
    );

    return pulse
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 800.ms,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
        );
  }

  Widget _buildRing() {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (color ?? AppColors.primary).withValues(alpha: 0.2),
                width: 3,
              ),
            ),
          ),
          SizedBox(
            width: size.w,
            height: size.w,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

enum LoaderStyle { spinner, dots, pulse, ring }

/// Full screen loading overlay
class PremiumLoadingOverlay extends StatelessWidget {
  const PremiumLoadingOverlay({
    required this.child,
    super.key,
    this.message,
    this.isVisible = false,
  });
  final String? message;
  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible) _buildOverlay(context),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final overlay = ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PremiumLoader(size: 48, style: LoaderStyle.ring),
              if (message != null) ...[
                SizedBox(height: 20.h),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return overlay.animate().fadeIn(duration: 200.ms);
  }
}

/// Skeleton shimmer effect for loading states
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({
    required this.child,
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Skeletonizer(
      containersColor: baseColor ?? AppColors.border.withValues(alpha: 0.5),
      child: child,
    );
  }
}

/// Skeleton box placeholder
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );

    return Skeletonizer(
      containersColor: AppColors.border.withValues(alpha: 0.5),
      child: box,
    );
  }
}

/// Skeleton circle placeholder
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );

    return Skeletonizer(
      containersColor: AppColors.border.withValues(alpha: 0.5),
      child: circle,
    );
  }
}

/// Skeleton text line placeholder
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width.isFinite ? width.w : width,
      height: height.h,
      borderRadius: 6,
    );
  }
}

/// Pre-built skeleton for ride cards
class RideCardSkeleton extends StatelessWidget {
  const RideCardSkeleton({super.key, this.delay = 0});
  final int delay;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Driver row skeleton
          Row(
            children: [
              const SkeletonCircle(size: 56),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 120.w, height: 16),
                    SizedBox(height: 8.h),
                    SkeletonLine(width: 80.w, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 60.w, height: 50.h, borderRadius: 14),
            ],
          ),
          SizedBox(height: 18.h),
          // Route section skeleton
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    const SkeletonCircle(size: 14),
                    SizedBox(height: 4.h),
                    SkeletonBox(width: 2.w, height: 30.h, borderRadius: 1),
                    SizedBox(height: 4.h),
                    const SkeletonCircle(size: 14),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 100.w, height: 12),
                      SizedBox(height: 4.h),
                      SkeletonLine(width: 140.w),
                      SizedBox(height: 16.h),
                      SkeletonLine(width: 100.w, height: 12),
                      SizedBox(height: 4.h),
                      SkeletonLine(width: 130.w),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // Bottom bar skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 100.w, height: 36.h, borderRadius: 10),
              SkeletonBox(width: 110.w, height: 44.h),
            ],
          ),
        ],
      ),
    );

    return card.animate().fadeIn(
      delay: Duration(milliseconds: delay),
      duration: 300.ms,
    );
  }
}

/// Pre-built skeleton for user profile cards
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const SkeletonCircle(size: 80),
          SizedBox(height: 16.h),
          SkeletonLine(width: 140.w, height: 18),
          SizedBox(height: 8.h),
          SkeletonLine(width: 100.w),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SkeletonBox(width: 50.w, height: 24.h),
                  SizedBox(height: 4.h),
                  SkeletonLine(width: 60.w, height: 12),
                ],
              ),
              Column(
                children: [
                  SkeletonBox(width: 50.w, height: 24.h),
                  SizedBox(height: 4.h),
                  SkeletonLine(width: 60.w, height: 12),
                ],
              ),
              Column(
                children: [
                  SkeletonBox(width: 50.w, height: 24.h),
                  SizedBox(height: 4.h),
                  SkeletonLine(width: 60.w, height: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return card.animate().fadeIn(duration: 300.ms);
  }
}

/// Pre-built skeleton for message items
class MessageItemSkeleton extends StatelessWidget {
  const MessageItemSkeleton({
    super.key,
    this.isOwnMessage = false,
    this.delay = 0,
  });
  final bool isOwnMessage;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final item = Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOwnMessage ? 80.w : 16.w,
          right: isOwnMessage ? 16.w : 80.w,
          bottom: 8.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwnMessage) ...[
              const SkeletonCircle(size: 32),
              SizedBox(width: 8.w),
            ],
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 150.w),
                  SizedBox(height: 6.h),
                  SkeletonLine(width: 100.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return item.animate().fadeIn(
      delay: Duration(milliseconds: delay),
      duration: 200.ms,
    );
  }
}

/// Skeleton list view builder
class SkeletonListView extends StatelessWidget {
  const SkeletonListView({
    required this.itemBuilder,
    super.key,
    this.itemCount = 5,
    this.padding,
  });
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: itemBuilder,
    );
  }
}
