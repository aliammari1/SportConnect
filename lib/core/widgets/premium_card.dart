import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Platform-adaptive card — glass border on iOS, standard on Android
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.hasBorder = false,
    this.borderColor,
    this.borderRadius = 20,
    this.shadow,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool hasBorder;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: gradient == null
              ? (backgroundColor ?? AppColors.cardBg)
              : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: hasBorder
              ? Border.all(color: borderColor ?? AppColors.border)
              : PlatformAdaptive.cardBorder,
          boxShadow: shadow ?? PlatformAdaptive.adaptiveShadow(),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

/// Glass morphism card — Liquid Glass aesthetic
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.padding,
    this.borderRadius = 20,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(borderRadius.r);
    final shouldBlur = PlatformAdaptive.useBackdropBlur;
    final card = Container(
      decoration: BoxDecoration(
        color: shouldBlur
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.cardBg,
        borderRadius: cardRadius,
        border: Border.all(
          color: shouldBlur
              ? Colors.white.withValues(alpha: 0.22)
              : AppColors.border,
          width: 0.8,
        ),
        gradient: shouldBlur
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              )
            : null,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );

    if (!shouldBlur) {
      return ClipRRect(borderRadius: cardRadius, child: card);
    }

    return ClipRRect(
      borderRadius: cardRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: PlatformAdaptive.cardBlurSigma,
          sigmaY: PlatformAdaptive.cardBlurSigma,
        ),
        child: card,
      ),
    );
  }
}

/// Stat Card for displaying metrics
class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
    this.iconColor,
    this.gradient,
    this.subtitle,
    this.onTap,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Gradient? gradient;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: gradient != null ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: gradient != null
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: gradient != null
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Featured Card with image background
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    required this.title,
    required this.subtitle,
    super.key,
    this.imageUrl,
    this.onTap,
    this.badge,
    this.overlayGradient,
  });
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? badge;
  final Gradient? overlayGradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppSpacing.shadowMd,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: overlayGradient ?? AppColors.heroGradient,
                ),
              ),
              // Decorative circles
              Positioned(
                right: -30.w,
                top: -30.h,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                right: 40.w,
                bottom: -40.h,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ?badge,
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List Item Card
class ListItemCard extends StatelessWidget {
  const ListItemCard({
    required this.leading,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          leading,
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
