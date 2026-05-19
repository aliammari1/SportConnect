import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';

class DateOfBirthField extends StatelessWidget {
  const DateOfBirthField({
    required this.formControlName,
    required this.label,
    required this.validationMessages,
    super.key,
  });

  final String formControlName;
  final String label;
  final Map<String, ValidationMessageFunction> validationMessages;

  Future<void> _pickDate(
    BuildContext context,
    ReactiveFormFieldState<DateTime, DateTime> field,
  ) async {
    unawaited(HapticFeedback.selectionClick());

    final selectedDate = await AdaptiveDatePicker.show(
      context: context,
      initialDate: _safeInitialDob(field.value),
      firstDate: DateTime(1950),
      lastDate: _adultCutoffDate(),
    );

    if (selectedDate == null) return;

    field.didChange(_dateOnly(selectedDate));
    field.control.markAsTouched();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormField<DateTime, DateTime>(
      formControlName: formControlName,
      validationMessages: validationMessages,
      builder: (field) {
        final value = field.value;
        final showError = field.control.touched && field.control.invalid;
        final errorText = showError ? field.errorText : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(
              text: label,
              hasError: showError,
            ),
            SizedBox(height: 8.h),
            AdaptiveTapSurface(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => _pickDate(context, field),
              child: Container(
                  height: 54.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
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
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 20.sp,
                        color: showError ? AppColors.error : AppColors.primary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          value == null
                              ? 'DD/MM/YYYY'
                              : _formatDateOfBirth(value),
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: value == null
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22.sp,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            _FieldErrorText(errorText),
          ],
        );
      },
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _adultCutoffDate({int years = 18}) {
  final today = DateTime.now();
  return DateTime(today.year - years, today.month, today.day);
}

String _formatDateOfBirth(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();

  return '$day/$month/$year';
}

DateTime _safeInitialDob(DateTime? value) {
  final firstDate = DateTime(1950);
  final lastDate = _adultCutoffDate();

  if (value == null) return DateTime(2000);

  final normalized = _dateOnly(value);

  if (normalized.isBefore(firstDate)) return firstDate;
  if (normalized.isAfter(lastDate)) return lastDate;

  return normalized;
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: text == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(text),
              padding: EdgeInsets.only(top: 6.h, left: 2.w),
              child: Text(
                text!,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
    );
  }
}
