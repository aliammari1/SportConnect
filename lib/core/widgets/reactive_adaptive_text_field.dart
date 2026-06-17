import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reactive_cupertino_text_field/reactive_cupertino_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AdaptiveReactiveTextField extends StatelessWidget {
  const AdaptiveReactiveTextField({
    super.key,
    this.formControlName,
    this.formControl,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.validationMessages,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.enabled = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
  });

  final String? formControlName;
  final FormControl<String>? formControl;

  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Map<String, ValidationMessageFunction>? validationMessages;

  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool enabled;
  final bool autocorrect;
  final bool enableSuggestions;

  /// Same callback type as reactive_forms ReactiveTextField.
  final ReactiveFormFieldCallback<String>? onTap;
  final ReactiveFormFieldCallback<String>? onChanged;
  final ReactiveFormFieldCallback<String>? onEditingComplete;
  final ReactiveFormFieldCallback<String>? onSubmitted;

  bool _useCupertino(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  bool _shouldUnfocusOnComplete() {
    return textInputAction == TextInputAction.done ||
        textInputAction == TextInputAction.go ||
        textInputAction == TextInputAction.send ||
        textInputAction == TextInputAction.search;
  }

  void _defaultEditingComplete(BuildContext context) {
    if (_shouldUnfocusOnComplete()) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).nextFocus();
    }
  }

  FormControl<String>? _resolveControl(FormGroup? formGroup) {
    final directControl = formControl;
    if (directControl != null) return directControl;

    final name = formControlName;
    if (name == null || formGroup == null) return null;

    final control = formGroup.findControl(name);
    if (control is FormControl<String>) return control;

    return null;
  }

  Widget? _cupertinoPrefix(BuildContext context) {
    final icon = prefixIcon;
    if (icon == null) return null;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, end: 6),
      child: IconTheme(
        data: IconThemeData(
          size: 20,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        child: icon,
      ),
    );
  }

  Widget? _cupertinoSuffix(BuildContext context) {
    final icon = suffixIcon;
    if (icon == null) return null;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6, end: 10),
      child: IconTheme(
        data: IconThemeData(
          size: 20,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        child: icon,
      ),
    );
  }

  Widget _buildCupertino(
    BuildContext context, {
    required FormGroup? formGroup,
  }) {
    final field = _buildCupertinoField(context, formGroup: formGroup);

    // ReactiveCupertinoTextField (2.1.x) exposes no onChanged parameter, so the
    // Material branch's onChanged would otherwise be silently dropped on Apple
    // platforms. Bridge it by listening to the resolved control's value stream.
    final changed = onChanged;
    if (changed == null) return field;

    final control = _resolveControl(formGroup);
    if (control == null) return field;

    return _CupertinoOnChangedListener(
      control: control,
      onChanged: changed,
      child: field,
    );
  }

  Widget _buildCupertinoField(
    BuildContext context, {
    required FormGroup? formGroup,
  }) {
    return ReactiveCupertinoTextField<String>(
      formControlName: formControlName,
      formControl: formControl,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validationMessages: validationMessages,
      placeholder: hintText,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly || !enabled,
      autocorrect: !obscureText && autocorrect,
      enableSuggestions: !obscureText && enableSuggestions,

      onTap: onTap == null
          ? null
          : () {
              final control = _resolveControl(formGroup);
              if (control != null) onTap!(control);
            },

      onEditingComplete: () {
        final control = _resolveControl(formGroup);

        if (onEditingComplete != null && control != null) {
          onEditingComplete!(control);
          return;
        }

        _defaultEditingComplete(context);
      },

      onSubmitted: onSubmitted == null
          ? null
          : () {
              final control = _resolveControl(formGroup);
              if (control != null) onSubmitted!(control);
            },

      inputDecoration: InputDecoration(
        labelText: labelText,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),

      prefix: _cupertinoPrefix(context),
      suffix: _cupertinoSuffix(context),

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: enabled
            ? CupertinoColors.secondarySystemBackground.resolveFrom(context)
            : CupertinoColors.systemGrey5.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
        ),
      ),

      placeholderStyle: TextStyle(
        color: CupertinoColors.placeholderText.resolveFrom(context),
      ),
      cursorColor: CupertinoTheme.of(context).primaryColor,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_useCupertino(context)) {
      if (formControl != null) {
        return _buildCupertino(context, formGroup: null);
      }

      return ReactiveFormConsumer(
        builder: (context, formGroup, child) {
          return _buildCupertino(context, formGroup: formGroup);
        },
      );
    }

    return ReactiveTextField<String>(
      formControlName: formControlName,
      formControl: formControl,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validationMessages: validationMessages,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly || !enabled,
      autocorrect: !obscureText && autocorrect,
      enableSuggestions: !obscureText && enableSuggestions,
      ignorePointers: !enabled,
      canRequestFocus: enabled,

      onTap: onTap,
      onChanged: onChanged,

      onEditingComplete: (control) {
        if (onEditingComplete != null) {
          onEditingComplete!(control);
          return;
        }

        _defaultEditingComplete(context);
      },

      onSubmitted: onSubmitted,

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabled: enabled,
      ),
    );
  }
}

/// Subscribes to [control]'s value changes and invokes [onChanged], mirroring
/// the Material `ReactiveTextField.onChanged` behavior on the Cupertino path
/// (where the underlying field offers no onChanged callback).
class _CupertinoOnChangedListener extends StatefulWidget {
  const _CupertinoOnChangedListener({
    required this.control,
    required this.onChanged,
    required this.child,
  });

  final FormControl<String> control;
  final ReactiveFormFieldCallback<String> onChanged;
  final Widget child;

  @override
  State<_CupertinoOnChangedListener> createState() =>
      _CupertinoOnChangedListenerState();
}

class _CupertinoOnChangedListenerState
    extends State<_CupertinoOnChangedListener> {
  StreamSubscription<String?>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(_CupertinoOnChangedListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.control, widget.control)) {
      unawaited(_subscription?.cancel());
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.control.valueChanges.listen((_) {
      widget.onChanged(widget.control);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
