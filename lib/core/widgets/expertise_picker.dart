import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/models/user/user_enums.dart';

class ExpertisePicker extends StatefulWidget {
  const ExpertisePicker({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
    required this.textColor,
    required this.cardBg,
    super.key,
    this.hint = 'Select your expertise level',
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final Expertise? value;
  final ValueChanged<Expertise> onChanged;
  final Color accent;
  final Color textColor;
  final Color cardBg;
  final String? errorText;
  final bool enabled;

  @override
  State<ExpertisePicker> createState() => _ExpertisePickerState();
}

class _ExpertisePickerState extends State<ExpertisePicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled) return;
    setState(() => _expanded = !_expanded);
    unawaited(_expanded ? _expandCtrl.forward() : _expandCtrl.reverse());
    unawaited(HapticFeedback.selectionClick());
  }

  void _select(Expertise expertise) {
    widget.onChanged(expertise);
    if (_expanded) {
      setState(() => _expanded = false);
      unawaited(_expandCtrl.reverse());
    }
    unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;
    final accent = widget.errorText == null ? widget.accent : Colors.redAccent;
    final triggerBorderColor = widget.errorText == null
        ? (_expanded || hasValue
              ? widget.accent
              : widget.accent.withValues(alpha: 0.2))
        : Colors.redAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.label,
          hint: hasValue ? 'Selected' : 'Tap to select',
          child: GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.06),
                borderRadius: _expanded
                    ? BorderRadius.vertical(top: Radius.circular(14.r))
                    : BorderRadius.circular(14.r),
                border: Border.all(
                  color: triggerBorderColor,
                  width: _expanded ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: accent,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: accent.withValues(alpha: 0.75),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.value?.displayName ?? widget.hint,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: hasValue
                                ? widget.textColor
                                : widget.textColor.withValues(alpha: 0.38),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: accent,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Container(
            decoration: BoxDecoration(
              color: widget.cardBg,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(14.r),
              ),
              border: Border(
                left: BorderSide(color: widget.accent, width: 2),
                right: BorderSide(color: widget.accent, width: 2),
                bottom: BorderSide(color: widget.accent, width: 2),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
              child: Column(
                children: Expertise.values
                    .map(
                      (expertise) => _ExpertiseOption(
                        expertise: expertise,
                        selected: expertise == widget.value,
                        accent: widget.accent,
                        textColor: widget.textColor,
                        onTap: () => _select(expertise),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ReactiveExpertisePicker extends StatelessWidget {
  const ReactiveExpertisePicker({
    required this.formControlName,
    required this.label,
    required this.accent,
    required this.textColor,
    required this.cardBg,
    super.key,
    this.hint = 'Select your expertise level',
    this.validationMessages,
    this.onChanged,
  });

  final String formControlName;
  final String label;
  final String hint;
  final Color accent;
  final Color textColor;
  final Color cardBg;
  final Map<String, String Function(Object)>? validationMessages;
  final ValueChanged<Expertise>? onChanged;

  @override
  Widget build(BuildContext context) => ReactiveFormField<Expertise, Expertise>(
    formControlName: formControlName,
    validationMessages: validationMessages,
    builder: (field) => ExpertisePicker(
      label: label,
      hint: hint,
      value: field.value,
      accent: accent,
      textColor: textColor,
      cardBg: cardBg,
      errorText: field.errorText,
      enabled: field.control.enabled,
      onChanged: (expertise) {
        field.didChange(expertise);
        onChanged?.call(expertise);
      },
    ),
  );
}

class _ExpertiseOption extends StatelessWidget {
  const _ExpertiseOption({
    required this.expertise,
    required this.selected,
    required this.accent,
    required this.textColor,
    required this.onTap,
  });

  final Expertise expertise;
  final bool selected;
  final Color accent;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: expertise.displayName,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.11) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                expertise.displayName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? accent : textColor.withValues(alpha: 0.72),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: 160.ms,
              child: Icon(
                Icons.check_rounded,
                color: accent,
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
