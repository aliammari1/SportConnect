import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ── Vehicle form field name constants ─────────────────────────────────────────

abstract final class VehicleFormFields {
  static const make = 'make';
  static const model = 'model';
  static const year = 'year';
  static const color = 'color';
  static const licensePlate = 'license_plate';
  static const seats = 'seats';
}

// ── Private helpers ───────────────────────────────────────────────────────────

String _vehicleColorLabel(BuildContext context, String label) {
  final l10n = AppLocalizations.of(context);
  return switch (label) {
    'Black' => l10n.black,
    'White' => l10n.white,
    'Grey' => l10n.grey,
    'Silver' => l10n.silver,
    'Blue' => l10n.blue,
    'Red' => l10n.red,
    'Green' => l10n.green,
    'Beige / Brown' => l10n.beige_brown,
    _ => label,
  };
}

String? _reactiveErrorText(
  AbstractControl<dynamic> control,
  Map<String, String Function(Object)>? validationMessages,
  BuildContext? context,
) {
  if (!(control.touched && control.invalid)) return null;
  if (control.errors.isEmpty) return null;

  final key = control.errors.keys.first;
  final error = control.errors[key];
  final builder = validationMessages?[key];

  if (builder != null) return builder((error ?? key) as Object);
  if (error is String) return error;
  return context == null ? null : AppLocalizations.of(context).invalidValue;
}

class _VehicleColorOption {
  const _VehicleColorOption({
    required this.label,
    required this.color,
    this.aliases = const [],
  });

  final String label;
  final Color color;
  final List<String> aliases;
}

const List<_VehicleColorOption> _vehicleColorOptions = [
  _VehicleColorOption(
    label: 'Black',
    color: Color(0xFF111827),
    aliases: ['black', 'noir'],
  ),
  _VehicleColorOption(
    label: 'White',
    color: Color(0xFFF8FAFC),
    aliases: ['white', 'blanc', 'pearl'],
  ),
  _VehicleColorOption(
    label: 'Grey',
    color: Color(0xFF6B7280),
    aliases: ['grey', 'gray', 'gris', 'anthracite'],
  ),
  _VehicleColorOption(
    label: 'Silver',
    color: Color(0xFFCBD5E1),
    aliases: ['silver', 'argent'],
  ),
  _VehicleColorOption(
    label: 'Blue',
    color: Color(0xFF2563EB),
    aliases: ['blue', 'bleu', 'navy', 'midnight'],
  ),
  _VehicleColorOption(
    label: 'Red',
    color: Color(0xFFDC2626),
    aliases: ['red', 'rouge', 'bordeaux', 'burgundy'],
  ),
  _VehicleColorOption(
    label: 'Green',
    color: Color(0xFF16A34A),
    aliases: ['green', 'vert'],
  ),
  _VehicleColorOption(
    label: 'Beige / Brown',
    color: Color(0xFF92400E),
    aliases: ['brown', 'marron', 'bronze', 'champagne', 'beige'],
  ),
];

String _normalizeVehicleColorText(String? raw) {
  return (raw ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zàâäéèêëîïôöùûüç\s-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}

_VehicleColorOption? _matchedVehicleColor(String? raw) {
  final normalized = _normalizeVehicleColorText(raw);
  if (normalized.isEmpty) return null;

  for (final option in _vehicleColorOptions) {
    if (option.label.toLowerCase() == normalized) return option;
    for (final alias in option.aliases) {
      if (normalized.contains(alias)) return option;
    }
  }

  return null;
}

bool _isLightVehicleColor(Color color) => color.computeLuminance() > 0.68;

// ── Vehicle UI Components ─────────────────────────────────────────────────────

class VehicleLiveSummary extends StatelessWidget {
  const VehicleLiveSummary({
    required this.form,
    required this.accent,
    super.key,
  });

  final FormGroup form;
  final Color accent;

  String _stringValue(String controlName) {
    return (form.control(controlName).value as String? ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final make = _stringValue(VehicleFormFields.make);
    final model = _stringValue(VehicleFormFields.model);
    final year = _stringValue(VehicleFormFields.year);
    final color = _stringValue(VehicleFormFields.color);
    final plate = _stringValue(VehicleFormFields.licensePlate);
    final seats = _stringValue(VehicleFormFields.seats);
    final colorOption = _matchedVehicleColor(color);
    final previewColor = colorOption?.color ?? AppColors.primary;
    final isLightColor = _isLightVehicleColor(previewColor);

    final hasIdentity = make.isNotEmpty || model.isNotEmpty;
    final title = hasIdentity
        ? [make, model].where((value) => value.isNotEmpty).join(' ')
        : l10n.vehicle_details;

    final subtitle = color.isNotEmpty
        ? [color, if (year.isNotEmpty) year].join(' • ')
        : l10n.addColorAndPlateSoRidersCanFindYou;

    final detailsParts = [
      if (plate.isNotEmpty) plate.toUpperCase(),
      if (seats.isNotEmpty) '$seats ${seats == '1' ? l10n.seat : l10n.seats}',
    ];

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: previewColor,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isLightColor
                    ? AppColors.border
                    : Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: previewColor.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              color: isLightColor ? AppColors.textPrimary : Colors.white,
              size: 29.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (detailsParts.isEmpty)
                      _VehicleMiniTag(
                        text: l10n.recognition_details_appear_here,
                        accent: accent,
                        muted: true,
                      )
                    else
                      ...detailsParts.map(
                        (detail) => _VehicleMiniTag(
                          text: detail,
                          accent: accent,
                        ),
                      ),
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

class _VehicleMiniTag extends StatelessWidget {
  const _VehicleMiniTag({
    required this.text,
    required this.accent,
    this.muted = false,
  });

  final String text;
  final Color accent;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.textSecondary.withValues(alpha: 0.06)
            : accent.withValues(alpha: 0.085),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: muted ? AppColors.textSecondary : accent,
        ),
      ),
    );
  }
}

class VehicleSectionCard extends StatelessWidget {
  const VehicleSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.children,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.46),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.022),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: accent, size: 19.sp),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        height: 1.28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: 13.h),
            children[i],
          ],
        ],
      ),
    );
  }
}

class VehicleTextField extends StatelessWidget {
  const VehicleTextField({
    required this.formControlName,
    required this.label,
    required this.hintText,
    required this.icon,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validationMessages,
    super.key,
  });

  final String formControlName;
  final String label;
  final String hintText;
  final String? helperText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Map<String, String Function(Object)>? validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final errorText = _reactiveErrorText(
          control,
          validationMessages,
          context,
        );
        final hasError = errorText != null;
        final hasValue = (control.value ?? '').trim().isNotEmpty;

        final borderColor = hasError
            ? AppColors.error.withValues(alpha: 0.72)
            : hasValue
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.border.withValues(alpha: 0.38);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.085),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: hasError ? AppColors.error : AppColors.primary,
                      size: 17.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AdaptiveReactiveTextField(
                      formControlName: formControlName,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      textCapitalization: TextCapitalization.sentences,
                      hintText: hintText,
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : helperText == null
                  ? const SizedBox.shrink(key: ValueKey('no-helper'))
                  : _VehicleFieldMessage(
                      key: ValueKey(helperText),
                      text: helperText!,
                      color: AppColors.textSecondary,
                      icon: Icons.info_outline_rounded,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class VehicleColorSelector extends StatefulWidget {
  const VehicleColorSelector({
    required this.formControlName,
    required this.label,
    required this.validationMessages,
    super.key,
  });

  final String formControlName;
  final String label;
  final Map<String, String Function(Object)> validationMessages;

  @override
  State<VehicleColorSelector> createState() => _VehicleColorSelectorState();
}

class _VehicleColorSelectorState extends State<VehicleColorSelector> {
  bool _showCustomInput = false;

  bool _isCommonValue(String value) {
    return _vehicleColorOptions.any(
      (option) => option.label.toLowerCase() == value.trim().toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: widget.formControlName,
      builder: (context, control, _) {
        final l10n = AppLocalizations.of(context);
        final value = (control.value ?? '').trim();
        final matched = _matchedVehicleColor(value);
        final isCustomValue = value.isNotEmpty && !_isCommonValue(value);
        final errorText = _reactiveErrorText(
          control,
          widget.validationMessages,
          context,
        );
        final hasError = errorText != null;
        final shouldShowCustom = _showCustomInput || isCustomValue;

        void selectColor(_VehicleColorOption option) {
          unawaited(HapticFeedback.selectionClick());
          setState(() => _showCustomInput = false);
          control
            ..updateValue(option.label)
            ..markAsTouched();
        }

        void useCustom() {
          unawaited(HapticFeedback.selectionClick());
          setState(() => _showCustomInput = true);
          if (_isCommonValue(value)) {
            control.updateValue('');
          }
          control.markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 9.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final option in _vehicleColorOptions)
                  _ColorChoiceChip(
                    option: option,
                    selected:
                        _isCommonValue(value) &&
                        value.toLowerCase() == option.label.toLowerCase(),
                    onTap: () => selectColor(option),
                  ),
                _OtherColorChip(
                  selected: shouldShowCustom,
                  onTap: useCustom,
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: shouldShowCustom
                  ? Padding(
                      key: const ValueKey('custom-color-input'),
                      padding: EdgeInsets.only(top: 11.h),
                      child: _CustomVehicleColorInput(
                        formControlName: widget.formControlName,
                        hintText: l10n.champagne_pearl_white_bordeaux,
                        color: matched?.color ?? AppColors.primary,
                        hasError: hasError,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-custom-color')),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : _VehicleFieldMessage(
                      key: ValueKey('color-$value-${matched?.label}'),
                      text: value.isEmpty
                          ? l10n.chooseACommonColorOrUseOtherColor
                          : matched != null
                          ? l10n.selectedColor(
                              _vehicleColorLabel(context, matched.label),
                            )
                          : l10n.customColorWillBeShownToRidersAsWritten,
                      color: AppColors.textSecondary,
                      icon: value.isEmpty
                          ? Icons.info_outline_rounded
                          : Icons.palette_rounded,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorChoiceChip extends StatelessWidget {
  const _ColorChoiceChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _VehicleColorOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = _isLightVehicleColor(option.color);

    return AdaptiveTapSurface(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.55)
                : AppColors.border.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight
                      ? AppColors.border
                      : Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            SizedBox(width: 7.w),
            Text(
              _vehicleColorLabel(context, option.label),
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherColorChip extends StatelessWidget {
  const _OtherColorChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveTapSurface(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.55)
                : AppColors.border.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_rounded,
              size: 14.sp,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              l10n.other_color,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomVehicleColorInput extends StatelessWidget {
  const _CustomVehicleColorInput({
    required this.formControlName,
    required this.hintText,
    required this.color,
    required this.hasError,
  });

  final String formControlName;
  final String hintText;
  final Color color;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.error.withValues(alpha: 0.72)
        : AppColors.border.withValues(alpha: 0.42);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _isLightVehicleColor(color)
                    ? AppColors.border
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: AdaptiveReactiveTextField(
              formControlName: formControlName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              hintText: hintText,
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}

class _VehicleFieldMessage extends StatelessWidget {
  const _VehicleFieldMessage({
    required this.text,
    required this.color,
    required this.icon,
    super.key,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12.5.sp, color: color),
          SizedBox(width: 5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 140.ms);
  }
}

class LicensePlateInput extends StatelessWidget {
  const LicensePlateInput({
    required this.formControlName,
    required this.label,
    required this.hintText,
    required this.helperText,
    required this.validationMessages,
    super.key,
  });

  final String formControlName;
  final String label;
  final String hintText;
  final String helperText;
  final Map<String, String Function(Object)> validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final errorText = _reactiveErrorText(
          control,
          validationMessages,
          context,
        );
        final hasError = errorText != null;
        final hasValue = (control.value ?? '').trim().isNotEmpty;

        final borderColor = hasError
            ? AppColors.error.withValues(alpha: 0.72)
            : hasValue
            ? AppColors.primary.withValues(alpha: 0.24)
            : AppColors.border.withValues(alpha: 0.42);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Center(
                      child: Text(
                        'FR',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AdaptiveReactiveTextField(
                      formControlName: formControlName,
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      hintText: hintText,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : _VehicleFieldMessage(
                      key: ValueKey(helperText),
                      text: helperText,
                      color: AppColors.textSecondary,
                      icon: Icons.privacy_tip_outlined,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class SeatChipSelector extends StatelessWidget {
  const SeatChipSelector({
    required this.formControlName,
    required this.label,
    required this.validationMessages,
    super.key,
  });

  final String formControlName;
  final String label;
  final Map<String, String Function(Object)> validationMessages;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: formControlName,
      builder: (context, control, _) {
        final l10n = AppLocalizations.of(context);
        final selected = int.tryParse(control.value ?? '') ?? 3;
        final errorText = _reactiveErrorText(
          control,
          validationMessages,
          context,
        );
        final hasError = errorText != null;

        void updateSeats(int value) {
          unawaited(HapticFeedback.selectionClick());
          control
            ..updateValue(value.toString())
            ..markAsTouched();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChoiceHeader(
              label: label,
              helper: l10n.chooseSeatsAvailableForPassengers,
              icon: Icons.event_seat_rounded,
              hasError: hasError,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                for (var seats = 1; seats <= 4; seats++) ...[
                  Expanded(
                    child: _NumberChoiceChip(
                      value: seats,
                      selected: selected == seats,
                      onTap: () => updateSeats(seats),
                    ),
                  ),
                  if (seats < 4) SizedBox(width: 8.w),
                ],
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: hasError
                  ? _VehicleFieldMessage(
                      key: ValueKey(errorText),
                      text: errorText,
                      color: AppColors.error,
                      icon: Icons.error_outline_rounded,
                    )
                  : _VehicleFieldMessage(
                      key: ValueKey('$selected-seat-helper'),
                      text:
                          '$selected ${selected == 1 ? l10n.seat : l10n.seats}',
                      color: AppColors.textSecondary,
                      icon: Icons.info_outline_rounded,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _NumberChoiceChip extends StatelessWidget {
  const _NumberChoiceChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      color: selected
          ? AppColors.primary
          : AppColors.background.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(13.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 46.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.45),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: Offset(0, 5.h),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceHeader extends StatelessWidget {
  const _ChoiceHeader({
    required this.label,
    required this.helper,
    required this.icon,
    required this.hasError,
  });

  final String label;
  final String helper;
  final IconData icon;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: hasError ? AppColors.error : AppColors.primary,
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: hasError ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                helper,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
