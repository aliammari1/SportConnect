import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Premium button styles
enum PremiumButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
  gradient,
  success,
  danger,
}

enum ButtonSize { small, medium, large }

AdaptiveButtonStyle _adaptiveStyle(PremiumButtonStyle style) {
  return switch (style) {
    PremiumButtonStyle.primary => AdaptiveButtonStyle.filled,
    PremiumButtonStyle.secondary => AdaptiveButtonStyle.tinted,
    PremiumButtonStyle.outline => AdaptiveButtonStyle.bordered,
    PremiumButtonStyle.ghost => AdaptiveButtonStyle.plain,
    PremiumButtonStyle.gradient => AdaptiveButtonStyle.filled,
    PremiumButtonStyle.success => AdaptiveButtonStyle.filled,
    PremiumButtonStyle.danger => AdaptiveButtonStyle.filled,
  };
}

AdaptiveButtonSize _adaptiveSize(ButtonSize size) {
  return switch (size) {
    ButtonSize.small => AdaptiveButtonSize.small,
    ButtonSize.medium => AdaptiveButtonSize.medium,
    ButtonSize.large => AdaptiveButtonSize.large,
  };
}

double _minButtonHeight(ButtonSize size) {
  return switch (size) {
    ButtonSize.small => 44.h,
    ButtonSize.medium => 52.h,
    ButtonSize.large => 60.h,
  };
}

Color? _adaptiveColor(PremiumButtonStyle style) {
  return switch (style) {
    PremiumButtonStyle.primary => AppColors.primary,
    PremiumButtonStyle.secondary => AppColors.secondary,
    PremiumButtonStyle.gradient => AppColors.primary,
    PremiumButtonStyle.success => AppColors.success,
    PremiumButtonStyle.danger => AppColors.error,
    PremiumButtonStyle.outline => AppColors.primary,
    PremiumButtonStyle.ghost => AppColors.primary,
  };
}

/// Custom elevated button with loading state and premium design
class PremiumButton extends StatelessWidget {
  const PremiumButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.style = PremiumButtonStyle.primary,
    this.size = ButtonSize.large,
    this.icon,
    this.iconRight = false,
    this.width,
    this.child,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PremiumButtonStyle style;
  final ButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final double? width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    final content = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.w,
            child: const CircularProgressIndicator.adaptive(strokeWidth: 2.4),
          )
        : child ?? _buildContent();

    return SizedBox(
      width: width ?? double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: _minButtonHeight(size)),
        child: AdaptiveButton.child(
          onPressed: enabled ? onPressed : null,
          enabled: enabled,
          style: _adaptiveStyle(style),
          size: _adaptiveSize(size),
          color: _adaptiveColor(style),
          child: content,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final textWidget = Text(
      text,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: switch (size) {
          ButtonSize.small => 14.sp,
          ButtonSize.medium => 15.sp,
          ButtonSize.large => 16.sp,
        },
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: 0,
      ),
    );

    if (icon == null) return textWidget;

    final iconWidget = Icon(
      icon,
      size: switch (size) {
        ButtonSize.small => 18.sp,
        ButtonSize.medium => 20.sp,
        ButtonSize.large => 22.sp,
      },
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: iconRight
          ? [
              Flexible(child: textWidget),
              SizedBox(width: 8.w),
              iconWidget,
            ]
          : [
              iconWidget,
              SizedBox(width: 8.w),
              Flexible(child: textWidget),
            ],
    );
  }
}

class GradientIconButton extends StatelessWidget {
  const GradientIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.size = 48,
    this.gradient,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return AdaptiveButton.icon(
      onPressed: onPressed,
      icon: icon,
      enabled: onPressed != null,
      color: AppColors.primary,
      size: AdaptiveButtonSize.large,
    );
  }
}

class PremiumFAB extends StatelessWidget {
  const PremiumFAB({
    required this.icon,
    super.key,
    this.onPressed,
    this.label,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AdaptiveFloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: label == null
          ? Icon(icon)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    label!,
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
