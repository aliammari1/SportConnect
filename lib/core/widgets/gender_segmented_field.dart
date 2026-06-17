import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';

abstract final class _GenderValue {
  static const male = 'Male';
  static const female = 'Female';
}

class GenderSegmentedField extends StatelessWidget {
  const GenderSegmentedField({
    required this.formControlName,
    required this.label,
    required this.maleLabel,
    required this.femaleLabel,
    required this.validationMessages,
    super.key,
  });

  final String formControlName;
  final String label;
  final String maleLabel;
  final String femaleLabel;
  final Map<String, ValidationMessageFunction> validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<String, String>(
      formControlName: formControlName,
      validationMessages: validationMessages,
      builder: (field) {
        final value = field.value;
        final showError = field.control.touched && field.control.invalid;
        final errorText = showError ? field.errorText : null;

        void selectGender(String nextValue) {
          if (value == nextValue) return;

          unawaited(HapticFeedback.selectionClick());
          field.didChange(nextValue);
          field.control.markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(
              text: label,
              hasError: showError,
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: showError
                      ? AppColors.error
                      : AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _GenderSegmentButton(
                      label: maleLabel,
                      icon: Icons.male_rounded,
                      selected: value == _GenderValue.male,
                      onTap: () => selectGender(_GenderValue.male),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _GenderSegmentButton(
                      label: femaleLabel,
                      icon: Icons.female_rounded,
                      selected: value == _GenderValue.female,
                      onTap: () => selectGender(_GenderValue.female),
                    ),
                  ),
                ],
              ),
            ),
            _FieldErrorText(errorText),
          ],
        );
      },
    );
  }
}

class _GenderSegmentButton extends StatelessWidget {
  const _GenderSegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: AdaptiveTapSurface(
          borderRadius: BorderRadius.circular(11.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 11.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18.sp,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.hasError,
  });

  final String text;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: hasError ? AppColors.error : AppColors.textSecondary,
      ),
    );
  }
}

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText(this.text);

  final String? text;

  @override
  Widget build(BuildContext context) {
    final errorText = text;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: errorText == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(errorText),
              padding: EdgeInsets.only(top: 6.h, left: 2.w),
              child: Text(
                errorText,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
    );
  }
}
