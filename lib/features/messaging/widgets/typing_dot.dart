import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// A single animated dot for the typing indicator.
/// Uses [AnimationController] with repeat() so it loops indefinitely.
class TypingDot extends StatefulWidget {
  const TypingDot({required this.index, super.key});

  final int index;

  @override
  State<TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (widget.index * 0.2).clamp(0.0, 1.0),
        (widget.index * 0.2 + 0.6).clamp(0.0, 1.0),
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity.drive(Tween(begin: 0.3, end: 1)),
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
