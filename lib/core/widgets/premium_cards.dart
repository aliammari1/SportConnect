import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Premium Card with various styles
class PremiumCard extends StatefulWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding,
    this.margin,
    this.style = PremiumCardStyle.elevated,
    this.width,
    this.height,
    this.showBorder = true,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = 20,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final PremiumCardStyle style;
  final double? width;
  final double? height;
  final bool showBorder;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double borderRadius;

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  BoxDecoration get _decoration {
    switch (widget.style) {
      case PremiumCardStyle.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.cardBg,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          // Platform-adaptive: glass border on iOS, subtle on Android
          border: widget.showBorder ? PlatformAdaptive.cardBorder : null,
          boxShadow: PlatformAdaptive.adaptiveShadow(),
        );
      case PremiumCardStyle.flat:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.cardBg,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: widget.showBorder
              ? Border.all(color: AppColors.border)
              : null,
        );
      case PremiumCardStyle.gradient:
        return BoxDecoration(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case PremiumCardStyle.glass:
        return BoxDecoration(
          // Glass: translucent surface (only styled on iOS)
          color: (widget.backgroundColor ?? AppColors.cardBg).withValues(
            alpha: PlatformAdaptive.isApple ? 0.12 : 0.06,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: PlatformAdaptive.isApple
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 0.8,
                )
              : Border.all(color: AppColors.border.withValues(alpha: 0.1)),
          boxShadow: PlatformAdaptive.adaptiveShadow(),
        );
      case PremiumCardStyle.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: Border.all(
            color: widget.backgroundColor ?? AppColors.primary,
            width: 2,
          ),
        );
    }
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    if (!_isPressed) {
      _isPressed = true;
      _pressController.forward();
      unawaited(HapticFeedback.lightImpact());
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    if (_isPressed) {
      _isPressed = false;
      _pressController.reverse();
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      _isPressed = false;
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final scale = 1.0 - (0.02 * _pressController.value);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding ?? EdgeInsets.all(16.w),
          decoration: _decoration,
          child: widget.child,
        ),
      ),
    );
  }
}

enum PremiumCardStyle { elevated, flat, gradient, glass, outlined }

/// Premium List Tile with modern design
class PremiumListTile extends StatelessWidget {
  const PremiumListTile({
    required this.title,
    super.key,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.showChevron = true,
    this.accentColor,
  });
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showChevron;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            unawaited(HapticFeedback.lightImpact());
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
            child: Row(
              children: [
                if (leading != null) ...[
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: (accentColor ?? AppColors.primary).withValues(
                        alpha: 0.1,
                      ),
                      // Liquid Glass: softer icon container
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: leading is IconData
                          ? Icon(
                              leading! as IconData,
                              color: accentColor ?? AppColors.primary,
                              size: 22.sp,
                            )
                          : leading,
                    ),
                  ),
                  SizedBox(width: 14.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 3.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
                if (showChevron && trailing == null) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 24.sp,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.5),
            indent: leading != null ? 58.w : 0,
          ),
      ],
    );
  }
}

/// Premium Icon Container
class PremiumIconContainer extends StatelessWidget {
  const PremiumIconContainer({
    required this.icon,
    super.key,
    this.size = 48,
    this.color,
    this.gradient,
    this.showShadow = true,
  });
  final IconData icon;
  final double size;
  final Color? color;
  final Gradient? gradient;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? AppColors.primary).withValues(alpha: 0.1)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular((size / 4).r),
        boxShadow: showShadow && gradient != null
            ? [
                BoxShadow(
                  color: (color ?? AppColors.primary).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: (size * 0.5).sp,
          color: gradient != null ? Colors.white : (color ?? AppColors.primary),
        ),
      ),
    );
  }
}

/// Premium Info Banner
class PremiumInfoBanner extends StatelessWidget {
  const PremiumInfoBanner({
    required this.message,
    super.key,
    this.title,
    this.icon,
    this.type = PremiumBannerType.info,
    this.onClose,
    this.onAction,
    this.actionLabel,
  });
  final String message;
  final String? title;
  final IconData? icon;
  final PremiumBannerType type;
  final VoidCallback? onClose;
  final VoidCallback? onAction;
  final String? actionLabel;

  Color get _color {
    switch (type) {
      case PremiumBannerType.info:
        return AppColors.info;
      case PremiumBannerType.success:
        return AppColors.success;
      case PremiumBannerType.warning:
        return AppColors.warning;
      case PremiumBannerType.error:
        return AppColors.error;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case PremiumBannerType.info:
        return Icons.info_rounded;
      case PremiumBannerType.success:
        return Icons.check_circle_rounded;
      case PremiumBannerType.warning:
        return Icons.warning_rounded;
      case PremiumBannerType.error:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon ?? _defaultIcon, color: _color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _color,
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (onAction != null && actionLabel != null) ...[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textTertiary,
                size: 20.sp,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, duration: 300.ms);
  }
}

enum PremiumBannerType { info, success, warning, error }

/// Premium Stats Card
class PremiumStatsCard extends StatelessWidget {
  const PremiumStatsCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
    this.subtitle,
    this.color,
    this.gradient,
    this.trend,
    this.isTrendPositive = true,
  });
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final String? trend;
  final bool isTrendPositive;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return PremiumCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PremiumIconContainer(
                icon: icon,
                size: 44,
                color: effectiveColor,
                gradient: gradient,
              ),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:
                        (isTrendPositive ? AppColors.success : AppColors.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14.sp,
                        color: isTrendPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isTrendPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Premium Empty State
class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48.sp, color: AppColors.primary),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            if (message != null) ...[
              SizedBox(height: 8.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.mediumImpact());
                  onAction!();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}
