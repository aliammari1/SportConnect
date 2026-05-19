import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';

/// The `/premium/checkout` route now forwards directly to the unified paywall.
/// Kept as a named route so deep-links and existing `pushNamed` calls still work.
class PremiumCheckoutScreen extends StatelessWidget {
  const PremiumCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect happens on the first frame so the route is never visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.replace(AppRoutes.premiumSubscribe.path);
      }
    });
    return const SizedBox.shrink();
  }
}
