import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─── Seats Stepper Widget ─────────────────────────────────────────────────────

/// A polished stepper widget for selecting seat count.
///
/// Features:
/// - Haptic feedback on tap
/// - Animated value change
/// - Visual min/max bounds indication
/// - Accessible labels
class SeatsStepper extends StatelessWidget {
  const SeatsStepper({
    required this.value,
    super.key,
    this.min = 1,
    this.max = 8,
    this.onChanged,
    this.label,
    this.accentColor,
    this.enabled = true,
  });
  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;
  final String? label;
  final Color? accentColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    final l10n = AppLocalizations.of(context);
    final canDecrement = enabled && value > min;
    final canIncrement = enabled && value < max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: accent.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: accent.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                enabled: canDecrement,
                accent: accent,
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  onChanged?.call(value - 1);
                },
              ),
              SizedBox(width: 16.w),
              Semantics(
                label: '$value ${l10n.seats}',
                child: AnimatedSwitcher(
                  duration: 200.ms,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Row(
                    key: ValueKey(value),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_seat_rounded,
                        color: accent,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              _StepButton(
                icon: Icons.add_rounded,
                enabled: canIncrement,
                accent: accent,
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  onChanged?.call(value + 1);
                },
              ),
            ],
          ),
        ),
        // Remaining seats hint
        Padding(
          padding: EdgeInsets.only(top: 4.h, left: 4.w),
          child: Text(
            value == max
                ? l10n.maximumSeats
                : '${max - value} ${l10n.seatsLeft}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      color: enabled
          ? accent.withValues(alpha: 0.12)
          : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(10.r),
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: Icon(
          icon,
          color: enabled ? accent : AppColors.textTertiary,
          size: 20.sp,
        ),
      ),
    );
  }
}

// ─── Price Input Widget ───────────────────────────────────────────────────────

/// A polished price input with currency symbol, validation, and optional
/// distance-based price suggestion.
///
/// Features:
/// - Currency symbol prefix
/// - Numeric keyboard with decimals
/// - Real-time validation
/// - Optional suggested price display
/// - Animated error states
class PriceInput extends StatefulWidget {
  const PriceInput({
    super.key,
    this.initialValue,
    this.onChanged,
    this.label,
    this.suggestedPrice,
    this.minPrice,
    this.maxPrice,
    this.accentColor,
    this.enabled = true,
    this.validator,
  });
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? label;
  final double? suggestedPrice;
  final double? minPrice;
  final double? maxPrice;
  final Color? accentColor;
  final bool enabled;
  final String? Function(double?)? validator;

  @override
  State<PriceInput> createState() => PriceInputState();
}

class PriceInputState extends State<PriceInput> {
  static final _priceRegExp = RegExp(r'^\d{0,4}[.,]?\d{0,2}$');
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _hasInteracted = false;

  double? get value {
    final text = _controller.text.replaceAll(',', '.').trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  String? validate() {
    _hasInteracted = true;
    final error = widget.validator?.call(value);
    setState(() => _errorText = error);
    return error;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null
          ? widget.initialValue!.toStringAsFixed(2)
          : '',
    );
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _hasInteracted) {
        validate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _hasInteracted = true;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    widget.onChanged?.call(parsed);
    if (_errorText != null) validate();
  }

  void _applySuggestion() {
    if (widget.suggestedPrice == null) return;
    unawaited(HapticFeedback.lightImpact());
    _controller.text = widget.suggestedPrice!.toStringAsFixed(2);
    widget.onChanged?.call(widget.suggestedPrice);
    validate();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final fill = accent.withValues(alpha: 0.06);
    final hasError = _errorText != null;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label ?? l10n.priceSummaryLabel,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: hasError ? AppColors.error : accent.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: hasError ? AppColors.error : accent.withValues(alpha: 0.2),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13.r),
                    bottomLeft: Radius.circular(13.r),
                  ),
                ),
                child: Text(
                  '€',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
              Expanded(
                child: Semantics(
                  label: widget.label ?? l10n.priceSummaryLabel,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        _priceRegExp,
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 18.sp,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                    ),
                    onChanged: _onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 12.w),
            child: Text(
              _errorText!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3),
        if (widget.suggestedPrice != null && !hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: GestureDetector(
              onTap: _applySuggestion,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 14.sp, color: Colors.green),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.suggestedPriceValue(
                        widget.suggestedPrice!.toStringAsFixed(2),
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10n.tap_to_apply,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.green.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
      ],
    );
  }
}

// ─── Date Time Picker Widget ─────────────────────────────────────────────────

/// Enhanced date-time picker with validation for future dates.
///
/// Shows date and time in separate tappable chips.
/// Validates that chosen time is in the future and not too soon.
class DateTimePickerField extends StatelessWidget {
  const DateTimePickerField({
    super.key,
    this.selectedDate,
    this.selectedTime,
    this.onDateChanged,
    this.onTimeChanged,
    this.label,
    this.accentColor,
    this.minMinutesFromNow = 30,
    this.error,
  });
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final String? label;
  final Color? accentColor;
  final int minMinutesFromNow;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    final hasError = error != null;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: hasError ? AppColors.error : accent.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Row(
          children: [
            Expanded(
              child: _DateTimeChip(
                icon: Icons.calendar_today_rounded,
                text: selectedDate != null
                    ? _formatDate(context, selectedDate!)
                    : l10n.selectDatePlaceholder,
                accent: accent,
                hasError: hasError,
                onTap: () => _pickDate(context, accent),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DateTimeChip(
                icon: Icons.access_time_rounded,
                text: selectedTime != null
                    ? selectedTime!.format(context)
                    : l10n.selectTimePlaceholder,
                accent: accent,
                hasError: hasError,
                onTap: () => _pickTime(context, accent),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              error!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ).animate().fadeIn(duration: 200.ms),
      ],
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return l10n.today;
    }
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return l10n.tomorrow;
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDate(BuildContext context, Color accent) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: accent),
        ),
        child: child!,
      ),
    );
    if (result != null) onDateChanged?.call(result);
  }

  Future<void> _pickTime(BuildContext context, Color accent) async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: accent),
        ),
        child: child!,
      ),
    );
    if (result != null) onTimeChanged?.call(result);
  }
}

class _DateTimeChip extends StatelessWidget {
  const _DateTimeChip({
    required this.icon,
    required this.text,
    required this.accent,
    required this.hasError,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final Color accent;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = text == AppLocalizations.of(context).selectDatePlaceholder ||
        text == AppLocalizations.of(context).selectTimePlaceholder;

    return AdaptiveTapSurface(
      color: accent.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasError ? AppColors.error : accent.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: placeholder
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Preference Chip ──────────────────────────────────────────────────

/// A toggle chip for ride preferences (pets, smoking, luggage, etc.)
class PreferenceToggle extends StatelessWidget {
  const PreferenceToggle({
    required this.label,
    required this.icon,
    required this.value,
    super.key,
    this.onChanged,
    this.accentColor,
    this.enabled = true,
  });
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? accentColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        onTap: enabled
            ? () {
                unawaited(HapticFeedback.lightImpact());
                onChanged?.call(!value);
              }
            : null,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: value ? accent.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: value ? accent.withValues(alpha: 0.4) : AppColors.border,
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: value ? accent : AppColors.textTertiary,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  color: value ? accent : AppColors.textSecondary,
                ),
              ),
              if (value) ...[
                SizedBox(width: 6.w),
                Icon(Icons.check_circle_rounded, size: 14.sp, color: accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
