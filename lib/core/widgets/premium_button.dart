import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Premium Button Styles
enum PremiumButtonStyle { primary, secondary, success, danger, ghost, gold }

/// Premium Button Size
enum PremiumButtonSize { small, medium, large }

/// Premium Button - Modern, animated button with haptic feedback
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    required this.text,
    super.key,
    this.onPressed,
    this.style = PremiumButtonStyle.primary,
    this.size = PremiumButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.showShimmer = false,
    this.customWidth,
    this.customHeight,
  });
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final PremiumButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final bool showShimmer;
  final double? customWidth;
  final double? customHeight;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
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

  LinearGradient get _gradient {
    if (widget.isDisabled) {
      return LinearGradient(
        colors: [
          AppColors.textTertiary.withValues(alpha: 0.5),
          AppColors.textTertiary.withValues(alpha: 0.3),
        ],
      );
    }

    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return AppColors.primaryGradient;
      case PremiumButtonStyle.secondary:
        return const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
        );
      case PremiumButtonStyle.success:
        return AppColors.successGradient;
      case PremiumButtonStyle.danger:
        return const LinearGradient(
          colors: [AppColors.error, AppColors.errorDark],
        );
      case PremiumButtonStyle.ghost:
        return const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
      case PremiumButtonStyle.gold:
        return AppColors.goldGradient;
    }
  }

  Color get _shadowColor {
    if (widget.isDisabled) return Colors.transparent;

    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return AppColors.primary.withValues(alpha: 0.4);
      case PremiumButtonStyle.secondary:
        return AppColors.secondary.withValues(alpha: 0.3);
      case PremiumButtonStyle.success:
        return AppColors.success.withValues(alpha: 0.4);
      case PremiumButtonStyle.danger:
        return AppColors.error.withValues(alpha: 0.4);
      case PremiumButtonStyle.ghost:
        return Colors.transparent;
      case PremiumButtonStyle.gold:
        return AppColors.xpGold.withValues(alpha: 0.4);
    }
  }

  Color get _textColor {
    if (widget.isDisabled) return AppColors.textTertiary;

    switch (widget.style) {
      case PremiumButtonStyle.ghost:
        return AppColors.primary;
      default:
        return Colors.white;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h);
      case PremiumButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h);
      case PremiumButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 32.w, vertical: 18.h);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 13.sp;
      case PremiumButtonSize.medium:
        return 15.sp;
      case PremiumButtonSize.large:
        return 17.sp;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 16.sp;
      case PremiumButtonSize.medium:
        return 20.sp;
      case PremiumButtonSize.large:
        return 24.sp;
    }
  }

  double get _minHeight {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 44.h;
      case PremiumButtonSize.medium:
        return 52.h;
      case PremiumButtonSize.large:
        return 60.h;
    }
  }

  /// Platform-adaptive border radii
  /// iOS: Pill-shaped (Liquid Glass) | Android: Material standard
  double get _borderRadius {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return PlatformAdaptive.buttonRadiusSm;
      case PremiumButtonSize.medium:
        return PlatformAdaptive.buttonRadiusMd;
      case PremiumButtonSize.large:
        return PlatformAdaptive.buttonRadiusLg;
    }
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.isDisabled || widget.isLoading) return;
    if (!_isPressed) {
      _isPressed = true;
      _pressController.forward();
      unawaited(HapticFeedback.lightImpact());
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.isDisabled || widget.isLoading) return;
    if (_isPressed) {
      _isPressed = false;
      _pressController.reverse();
      widget.onPressed?.call();
      unawaited(HapticFeedback.mediumImpact());
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
    final minButtonHeight =
        widget.customHeight == null || widget.customHeight! < _minHeight
        ? _minHeight
        : widget.customHeight!;
    Widget button = AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final scale = 1.0 - (0.04 * _pressController.value);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: widget.fullWidth ? double.infinity : widget.customWidth,
          constraints: BoxConstraints(minHeight: minButtonHeight),
          padding: _padding,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(_borderRadius),
            // Platform-adaptive: ghost gets primary outline;
            // iOS: glass highlight border | Android: no extra border
            border: widget.style == PremiumButtonStyle.ghost
                ? Border.all(
                    color: AppColors.primary,
                    width: PlatformAdaptive.ghostBorderWidth,
                  )
                : PlatformAdaptive.buttonGlassBorder,
            boxShadow: widget.style != PremiumButtonStyle.ghost
                ? [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: _buildContent(),
        ),
      ),
    );

    if (widget.showShimmer && !widget.isDisabled && !widget.isLoading) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
            delay: 2000.ms,
            duration: 1500.ms,
            color: Colors.white.withValues(alpha: 0.2),
          );
    }

    return button;
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(_textColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: _textColor, size: _iconSize),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Text(
            widget.text,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w700,
              color: _textColor,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: 8.w),
          Icon(widget.trailingIcon, color: _textColor, size: _iconSize),
        ],
      ],
    );
  }
}

/// Icon-only premium button
class PremiumIconButton extends StatefulWidget {
  const PremiumIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.style = PremiumButtonStyle.primary,
    this.size = PremiumButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final PremiumButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final String? tooltip;

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
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

  double get _size {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 36.w;
      case PremiumButtonSize.medium:
        return 48.w;
      case PremiumButtonSize.large:
        return 56.w;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 18.sp;
      case PremiumButtonSize.medium:
        return 22.sp;
      case PremiumButtonSize.large:
        return 26.sp;
    }
  }

  LinearGradient get _gradient {
    if (widget.isDisabled) {
      return LinearGradient(
        colors: [
          AppColors.textTertiary.withValues(alpha: 0.5),
          AppColors.textTertiary.withValues(alpha: 0.3),
        ],
      );
    }

    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return AppColors.primaryGradient;
      case PremiumButtonStyle.secondary:
        return const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
        );
      case PremiumButtonStyle.success:
        return AppColors.successGradient;
      case PremiumButtonStyle.danger:
        return const LinearGradient(
          colors: [AppColors.error, AppColors.errorDark],
        );
      case PremiumButtonStyle.ghost:
        return const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
      case PremiumButtonStyle.gold:
        return AppColors.goldGradient;
    }
  }

  Color get _iconColor {
    if (widget.isDisabled) return AppColors.textTertiary;

    switch (widget.style) {
      case PremiumButtonStyle.ghost:
        return AppColors.primary;
      default:
        return Colors.white;
    }
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.isDisabled || widget.isLoading) return;
    if (!_isPressed) {
      _isPressed = true;
      _pressController.forward();
      unawaited(HapticFeedback.lightImpact());
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.isDisabled || widget.isLoading) return;
    if (_isPressed) {
      _isPressed = false;
      _pressController.reverse();
      widget.onPressed?.call();
      unawaited(HapticFeedback.mediumImpact());
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
    Widget button = AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final scale = 1.0 - (0.06 * _pressController.value);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            gradient: _gradient,
            shape: BoxShape.circle,
            // Platform-adaptive: glass border only on iOS
            border: widget.style == PremiumButtonStyle.ghost
                ? Border.all(
                    color: AppColors.primary,
                    width: PlatformAdaptive.ghostBorderWidth,
                  )
                : PlatformAdaptive.buttonGlassBorder,
            boxShadow: widget.style != PremiumButtonStyle.ghost
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: _iconSize * 0.8,
                    height: _iconSize * 0.8,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_iconColor),
                    ),
                  )
                : Icon(widget.icon, color: _iconColor, size: _iconSize),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = AdaptiveTooltip(message: widget.tooltip ?? '', child: button);
    }

    return button;
  }
}

/// Floating Action Button Premium style
class PremiumFAB extends StatefulWidget {
  const PremiumFAB({
    required this.icon,
    super.key,
    this.label,
    this.onPressed,
    this.isExtended = false,
    this.showPulse = false,
  });
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isExtended;
  final bool showPulse;

  @override
  State<PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<PremiumFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            if (widget.showPulse)
              Transform.scale(
                scale: 1.0 + (0.15 * _pulseController.value),
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(
                      alpha: 0.25 * (1 - _pulseController.value),
                    ),
                  ),
                ),
              ),
            // Main FAB
            child!,
          ],
        );
      },
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.mediumImpact());
          widget.onPressed?.call();
        },
        child: Container(
          height: 56.h,
          padding: widget.isExtended
              ? EdgeInsets.symmetric(horizontal: 24.w)
              : EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: widget.isExtended
                ? BorderRadius.circular(28.r)
                : BorderRadius.circular(56.r),
            // Platform-adaptive: glass highlight border only on iOS
            border: PlatformAdaptive.buttonGlassBorder,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 24.sp),
              if (widget.isExtended && widget.label != null) ...[
                SizedBox(width: 12.w),
                Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
