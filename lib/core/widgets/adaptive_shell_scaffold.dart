import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class AdaptiveShellDestination {
  const AdaptiveShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class AdaptiveShellScaffold extends StatelessWidget {
  const AdaptiveShellScaffold({
    required this.activeIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
    super.key,
  });

  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveShellDestination> destinations;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final useRail = useNavigationRailLayout(context);
    final useExtendedRail = context.screenWidth >= Breakpoints.medium;
    final l10n = AppLocalizations.of(context);

    if (!useRail) {
      return AdaptiveScaffold(
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          selectedIndex: activeIndex,
          onTap: onDestinationSelected,
          selectedItemColor: AppColors.primaryLight,
          items: [
            for (final destination in destinations)
              AdaptiveNavigationDestination(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: destination.label,
              ),
          ],
        ),
      );
    }

    return AdaptiveScaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: activeIndex,
              onDestinationSelected: onDestinationSelected,
              extended: useExtendedRail,
              minExtendedWidth: 220,
              labelType: useExtendedRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              backgroundColor: AppColors.surface,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primaryLight,
              ),
              unselectedIconTheme: IconThemeData(
                color: AppColors.textSecondary,
              ),
              selectedLabelTextStyle: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
              unselectedLabelTextStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primaryLight,
                      size: 28,
                    ),
                    if (useExtendedRail) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
