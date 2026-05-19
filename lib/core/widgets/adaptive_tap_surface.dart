import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Platform-adaptive pressable surface.
///
/// Uses Material ink on Android and a Cupertino-style gesture surface on Apple
/// platforms so custom cards/buttons do not require raw `Material` wrappers.
class AdaptiveTapSurface extends StatelessWidget {
  const AdaptiveTapSurface({
    required this.child,
    super.key,
    this.onTap,
    this.color = Colors.transparent,
    this.borderRadius,
    this.shape,
    this.customBorder,
    this.elevation = 0,
    this.shadowColor,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final ShapeBorder? customBorder;
  final double elevation;
  final Color? shadowColor;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectiveShape =
        shape ??
        customBorder ??
        (borderRadius != null
            ? RoundedRectangleBorder(borderRadius: borderRadius!)
            : null);

    if (!PlatformAdaptive.isApple) {
      return Material(
        color: color,
        shape: effectiveShape,
        elevation: elevation,
        shadowColor: shadowColor,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          customBorder: customBorder,
          child: child,
        ),
      );
    }

    final surface = _CupertinoTapFeedback(onTap: onTap, child: child);

    if (effectiveShape != null) {
      return DecoratedBox(
        decoration: ShapeDecoration(color: color, shape: effectiveShape),
        child: surface,
      );
    }

    if (borderRadius == null) {
      return ColoredBox(color: color, child: surface);
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius!,
        clipBehavior: clipBehavior,
        child: surface,
      ),
    );
  }
}

class _CupertinoTapFeedback extends StatefulWidget {
  const _CupertinoTapFeedback({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_CupertinoTapFeedback> createState() => _CupertinoTapFeedbackState();
}

class _CupertinoTapFeedbackState extends State<_CupertinoTapFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 110),
          opacity: _pressed ? 0.68 : 1,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
