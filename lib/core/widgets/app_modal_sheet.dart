import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// App-standard modal sheet built on WoltModalSheet.
///
/// Keeps sheet motion, top-bar behavior, drag handle, safe area, and corner
/// treatment consistent across screens while avoiding duplicated modal code.
class AppModalSheet {
  const AppModalSheet._();

  static WoltModalSheetPage page({
    required BuildContext context,
    required Widget child,
    String? title,
    bool forceMaxHeight = false,
    bool showCloseButton = true,
    double maxHeightFactor = 0.9,
    Widget? stickyActionBar,
    Widget? leadingNavBarWidget,
    Widget? trailingNavBarWidget,
  }) {
    return WoltModalSheetPage(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      forceMaxHeight: forceMaxHeight,
      hasSabGradient: stickyActionBar != null,
      stickyActionBar: stickyActionBar,
      topBarTitle: _buildTitle(title),
      leadingNavBarWidget: leadingNavBarWidget,
      isTopBarLayerAlwaysVisible:
          title != null ||
          showCloseButton ||
          leadingNavBarWidget != null ||
          trailingNavBarWidget != null,
      trailingNavBarWidget: _buildTrailingNavBarWidget(
        context,
        showCloseButton: showCloseButton,
        trailingNavBarWidget: trailingNavBarWidget,
      ),
      child: SafeArea(
        top: false,
        child: MaxWidthContainer(
          maxWidth: context.isPhone ? double.infinity : 600,
          child: forceMaxHeight
              ? SizedBox(
                  height: _resolvedContentHeight(
                    context,
                    title: title,
                    showCloseButton: showCloseButton,
                    leadingNavBarWidget: leadingNavBarWidget,
                    trailingNavBarWidget: trailingNavBarWidget,
                    maxHeightFactor: maxHeightFactor,
                  ),
                  child: child,
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.sizeOf(context).height * maxHeightFactor,
                  ),
                  child: child,
                ),
        ),
      ),
    );
  }

  static double _resolvedContentHeight(
    BuildContext context, {
    required String? title,
    required bool showCloseButton,
    required Widget? leadingNavBarWidget,
    required Widget? trailingNavBarWidget,
    required double maxHeightFactor,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * maxHeightFactor;
    final hasTopBar =
        title != null ||
        showCloseButton ||
        leadingNavBarWidget != null ||
        trailingNavBarWidget != null;
    final reservedHeight =
        (hasTopBar ? 64.h : 0) +
        MediaQuery.paddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;
    final resolvedHeight = maxHeight - reservedHeight;
    final minHeight = screenHeight < 600 ? 240.0 : 320.0;

    if (resolvedHeight >= minHeight) return resolvedHeight;
    return maxHeight < minHeight ? maxHeight : minHeight;
  }

  static SliverWoltModalSheetPage sliverPage({
    required BuildContext context,
    required List<Widget> Function(BuildContext context) sliversBuilder,
    String? title,
    bool forceMaxHeight = false,
    bool showCloseButton = true,
    Widget? stickyActionBar,
    Widget? leadingNavBarWidget,
    Widget? trailingNavBarWidget,
  }) {
    return SliverWoltModalSheetPage(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      forceMaxHeight: forceMaxHeight,
      hasSabGradient: stickyActionBar != null,
      stickyActionBar: stickyActionBar,
      topBarTitle: _buildTitle(title),
      leadingNavBarWidget: leadingNavBarWidget,
      isTopBarLayerAlwaysVisible:
          title != null ||
          showCloseButton ||
          leadingNavBarWidget != null ||
          trailingNavBarWidget != null,
      trailingNavBarWidget: _buildTrailingNavBarWidget(
        context,
        showCloseButton: showCloseButton,
        trailingNavBarWidget: trailingNavBarWidget,
      ),
      mainContentSliversBuilder: sliversBuilder,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool barrierDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool forceMaxHeight = false,
    bool showDragHandle = false,
    bool showCloseButton = true,
    double maxHeightFactor = 0.9,
    Widget? stickyActionBar,
    Widget? leadingNavBarWidget,
    Widget? trailingNavBarWidget,
  }) {
    return showPages<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      showDragHandle: showDragHandle,
      pageListBuilder: (sheetContext) => [
        page(
          context: sheetContext,
          title: title,
          forceMaxHeight: forceMaxHeight,
          showCloseButton: showCloseButton,
          maxHeightFactor: maxHeightFactor,
          stickyActionBar: stickyActionBar,
          leadingNavBarWidget: leadingNavBarWidget,
          trailingNavBarWidget: trailingNavBarWidget,
          child: child,
        ),
      ],
    );
  }

  static Future<T?> showSlivers<T>({
    required BuildContext context,
    required List<Widget> Function(BuildContext context) sliversBuilder,
    String? title,
    bool barrierDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool forceMaxHeight = false,
    bool showDragHandle = false,
    bool showCloseButton = true,
    Widget? stickyActionBar,
    Widget? leadingNavBarWidget,
    Widget? trailingNavBarWidget,
  }) {
    return showPages<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      showDragHandle: showDragHandle,
      pageListBuilder: (sheetContext) => [
        sliverPage(
          context: sheetContext,
          title: title,
          forceMaxHeight: forceMaxHeight,
          showCloseButton: showCloseButton,
          stickyActionBar: stickyActionBar,
          leadingNavBarWidget: leadingNavBarWidget,
          trailingNavBarWidget: trailingNavBarWidget,
          sliversBuilder: sliversBuilder,
        ),
      ],
    );
  }

  static Future<T?> showPages<T>({
    required BuildContext context,
    required List<SliverWoltModalSheetPage> Function(BuildContext sheetContext)
    pageListBuilder,
    bool barrierDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool showDragHandle = false,
    int initialPageIndex = 0,
  }) {
    return WoltModalSheet.show<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      useRootNavigator: useRootNavigator,
      modalTypeBuilder: _modalTypeBuilder,
      pageIndexNotifier: initialPageIndex == 0
          ? null
          : ValueNotifier(initialPageIndex),
      pageListBuilder: pageListBuilder,
    );
  }

  static Future<T?> showActions<T>({
    required BuildContext context,
    required String title,
    required List<AppModalAction> actions,
    String? description,
    bool barrierDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool showDragHandle = false,
    bool showCloseButton = true,
    double maxHeightFactor = 0.82,
  }) {
    return show<T>(
      context: context,
      title: title,
      barrierDismissible: barrierDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      maxHeightFactor: maxHeightFactor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null) ...[
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            ...actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == actions.length - 1 ? 0 : 12.h,
                ),
                child: _AppModalActionTile(action: action),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _buildTitle(String? title) {
    if (title == null) return const SizedBox.shrink();
    return Text(
      title,
      maxLines: 2,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  static Widget? _buildTrailingNavBarWidget(
    BuildContext context, {
    required bool showCloseButton,
    Widget? trailingNavBarWidget,
  }) {
    final closeButton = showCloseButton
        ? IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null;

    if (trailingNavBarWidget == null) {
      return closeButton;
    }

    if (closeButton == null) {
      return trailingNavBarWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        trailingNavBarWidget,
        SizedBox(width: 4.w),
        closeButton,
      ],
    );
  }

  static WoltModalType _modalTypeBuilder(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.compact) {
      return WoltModalType.bottomSheet();
    }
    if (width < Breakpoints.medium) {
      return WoltModalType.dialog();
    }
    // On tablets and larger screens (iPad, desktop) use a full-width bottom
    // sheet instead of a side sheet. WoltSideSheetType caps its width at ~524pt
    // and anchors to the right edge, which leaves the left half of the screen
    // uncovered on large iPads — producing a broken half-screen layout.
    // A bottom sheet spans the full available width on all screen sizes.
    return WoltModalType.bottomSheet();
  }
}

class AppModalAction {
  const AppModalAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.accentColor,
    this.trailing,
    this.closeOnTap = true,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool closeOnTap;
  final bool isDestructive;
}

class _AppModalActionTile extends StatelessWidget {
  const _AppModalActionTile({required this.action});

  final AppModalAction action;

  @override
  Widget build(BuildContext context) {
    final accent = action.isDestructive
        ? AppColors.error
        : action.accentColor ?? AppColors.primary;
    final foreground = action.isDestructive
        ? AppColors.error
        : AppColors.textPrimary;

    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        if (action.closeOnTap) {
          Navigator.of(context).pop();
        }
        action.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: accent.withValues(
              alpha: action.isDestructive ? 0.28 : 0.16,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(action.icon, color: accent, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  if (action.subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      action.subtitle!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action.trailing != null) ...[
              SizedBox(width: 12.w),
              action.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
