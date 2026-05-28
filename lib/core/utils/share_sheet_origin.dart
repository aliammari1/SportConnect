import 'package:flutter/widgets.dart';

/// Returns a stable global rect for iOS/iPadOS share sheet popovers.
///
/// share_plus requires this on iPad. When no widget context is available
/// (for example from a view model fallback), use the center of the active view.
Rect shareSheetOrigin([BuildContext? context]) {
  final renderObject = context?.findRenderObject();
  if (renderObject is RenderBox && renderObject.hasSize) {
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isNotEmpty) {
    final view = views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final center = Offset(logicalSize.width / 2, logicalSize.height / 2);
    return center & const Size(1, 1);
  }

  return Offset.zero & const Size(1, 1);
}
