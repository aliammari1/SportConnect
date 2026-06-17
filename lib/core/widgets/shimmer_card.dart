import 'package:flutter/material.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';

/// A rounded, sized loading placeholder card.
///
/// Wraps the shared [ShimmerLoading] primitive so that loading placeholders
/// across the app share a single implementation instead of each screen
/// re-implementing a `Skeletonizer`/`SkeletonLoader` wrapped container.
///
/// By default the card fills the available width and only the [height] needs
/// to be provided, matching the common "skeleton stat/ride card" use case.
///
/// Example:
/// ```dart
/// loading: () => const ShimmerCard(height: 108),
/// ```
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height,
    this.width = double.infinity,
    this.radius = 16,
  });

  /// Card height (logical pixels, scaled via ScreenUtil inside [ShimmerLoading]).
  final double? height;

  /// Card width. Defaults to [double.infinity] so the card fills its parent.
  final double width;

  /// Corner radius for the rounded placeholder.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      width: width,
      height: height ?? 90,
      borderRadius: radius,
    );
  }
}
