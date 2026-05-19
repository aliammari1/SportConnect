import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────

class PhoneNumber {
  const PhoneNumber({
    required this.countryCode,
    required this.dialCode,
    required this.number,
    required this.isValid,
  });

  final String countryCode;
  final String dialCode;

  /// National-significant number without the French leading trunk prefix `0`.
  ///
  /// Example:
  /// - UI: FR +33 | 6 12 34 56 78
  /// - number: 612345678
  /// - fullNumber: +33612345678
  final String number;

  final bool isValid;

  String get fullNumber => number.isEmpty ? '' : '+$dialCode$number';

  @override
  String toString() => fullNumber;
}

class Country {
  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.example,
    this.minLength = 6,
    this.maxLength = 15,
  });

  final String code;
  final String name;
  final String dialCode;
  final String flag;
  final String example;
  final int minLength;
  final int maxLength;
}

const Country france = Country(
  code: 'FR',
  name: 'France',
  dialCode: '33',
  flag: '🇫🇷',
  example: '6 12 34 56 78',
  minLength: 9,
  maxLength: 9,
);

// ─── Main Widget ──────────────────────────────────────────────────────────────

/// Production-style France phone input using an international prefix pattern.
///
/// Keeps the existing public API name `IntlPhoneInput` so current screens do
/// not break.
///
/// UX:
/// - visible fixed prefix: FR +33
/// - user enters the 9 national-significant digits: 6 12 34 56 78
/// - local pasted values like 06 12 34 56 78 are normalized safely
/// - international pasted values like +33612345678 / 0033612345678 work
/// - no fake country picker
/// - no aggressive focus border
/// - stores normalized full number as +33XXXXXXXXX
class IntlPhoneInput extends StatefulWidget {
  const IntlPhoneInput({
    super.key,
    this.initialValue,
    this.initialCountryCode = 'FR',
    this.label,
    this.hint,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.validator,
    this.accentColor,
    this.fillColor,
  });

  final String? initialValue;

  /// Kept only for API compatibility. This widget is intentionally France-only.
  final String initialCountryCode;

  final String? label;
  final String? hint;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<PhoneNumber>? onChanged;
  final String? Function(PhoneNumber?)? validator;
  final Color? accentColor;
  final Color? fillColor;

  @override
  State<IntlPhoneInput> createState() => IntlPhoneInputState();
}

class IntlPhoneInputState extends State<IntlPhoneInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String? _errorText;
  bool _hasInteracted = false;

  Country get selectedCountry => france;

  /// What appears after the visible +33 prefix.
  ///
  /// Valid final shape:
  /// 6 12 34 56 78
  String get _visibleDigits => _extractInternationalNationalDigits(
    _controller.text,
  );

  /// What the app stores after +33.
  ///
  /// This never includes the French domestic trunk prefix `0`.
  String get _normalizedDigits => _normalizeInternationalDigits(_visibleDigits);

  bool get _hasDigits => _visibleDigits.isNotEmpty;

  bool get _isOnlyLeadingZero => _visibleDigits == '0';

  bool get _isPhoneValid => _normalizedDigits.length == france.maxLength;

  PhoneNumber get phoneNumber => PhoneNumber(
    countryCode: france.code,
    dialCode: france.dialCode,
    number: _normalizedDigits,
    isValid: _isPhoneValid,
  );

  String get fullNumber => phoneNumber.fullNumber;

  String? validate() {
    _hasInteracted = true;

    final error = _validatePhone();

    setState(() {
      _errorText = error;
    });

    return error;
  }

  void setValue(String? value) {
    final nextDigits = _extractInternationalNationalDigits(value);
    final nextText = _formatInternationalNationalNumber(nextDigits);
    if (_controller.text == nextText) return;

    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    widget.onChanged?.call(phoneNumber);
  }

  @override
  void initState() {
    super.initState();

    final initialDigits = _extractInternationalNationalDigits(
      widget.initialValue,
    );

    _controller = TextEditingController(
      text: _formatInternationalNationalNumber(initialDigits),
    );

    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged?.call(phoneNumber);
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) return;

    if (!_focusNode.hasFocus && _hasInteracted) {
      setState(() {
        _errorText = _validatePhone();
      });
      return;
    }

    setState(() {});
  }

  String? _validatePhone() {
    final pn = phoneNumber;
    final customError = widget.validator?.call(pn);

    if (customError != null) return customError;

    if (!_isPhoneValid && _hasDigits) {
      return AppLocalizations.of(context).enter_a_valid_french_phone_number;
    }

    return null;
  }

  void _handleChanged(String _) {
    _hasInteracted = true;

    setState(() {
      if (_errorText != null) {
        _errorText = _validatePhone();
      }
    });

    widget.onChanged?.call(phoneNumber);
  }

  void _clear() {
    unawaited(HapticFeedback.selectionClick());

    _controller.clear();

    setState(() {
      _hasInteracted = true;
      _errorText = _validatePhone();
    });

    widget.onChanged?.call(phoneNumber);
  }

  String _supportText(
    BuildContext context, {
    required bool hasError,
    required bool showValid,
  }) {
    final l10n = AppLocalizations.of(context);

    if (hasError) return _errorText!;

    if (showValid) return phoneNumber.fullNumber;

    if (_isOnlyLeadingZero) {
      return l10n.phoneNumberSupportNoLeadingZero;
    }

    if (_hasDigits) {
      return l10n.phoneNumberDigitsCount(
        _normalizedDigits.length.clamp(0, france.maxLength),
        france.maxLength,
      );
    }

    return l10n.phoneNumberSupportPrivacy;
  }

  Color _supportColor({
    required Color accent,
    required bool hasError,
    required bool showValid,
  }) {
    if (hasError) return AppColors.error;
    if (showValid) return accent;
    if (_isOnlyLeadingZero) return AppColors.textSecondary;
    return AppColors.textSecondary;
  }

  IconData _supportIcon({
    required bool hasError,
    required bool showValid,
  }) {
    if (hasError) return Icons.error_outline_rounded;
    if (showValid) return Icons.check_circle_rounded;
    if (_hasDigits) return Icons.dialpad_rounded;
    return Icons.lock_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = widget.accentColor ?? AppColors.primary;
    final fill = widget.fillColor ?? AppColors.surface;

    final hasError = _errorText != null;
    final isFocused = _focusNode.hasFocus;
    final showValid = _hasDigits && _isPhoneValid && !hasError;
    final showClear = widget.enabled && _hasDigits && isFocused && !showValid;

    final title = widget.label ?? l10n.phone_number;

    final fieldBackground = !widget.enabled
        ? AppColors.textSecondary.withValues(alpha: 0.05)
        : Color.alphaBlend(
            isFocused ? accent.withValues(alpha: 0.035) : Colors.transparent,
            fill,
          );

    final borderColor = hasError
        ? AppColors.error.withValues(alpha: 0.68)
        : isFocused
        ? accent.withValues(alpha: 0.16)
        : AppColors.border.withValues(alpha: 0.32);

    final supportColor = _supportColor(
      accent: accent,
      hasError: hasError,
      showValid: showValid,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w800,
            color: hasError ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: fieldBackground,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isFocused ? 0.04 : 0.022,
                ),
                blurRadius: isFocused ? 18 : 10,
                offset: Offset(0, isFocused ? 7.h : 4.h),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              _InternationalPrefixBlock(
                accent: accent,
                enabled: widget.enabled,
              ),
              SizedBox(width: 12.w),
              Container(
                width: 1,
                height: 30.h,
                color: AppColors.border.withValues(alpha: 0.32),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Semantics(
                  label: title,
                  textField: true,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.telephoneNumber,
                    ],
                    enableSuggestions: false,
                    autocorrect: false,
                    cursorColor: accent,
                    inputFormatters: const [
                      _InternationalFrenchPhoneFormatter(),
                    ],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.1,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint ?? l10n.phoneNumberHint,
                      hintStyle: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 17.h),
                    ),
                    onChanged: _handleChanged,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: showValid
                    ? Padding(
                        key: const ValueKey('phone-valid-icon'),
                        padding: EdgeInsets.only(right: 14.w),
                        child:
                            Icon(
                              Icons.check_circle_rounded,
                              color: accent,
                              size: 20.sp,
                            ).animate().scale(
                              duration: 180.ms,
                              curve: Curves.easeOutBack,
                            ),
                      )
                    : showClear
                    ? IconButton(
                        key: const ValueKey('phone-clear-button'),
                        tooltip: AppLocalizations.of(
                          context,
                        ).clearPhoneNumber,
                        onPressed: _clear,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 42.w,
                          minHeight: 48.h,
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18.sp,
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('phone-empty-trailing'),
                        width: 14.w,
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Row(
            key: ValueKey(
              '${_supportText(
                context,
                hasError: hasError,
                showValid: showValid,
              )}-$supportColor',
            ),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _supportIcon(
                  hasError: hasError,
                  showValid: showValid,
                ),
                size: 13.sp,
                color: supportColor,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  _supportText(
                    context,
                    hasError: hasError,
                    showValid: showValid,
                  ),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: supportColor,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 160.ms),
        ),
      ],
    );
  }
}

// ─── UI Pieces ────────────────────────────────────────────────────────────────

class _InternationalPrefixBlock extends StatelessWidget {
  const _InternationalPrefixBlock({
    required this.accent,
    required this.enabled,
  });

  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final primary = enabled ? AppColors.textPrimary : AppColors.textSecondary;
    final secondary = enabled ? accent : AppColors.textSecondary;

    return SizedBox(
      height: 44.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            france.code,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '+${france.dialCode}',
            style: TextStyle(
              fontSize: 13.sp,
              height: 1,
              fontWeight: FontWeight.w900,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Formatting ───────────────────────────────────────────────────────────────

class _InternationalFrenchPhoneFormatter extends TextInputFormatter {
  const _InternationalFrenchPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _extractInternationalNationalDigits(newValue.text);
    final formatted = _formatInternationalNationalNumber(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Extracts the digits that should visually appear after the visible +33 prefix.
///
/// Accepts:
/// - 6 12 34 56 78   -> 612345678
/// - 06 12 34 56 78  -> 612345678 after the second digit is typed
/// - +33612345678    -> 612345678
/// - 0033612345678   -> 612345678
///
/// Special case:
/// - typing only `0` keeps `0` temporarily so the first tap does not disappear.
String _extractInternationalNationalDigits(String? rawValue) {
  if (rawValue == null || rawValue.trim().isEmpty) {
    return '';
  }

  var digits = rawValue.replaceAll(RegExp(r'[^\d]'), '');

  if (digits.startsWith('0033')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('33') && digits.length > france.maxLength) {
    digits = digits.substring(2);
  }

  if (digits == '0') {
    return digits;
  }

  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  if (digits.length > france.maxLength) {
    digits = digits.substring(0, france.maxLength);
  }

  return digits;
}

String _normalizeInternationalDigits(String visibleDigits) {
  if (visibleDigits == '0') return '';
  return visibleDigits;
}

/// Formats national-significant digits after +33:
/// 612345678 -> 6 12 34 56 78
///
/// Temporary leading 0:
/// 0 -> 0
String _formatInternationalNationalNumber(String digits) {
  if (digits.isEmpty) return '';

  if (digits == '0') return '0';

  final groups = <String>[];

  groups.add(digits.substring(0, 1));

  for (var i = 1; i < digits.length; i += 2) {
    final end = (i + 2 < digits.length) ? i + 2 : digits.length;
    groups.add(digits.substring(i, end));
  }

  return groups.join(' ');
}
