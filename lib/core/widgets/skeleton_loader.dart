import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Reusable skeleton shimmer loader for list loading states.
///
/// Provides common placeholders: ride cards, event cards, chat tiles,
/// notification tiles, and custom builders.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.itemCount = 4,
    this.type = SkeletonType.rideCard,
    this.padding,
  });

  final int itemCount;
  final SkeletonType type;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, _) => switch (type) {
        SkeletonType.rideCard => const _RideCardSkeleton(),
        SkeletonType.eventCard => const _EventCardSkeleton(),
        SkeletonType.chatTile => const _ChatTileSkeleton(),
        SkeletonType.notificationTile => const _NotificationTileSkeleton(),
        SkeletonType.profileCard => const _ProfileCardSkeleton(),
        SkeletonType.compactTile => const _CompactTileSkeleton(),
      },
    );

    return Skeletonizer(
      containersColor: AppColors.shimmer,
      child: list,
    );
  }
}

enum SkeletonType {
  rideCard,
  eventCard,
  chatTile,
  notificationTile,
  profileCard,
  compactTile,
}

// ── Skeleton building blocks ──

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.radius = 8});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerHighlight,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class _CircleBone extends StatelessWidget {
  const _CircleBone({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.shimmerHighlight,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Ride Card Skeleton ──
class _RideCardSkeleton extends StatelessWidget {
  const _RideCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleBone(size: 40.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 120.w, height: 14.h),
                    SizedBox(height: 6.h),
                    _Bone(width: 80.w, height: 10.h),
                  ],
                ),
              ),
              _Bone(width: 50.w, height: 20.h, radius: 10),
            ],
          ),
          SizedBox(height: 16.h),
          _Bone(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          _Bone(width: 200.w, height: 12.h),
          SizedBox(height: 12.h),
          Row(
            children: [
              _Bone(width: 60.w, height: 24.h, radius: 12),
              SizedBox(width: 8.w),
              _Bone(width: 60.w, height: 24.h, radius: 12),
              SizedBox(width: 8.w),
              _Bone(width: 60.w, height: 24.h, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Event Card Skeleton ──
class _EventCardSkeleton extends StatelessWidget {
  const _EventCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          _Bone(width: double.infinity, height: 120.h, radius: 16),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 160.w, height: 16.h),
                SizedBox(height: 8.h),
                _Bone(width: 100.w, height: 12.h),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _Bone(width: 20.w, height: 20.w),
                    SizedBox(width: 8.w),
                    _Bone(width: 140.w, height: 12.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Tile Skeleton ──
class _ChatTileSkeleton extends StatelessWidget {
  const _ChatTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _CircleBone(size: 48.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 140.w, height: 14.h),
                SizedBox(height: 6.h),
                _Bone(width: 200.w, height: 11.h),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Bone(width: 40.w, height: 10.h),
              SizedBox(height: 6.h),
              _CircleBone(size: 18.w),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Notification Tile Skeleton ──
class _NotificationTileSkeleton extends StatelessWidget {
  const _NotificationTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _CircleBone(size: 42.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 180.w, height: 13.h),
                SizedBox(height: 6.h),
                _Bone(width: 240.w, height: 11.h),
                SizedBox(height: 4.h),
                _Bone(width: 60.w, height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card Skeleton ──
class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _CircleBone(size: 56.w),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 120.w, height: 16.h),
                SizedBox(height: 6.h),
                _Bone(width: 80.w, height: 12.h),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _Bone(width: 50.w, height: 10.h),
                    SizedBox(width: 12.w),
                    _Bone(width: 50.w, height: 10.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact Tile Skeleton ──
class _CompactTileSkeleton extends StatelessWidget {
  const _CompactTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          _Bone(width: 36.w, height: 36.w, radius: 10),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 160.w, height: 13.h),
                SizedBox(height: 4.h),
                _Bone(width: 100.w, height: 10.h),
              ],
            ),
          ),
          _Bone(width: 20.w, height: 20.w),
        ],
      ),
    );
  }
}
