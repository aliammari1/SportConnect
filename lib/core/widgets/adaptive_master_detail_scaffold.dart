import 'package:flutter/material.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

class AdaptiveMasterDetailScaffold extends StatelessWidget {
  const AdaptiveMasterDetailScaffold({
    required this.master,
    required this.detail,
    required this.phone,
    super.key,
    this.masterFlex = 5,
    this.detailFlex = 7,
    // Two-pane needs real room: with the ~1.5× tablet scale, two side-by-side
    // panes only fit from ~landscape-iPad width up. Below this (e.g. iPad
    // PORTRAIT at 1032pt) we render a single full-width column and push the
    // detail as a page. Screens MUST gate their tap handlers on the same
    // [kTwoPaneMinWidth] or taps will set a detail that has no pane to show.
    this.minTwoPaneWidth = kTwoPaneMinWidth,
  });

  final Widget master;
  final Widget detail;
  final Widget phone;
  final int masterFlex;
  final int detailFlex;
  final double minTwoPaneWidth;

  @override
  Widget build(BuildContext context) {
    if (context.screenWidth < minTwoPaneWidth) return phone;

    // Each pane is wrapped in a transparent Material so that Material widgets
    // inside them (TextField/PremiumSearchField, InkWell, etc.) find a Material
    // ancestor. The phone path returns a full Scaffold, but the two-pane Row
    // has none — without this, the search fields in the master pane throw
    // "No Material widget found" on tablets.
    return Row(
      children: [
        Expanded(
          flex: masterFlex,
          child: Material(type: MaterialType.transparency, child: master),
        ),
        VerticalDivider(width: 1, color: AppColors.divider),
        Expanded(
          flex: detailFlex,
          child: Material(type: MaterialType.transparency, child: detail),
        ),
      ],
    );
  }
}

class TabletEmptyDetail extends StatelessWidget {
  const TabletEmptyDetail({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
