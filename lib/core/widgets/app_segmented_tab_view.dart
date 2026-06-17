import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// A full-width segmented tab view used as a drop-in replacement for the
/// `AdaptiveTabBarView` from `adaptive_platform_ui`.
///
/// The third-party widget renders an intrinsically sized
/// `CupertinoSlidingSegmentedControl` on iOS, which hugs its label content and
/// therefore appears as a small centered pill on wide screens (e.g. iPad). This
/// widget instead lays the segments out in a [Row] where each segment is wrapped
/// in [Expanded], so the header always fills the available width.
///
/// The constructor mirrors `AdaptiveTabBarView` (tabs, children, selectedColor,
/// backgroundColor, unselectedColor) so it can be swapped in without changing
/// the call sites.
class AppSegmentedTabView extends StatefulWidget {
  const AppSegmentedTabView({
    required this.tabs,
    required this.children,
    this.selectedColor,
    this.backgroundColor,
    this.unselectedColor,
    super.key,
  });

  /// Tab labels. Must have the same length as [children].
  final List<String> tabs;

  /// Tab content pages, one per entry in [tabs].
  final List<Widget> children;

  /// Background color of the selected pill. Defaults to [AppColors.surface]
  /// (white). The selected label color is derived for contrast.
  final Color? selectedColor;

  /// Background color of the header bar that contains the segments.
  /// Defaults to [AppColors.primary].
  final Color? backgroundColor;

  /// Text color for unselected segments. When omitted a muted variant of the
  /// header foreground is used.
  final Color? unselectedColor;

  @override
  State<AppSegmentedTabView> createState() => _AppSegmentedTabViewState();
}

class _AppSegmentedTabViewState extends State<AppSegmentedTabView> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSegmentTapped(int index) {
    if (index == _selectedIndex) return;
    unawaited(HapticFeedback.selectionClick());
    unawaited(
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onPageChanged(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = widget.backgroundColor ?? AppColors.primary;
    final pillColor = widget.selectedColor ?? AppColors.surface;
    final unselectedColor =
        widget.unselectedColor ?? Colors.white.withValues(alpha: 0.85);

    return Column(
      children: [
        Container(
          color: headerColor,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                for (var i = 0; i < widget.tabs.length; i++) ...[
                  if (i > 0) SizedBox(width: 4.w),
                  Expanded(
                    child: _SegmentButton(
                      label: widget.tabs[i],
                      selected: i == _selectedIndex,
                      pillColor: pillColor,
                      unselectedColor: unselectedColor,
                      onTap: () => _onSegmentTapped(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.pillColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color pillColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? pillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 8.w),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : unselectedColor,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
