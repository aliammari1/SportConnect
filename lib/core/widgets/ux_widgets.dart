import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Animated status badge with transitions (#77)
class AnimatedStatusBadge extends StatelessWidget {
  const AnimatedStatusBadge({
    required this.label,
    required this.color,
    required this.icon,
    super.key,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(label),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipe action wrapper for list items (#76)
class SwipeActionTile extends StatelessWidget {
  const SwipeActionTile({
    required this.child,
    super.key,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftIcon = Icons.delete_rounded,
    this.rightIcon = Icons.archive_rounded,
    this.leftColor = AppColors.error,
    this.rightColor = AppColors.info,
    this.leftLabel,
    this.rightLabel,
  });
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final IconData leftIcon;
  final IconData rightIcon;
  final Color leftColor;
  final Color rightColor;
  final String? leftLabel;
  final String? rightLabel;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ?? UniqueKey(),
      background: _buildBackground(
        alignment: Alignment.centerLeft,
        color: rightColor,
        icon: rightIcon,
        label: rightLabel,
      ),
      secondaryBackground: _buildBackground(
        alignment: Alignment.centerRight,
        color: leftColor,
        icon: leftIcon,
        label: leftLabel,
      ),
      confirmDismiss: (direction) async {
        unawaited(HapticFeedback.mediumImpact());
        if (direction == DismissDirection.startToEnd) {
          onSwipeRight?.call();
        } else {
          onSwipeLeft?.call();
        }
        return false; // Don't actually dismiss — caller handles state
      },
      child: child,
    );
  }

  Widget _buildBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    String? label,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(width: 8.w),
          ],
          Icon(icon, color: Colors.white, size: 22.sp),
          if (alignment == Alignment.centerLeft) ...[
            SizedBox(width: 8.w),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Compact/Expanded list toggle (#81)
class ListViewToggle extends StatelessWidget {
  const ListViewToggle({
    required this.isCompact,
    required this.onToggle,
    super.key,
  });
  final bool isCompact;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleButton(
          icon: Icons.view_list_rounded,
          isSelected: !isCompact,
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            onToggle(false);
          },
          tooltip: AppLocalizations.of(context).expandedView,
        ),
        SizedBox(width: 4.w),
        _ToggleButton(
          icon: Icons.view_module_rounded,
          isSelected: isCompact,
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            onToggle(true);
          },
          tooltip: AppLocalizations.of(context).compactView,
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
