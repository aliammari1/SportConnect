import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

// ═══════════════════════════════════════════════════════════════════
// MATERIAL DESIGN 3 BREAKPOINTS
// ═══════════════════════════════════════════════════════════════════
// These align with the official Material Design 3 window size classes:
// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
//
// Production usage confirmed in:
// - Flutter framework's own about.dart (maxWidth: 600)
// - ResponsiveFramework package (1.4k+ stars)
// - adaptive_shell package (M3 compliant)
// - Google codelabs for responsive Flutter

/// Material Design 3 window size class breakpoints.
///
/// Use these instead of hardcoding magic numbers across screens.
class Breakpoints {
  Breakpoints._();

  /// Compact: phones in portrait (0–599dp).
  /// Single-column layouts, touch-first.
  static const double compact = 600;

  /// Medium: large phones, small tablets (600–839dp).
  /// Dual-pane capable, navigation rails possible.
  static const double medium = 840;

  /// Expanded: large tablets, foldables (840–1199dp).
  /// Complex multi-pane, persistent UI elements.
  static const double expanded = 1200;

  /// Large: desktop screens (1200–1599dp).
  /// Rich information architecture.
  static const double large = 1600;

  /// Extra large: large monitors (1920dp+).
  /// Expansive multi-column arrangements.
  static const double extraLarge = 1920;
}

// ═══════════════════════════════════════════════════════════════════
// NAMED MAX-WIDTH CONSTANTS
// ═══════════════════════════════════════════════════════════════════
// Use these semantic constants instead of scattering magic numbers.
// Aligned with production patterns from Flutter framework, MD3, and
// popular packages (ResponsiveFramework, adaptive_shell).

/// Maximum width for narrow forms (login, signup, password reset).
/// Matches Flutter's about.dart dialog constraint.
const double kMaxWidthFormNarrow = 500;

/// Maximum width for standard forms (profile edit, checkout, settings).
const double kMaxWidthForm = 600;

/// Maximum width for content cards and detail screens.
const double kMaxWidthContent = 700;

/// Maximum width for wide content (legal, dashboards, data tables).
const double kMaxWidthWide = 900;

/// Maximum width for dialogs and bottom sheets on tablets.
/// Prevents them from stretching edge-to-edge on iPad.
const double kMaxWidthDialog = 600;

// ═══════════════════════════════════════════════════════════════════
// SCREEN TYPE DETECTION
// ═══════════════════════════════════════════════════════════════════

/// Screen type categories for adaptive layouts.
enum ScreenType { compact, medium, expanded, large, extraLarge }

/// Categorizes the current screen size using Material Design 3
/// window size classes.
ScreenType getScreenType(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.large) return ScreenType.extraLarge;
  if (width >= Breakpoints.expanded) return ScreenType.large;
  if (width >= Breakpoints.medium) return ScreenType.expanded;
  if (width >= Breakpoints.compact) return ScreenType.medium;
  return ScreenType.compact;
}

// ═══════════════════════════════════════════════════════════════════
// BUILD CONTEXT EXTENSIONS
// ═══════════════════════════════════════════════════════════════════

extension ResponsiveContext on BuildContext {
  /// Current screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Current screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Whether the screen is in landscape orientation.
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Material Design 3: compact screen (< 600dp).
  bool get isCompact => screenWidth < Breakpoints.compact;

  /// Material Design 3: medium screen (600–839dp).
  bool get isMedium =>
      screenWidth >= Breakpoints.compact && screenWidth < Breakpoints.medium;

  /// Material Design 3: expanded screen (840–1199dp).
  bool get isExpanded =>
      screenWidth >= Breakpoints.medium && screenWidth < Breakpoints.expanded;

  /// Material Design 3: large screen (1200–1599dp).
  bool get isLarge =>
      screenWidth >= Breakpoints.expanded && screenWidth < Breakpoints.large;

  /// Material Design 3: extra large screen (1600dp+).
  bool get isExtraLarge => screenWidth >= Breakpoints.large;

  /// Whether the current layout is at least medium (tablet territory).
  bool get isTabletOrLarger => screenWidth >= Breakpoints.compact;

  /// Whether the current layout is at least expanded (large tablet/desktop).
  bool get isExpandedOrLarger => screenWidth >= Breakpoints.medium;

  /// Convenience alias for phone detection.
  bool get isPhone => isCompact;

  /// Convenience alias for tablet detection.
  bool get isTablet => isMedium || isExpanded;

  /// Convenience alias for desktop detection.
  bool get isDesktop => isLarge || isExtraLarge;

  /// Current [ScreenType] based on M3 size classes.
  ScreenType get screenType => getScreenType(this);

  /// Responsive breakpoints data from [ResponsiveFramework].
  ResponsiveBreakpointsData get responsiveBreakpoints =>
      ResponsiveBreakpoints.of(this);
}

// ═══════════════════════════════════════════════════════════════════
// RESPONSIVE VALUE SELECTORS
// ═══════════════════════════════════════════════════════════════════

/// Returns a value based on the current Material Design 3 screen size.
///
/// Example:
/// ```dart
/// final columns = responsiveValue(context,
///   compact: 1,
///   medium: 2,
///   expanded: 3,
/// );
/// ```
T responsiveValue<T>(
  BuildContext context, {
  T? phone,
  T? tablet,
  T? desktop,
  T? compact,
  T? medium,
  T? expanded,
  T? large,
  T? extraLarge,
}) {
  assert(
    compact != null || phone != null,
    'responsiveValue requires either compact or phone.',
  );

  final compactValue = compact ?? phone as T;
  final mediumValue = medium ?? tablet ?? compactValue;
  final expandedValue = expanded ?? desktop ?? mediumValue;
  final largeValue = large ?? desktop ?? expandedValue;
  final extraLargeValue = extraLarge ?? desktop ?? largeValue;
  final type = getScreenType(context);
  switch (type) {
    case ScreenType.extraLarge:
      return extraLargeValue;
    case ScreenType.large:
      return largeValue;
    case ScreenType.expanded:
      return expandedValue;
    case ScreenType.medium:
      return mediumValue;
    case ScreenType.compact:
      return compactValue;
  }
}

// ═══════════════════════════════════════════════════════════════════
// LAYOUT BUILDERS
// ═══════════════════════════════════════════════════════════════════

/// A widget that constrains its child to a maximum width, centering it
/// horizontally. This is the primary pattern for making phone-first
/// layouts look good on tablets without stretching edge-to-edge.
///
/// Used by the Flutter framework itself (see about.dart).
class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    required this.child,
    this.maxWidth = kMaxWidthContent,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Layout builder that swaps widget trees based on M3 screen size.
///
/// Use this when you need completely different layouts per screen size
/// (e.g., master-detail on tablet vs. single pane on phone).
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    this.phone,
    this.tablet,
    this.desktop,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    super.key,
  }) : assert(
         compact != null || phone != null,
         'ResponsiveLayoutBuilder requires either compact or phone.',
       );

  final WidgetBuilder? phone;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;
  final WidgetBuilder? extraLarge;

  @override
  Widget build(BuildContext context) {
    final compactBuilder = compact ?? phone!;
    final mediumBuilder = medium ?? tablet;
    final expandedBuilder = expanded ?? desktop ?? mediumBuilder;
    final largeBuilder = large ?? desktop ?? expandedBuilder;
    final extraLargeBuilder = extraLarge ?? desktop ?? largeBuilder;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= Breakpoints.large && extraLargeBuilder != null) {
          return extraLargeBuilder(context);
        }
        if (width >= Breakpoints.expanded && largeBuilder != null) {
          return largeBuilder(context);
        }
        if (width >= Breakpoints.medium && expandedBuilder != null) {
          return expandedBuilder(context);
        }
        if (width >= Breakpoints.compact && mediumBuilder != null) {
          return mediumBuilder(context);
        }
        return compactBuilder(context);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ADAPTIVE PADDING & SPACING
// ═══════════════════════════════════════════════════════════════════

/// Adaptive horizontal screen padding that increases on larger screens.
///
/// Phone: 20dp | Medium: 28dp | Expanded+: 36dp
EdgeInsets adaptiveScreenPadding(BuildContext context) {
  final padding = responsiveValue<double>(
    context,
    compact: 20,
    medium: 28,
    expanded: 36,
    large: 48,
  );
  return EdgeInsets.symmetric(horizontal: padding);
}

/// Whether the current viewport should promote shell navigation to a rail.
///
/// Width drives the promotion while a minimum height prevents cramped rails
/// on short landscape phones.
bool useNavigationRailLayout(BuildContext context) {
  final viewport = MediaQuery.sizeOf(context);
  return viewport.width >= Breakpoints.medium && viewport.height >= 600;
}

/// Adaptive padding for all edges.
///
/// [base] is the phone value. Multiplied by 1.25 on medium, 1.5 on expanded.
EdgeInsets adaptivePadding(
  BuildContext context, {
  required double base,
}) {
  final multiplier = responsiveValue<double>(
    context,
    compact: 1.0,
    medium: 1.25,
    expanded: 1.5,
    large: 1.75,
  );
  final value = base * multiplier;
  return EdgeInsets.all(value);
}

// ═══════════════════════════════════════════════════════════════════
// GRID HELPERS
// ═══════════════════════════════════════════════════════════════════

/// Returns the recommended number of grid columns for the current screen.
///
/// Phone: 1 | Medium: 2 | Expanded: 3 | Large+: 4
int adaptiveGridColumns(BuildContext context) {
  return responsiveValue<int>(
    context,
    compact: 1,
    medium: 2,
    expanded: 3,
    large: 4,
  );
}

/// Returns a [SliverGridDelegateWithFixedCrossAxisCount] that adapts
/// column count to the screen size.
///
/// Example:
/// ```dart
/// GridView.builder(
///   gridDelegate: adaptiveGridDelegate(context),
///   itemBuilder: ...,
/// )
/// ```
SliverGridDelegateWithFixedCrossAxisCount adaptiveGridDelegate(
  BuildContext context, {
  double childAspectRatio = 1.0,
  double crossAxisSpacing = 12,
  double mainAxisSpacing = 12,
}) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: adaptiveGridColumns(context),
    childAspectRatio: childAspectRatio,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisSpacing: mainAxisSpacing,
  );
}

// ═══════════════════════════════════════════════════════════════════
// DEVICE TYPE DETECTION (async, for analytics / conditional features)
// ═══════════════════════════════════════════════════════════════════

/// Whether the current device is likely a physical tablet.
///
/// This combines screen size with device info (iPad model check on iOS).
/// Falls back to size-only detection if device_info_plus fails.
Future<bool> isTabletDevice(BuildContext context) async {
  final width = MediaQuery.sizeOf(context).width;
  if (width < Breakpoints.compact) return false;

  try {
    final deviceInfo = DeviceInfoPlugin();
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model.toLowerCase().contains('ipad') ||
          width >= Breakpoints.compact;
    }

    if (platform == TargetPlatform.android) {
      await deviceInfo.androidInfo;
      // Most Android tablets report a screen with smallest width >= 600dp.
      return width >= Breakpoints.compact;
    }
  } on Exception {
    // Fallback to size-only detection.
  }

  return width >= Breakpoints.compact;
}
