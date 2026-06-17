import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/features/payments/views/premium_checkout_screen.dart';
import 'package:sport_connect/features/payments/views/premium_subscribe_screen.dart';

/// Premium module routes
class PremiumRoutes {
  List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: AppRoutes.premiumSubscribe.path,
        name: AppRoutes.premiumSubscribe.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const PremiumSubscribeScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const PremiumSubscribeScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.premiumCheckout.path,
        name: AppRoutes.premiumCheckout.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const PremiumCheckoutScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const PremiumCheckoutScreen(),
              ),
      ),
    ];
  }
}
