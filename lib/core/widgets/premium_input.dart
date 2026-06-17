import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Premium Text Field with modern design and animations
class PremiumTextField extends StatefulWidget {
  const PremiumTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.validator,
    this.showGlow = true,
  });
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final String? Function(String?)? validator;
  final bool showGlow;

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final AnimationController _glowController;
  bool _isFocused = false;
  bool _hasError = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    _glowController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    });
  }

  void _validate(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _hasError = error != null;
        _currentError = error;
      });
    }
  }

  Color get _borderColor {
    if (!widget.enabled) return AppColors.border.withValues(alpha: 0.5);
    if (_hasError || widget.errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.border;
  }

  Color get _glowColor {
    if (_hasError || widget.errorText != null) {
      return AppColors.error.withValues(alpha: 0.2);
    }
    return AppColors.primary.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _isFocused
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              )
              .animate(target: _isFocused ? 1 : 0)
              .slide(
                duration: 150.ms,
                begin: Offset.zero,
                end: const Offset(0.02, 0),
              ),
          SizedBox(height: 8.h),
        ],
        // Text field with glow
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                // Platform-adaptive corners
                borderRadius: BorderRadius.circular(
                  PlatformAdaptive.inputRadius,
                ),
                boxShadow: widget.showGlow && (_isFocused || _hasError)
                    ? [
                        BoxShadow(
                          color: _glowColor,
                          blurRadius: 12 * _glowController.value,
                          spreadRadius: 2 * _glowController.value,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.surfaceVariant.withValues(alpha: 0.5)
                  : AppColors.surfaceVariant.withValues(alpha: 0.3),
              // Platform-adaptive corners
              borderRadius: BorderRadius.circular(PlatformAdaptive.inputRadius),
              border: Border.all(
                color: _borderColor,
                width: _isFocused ? 2 : 1.5,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              onChanged: (value) {
                widget.onChanged?.call(value);
                _validate(value);
              },
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                border: InputBorder.none,
                counterText: widget.showCounter ? null : '',
                prefixIcon:
                    widget.prefix ??
                    (widget.prefixIcon != null
                        ? Container(
                            padding: EdgeInsets.only(left: 16.w, right: 12.w),
                            child: Icon(
                              widget.prefixIcon,
                              size: 22.sp,
                              color: _isFocused
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          )
                        : null),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 50.w,
                  minHeight: 22.h,
                ),
                suffixIcon:
                    widget.suffix ??
                    (widget.suffixIcon != null
                        ? GestureDetector(
                            onTap: () {
                              unawaited(HapticFeedback.lightImpact());
                              widget.onSuffixTap?.call();
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 12.w, right: 16.w),
                              child: Icon(
                                widget.suffixIcon,
                                size: 22.sp,
                                color: _isFocused
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          )
                        : null),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 50.w,
                  minHeight: 22.h,
                ),
              ),
            ),
          ),
        ),
        // Helper/Error text
        if (widget.helperText != null ||
            widget.errorText != null ||
            _currentError != null) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              if (widget.errorText != null || _currentError != null) ...[
                Icon(
                  Icons.error_outline_rounded,
                  size: 14.sp,
                  color: AppColors.error,
                ),
                SizedBox(width: 4.w),
              ],
              Expanded(
                child: Text(
                  widget.errorText ?? _currentError ?? widget.helperText ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: widget.errorText != null || _currentError != null
                        ? AppColors.error
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3),
        ],
      ],
    );
  }
}

/// Premium Search Field with enhanced styling
class PremiumSearchField extends StatefulWidget {
  const PremiumSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
    this.showFilterButton = false,
    this.onFilterTap,
    this.filterCount,
  });
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool readOnly;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;
  final int? filterCount;

  @override
  State<PremiumSearchField> createState() => _PremiumSearchFieldState();
}

class _PremiumSearchFieldState extends State<PremiumSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChange);
    }
    super.dispose();
  }

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onClear() {
    unawaited(HapticFeedback.lightImpact());
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        // Platform-adaptive search field
        borderRadius: BorderRadius.circular(PlatformAdaptive.searchRadius),
        border: PlatformAdaptive.isApple
            ? Border.all(
                color: AppColors.border.withValues(alpha: 0.15),
                width: 0.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: AppColors.textTertiary,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 16.h,
                ),
              ),
            ),
          ),
          // Clear button
          if (_hasText)
            GestureDetector(
                  onTap: _onClear,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 150.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          // Filter button
          if (widget.showFilterButton) ...[
            Container(width: 1.w, height: 24.h, color: AppColors.border),
            GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                widget.onFilterTap?.call();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 22.sp,
                      color: AppColors.primary,
                    ),
                    if (widget.filterCount != null && widget.filterCount! > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).value2(widget.filterCount!),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ] else
            SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

/// Premium OTP/PIN input field
class PremiumPinField extends StatefulWidget {
  const PremiumPinField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.obscureText = false,
    this.controller,
  });
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  State<PremiumPinField> createState() => _PremiumPinFieldState();
}

class _PremiumPinFieldState extends State<PremiumPinField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _pin = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChange);
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChange() {
    final text = _controller.text;
    if (text.length <= widget.length && text != _pin) {
      setState(() => _pin = text);
      widget.onChanged?.call(text);
      if (text.length == widget.length) {
        widget.onCompleted?.call(text);
        unawaited(HapticFeedback.heavyImpact());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          // Hidden text field
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
          // PIN boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final isFilled = index < _pin.length;
              final isActive = index == _pin.length && _focusNode.hasFocus;

              return Container(
                width: 48.w,
                height: 56.h,
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.primarySurface
                      : AppColors.surfaceVariant,
                  // Platform-adaptive PIN box corners
                  borderRadius: BorderRadius.circular(
                    PlatformAdaptive.isApple ? 16.r : 12.r,
                  ),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : isFilled
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                    width: isActive ? 2 : 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isFilled
                    ? Text(
                        widget.obscureText ? '•' : _pin[index],
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ).animate().scale(
                        duration: 100.ms,
                        begin: const Offset(0.5, 0.5),
                      )
                    : isActive
                    ? Container(
                            width: 2.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 400.ms)
                          .then()
                          .fadeOut(duration: 400.ms)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
