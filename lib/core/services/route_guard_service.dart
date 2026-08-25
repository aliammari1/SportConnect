import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';

class RouteGuardService {
  const RouteGuardService({
    required this.isLoading,
    required this.user,
    this.isOnboardingLoading = false,
    this.isFirestoreStillLoading = false,
    this.isConnectedAccountLoading = false,
    this.needsRoleSelection = false,
    this.hasCompletedOnboarding = false,
    this.isEmailVerified = false,
    this.hasVerifiableEmail = false,
    this.hasAdminClaim = false,
    this.isAdminClaimLoading = false,
    this.selectedRoleIntent,
    this.currentDriverConnectedAccount,
  });

  factory RouteGuardService.fromAuthState(
    AsyncValue<UserModel?> userState, {
    bool isOnboardingLoading = false,
    bool isFirestoreStillLoading = false,
    bool isConnectedAccountLoading = false,
    bool needsRoleSelection = false,
    bool hasCompletedOnboarding = false,
    bool isEmailVerified = false,
    bool hasVerifiableEmail = false,
    bool hasAdminClaim = false,
    bool isAdminClaimLoading = false,
    UserRole? selectedRoleIntent,
    DriverConnectedAccount? currentDriverConnectedAccount,
  }) {
    return RouteGuardService(
      isLoading: userState.isLoading,
      isOnboardingLoading: isOnboardingLoading,
      isFirestoreStillLoading: isFirestoreStillLoading,
      isConnectedAccountLoading: isConnectedAccountLoading,
      needsRoleSelection: needsRoleSelection,
      hasCompletedOnboarding: hasCompletedOnboarding,
      user: userState.value,
      isEmailVerified: isEmailVerified,
      hasVerifiableEmail: hasVerifiableEmail,
      hasAdminClaim: hasAdminClaim,
      isAdminClaimLoading: isAdminClaimLoading,
      selectedRoleIntent: selectedRoleIntent,
      currentDriverConnectedAccount: currentDriverConnectedAccount,
    );
  }

  final bool isLoading;
  final bool isOnboardingLoading;
  final bool isFirestoreStillLoading;
  final bool needsRoleSelection;
  final bool hasCompletedOnboarding;
  final UserModel? user;
  final bool isEmailVerified;
  final bool hasVerifiableEmail;
  final UserRole? selectedRoleIntent;
  final bool isConnectedAccountLoading;
  final DriverConnectedAccount? currentDriverConnectedAccount;

  /// True when the signed-in user's ID token carries the admin custom claim.
  /// Admins land on the oversight console instead of a role home.
  final bool hasAdminClaim;

  /// True while that claim check is still resolving. Landing decisions hold
  /// (returning null = stay) rather than guessing a role home and then
  /// yanking the user elsewhere a moment later.
  final bool isAdminClaimLoading;

  bool get isLoggedIn => user != null;

  bool get _isPendingUser => user?.role == UserRole.pending;

  String? get _pendingIntentRoute {
    return switch (selectedRoleIntent) {
      UserRole.rider => AppRoutes.riderOnboarding.path,
      UserRole.driver => AppRoutes.driverOnboarding.path,
      _ => null,
    };
  }

  bool get isDriver => user?.role == UserRole.driver;

  DriverModel? get _driver => user is DriverModel ? user! as DriverModel : null;
  bool get hasCompletedDriverVehicleStep {
    final driver = _driver;
    if (driver == null) return true;
    return driver.vehicleIds.isNotEmpty;
  }

  bool get hasCompletedDriverPayoutSetup {
    final driver = _driver;
    if (driver == null) return true;

    final account = currentDriverConnectedAccount;

    return account != null && account.isFullySetup;
  }

  bool get shouldRedirectToSetupPayouts {
    final driver = _driver;
    if (driver == null) return false;

    return hasCompletedDriverVehicleStep && !hasCompletedDriverPayoutSetup;
  }

  bool get hasCompletedDriverOnboarding {
    final driver = _driver;
    if (driver == null) return true;

    return hasCompletedDriverVehicleStep && hasCompletedDriverPayoutSetup;
  }

  bool get _driverHasPersistedProfileData {
    final driver = _driver;
    if (driver == null) return false;
    return (driver.phoneNumber?.isNotEmpty ?? false) ||
        (driver.address?.isNotEmpty ?? false) ||
        (driver.gender?.isNotEmpty ?? false);
  }

  String get _driverOnboardingRedirectPath {
    if (_driverHasPersistedProfileData) {
      return '${AppRoutes.driverOnboarding.path}?skipProfile=true';
    }
    return AppRoutes.driverOnboarding.path;
  }

  String? getRedirect(Uri currentUri) {
    final currentPath = currentUri.path;

    if (isLoading || isOnboardingLoading || isFirestoreStillLoading) {
      return null;
    }

    if (currentPath == AppRoutes.splash.path) {
      return _getInitialRoute();
    }

    if (!isLoggedIn && !hasCompletedOnboarding) {
      final isOnboardingRoute = currentPath == AppRoutes.onboarding.path;
      if (!isOnboardingRoute && !_isLegalRoute(currentPath)) {
        return AppRoutes.onboarding.path;
      }
    }

    // Once onboarding is complete, never strand the user on the intro carousel.
    // Onboarding is also a "public" route, so without this the public-route
    // branch below returns null (stay) for signed-out users who just finished
    // onboarding — leaving them unable to pass the onboarding screen. Route them
    // to their resolved destination (login when signed out).
    if (currentPath == AppRoutes.onboarding.path && hasCompletedOnboarding) {
      return _getInitialRoute();
    }

    if (_isLegalRoute(currentPath)) return null;

    if (isLoggedIn &&
        hasVerifiableEmail &&
        isEmailVerified &&
        currentPath == AppRoutes.emailVerification.path) {
      return _getDashboardRoute();
    }

    if (isLoggedIn &&
        hasVerifiableEmail &&
        !isEmailVerified &&
        isDriver &&
        !hasCompletedDriverVehicleStep &&
        currentPath == AppRoutes.driverOnboarding.path) {
      return null;
    }

    if (isLoggedIn && hasVerifiableEmail && !isEmailVerified) {
      // An unverified user must verify their email before anything else —
      // including picking a role. Send them to the verification screen, and
      // once they're there return null (stay) instead of falling through to
      // the pending-user block below. A brand-new account is still
      // `pending`, so without this short-circuit that block would redirect
      // /email-verification → /role-selection, which immediately redirects
      // back here — tripping GoRouter's redirect-loop detector and dumping
      // the user on an error page right after sign-up.
      if (currentPath != AppRoutes.emailVerification.path) {
        return AppRoutes.emailVerification.path;
      }
      return null;
    }

    if (currentPath == AppRoutes.roleSelection.path && isLoggedIn) {
      if (_isPendingUser) {
        // Once the user has picked a role (intent saved), move them on to that
        // onboarding flow; with no saved intent yet, keep them on role
        // selection (_pendingIntentRoute is null → no redirect).
        return _pendingIntentRoute;
      }
      return _getDashboardRoute();
    }

    if (isLoggedIn && (needsRoleSelection || _isPendingUser)) {
      final pendingIntentRoute = _pendingIntentRoute;

      if (pendingIntentRoute == AppRoutes.riderOnboarding.path &&
          currentPath == AppRoutes.driverOnboarding.path) {
        return AppRoutes.riderOnboarding.path;
      }

      if (pendingIntentRoute == AppRoutes.driverOnboarding.path &&
          currentPath == AppRoutes.riderOnboarding.path) {
        return AppRoutes.driverOnboarding.path;
      }

      const allowedDuringSetup = {
        AppRoutes.roleSelection,
        AppRoutes.driverOnboarding,
        AppRoutes.driverStripeOnboarding,
        AppRoutes.riderOnboarding,
      };

      final isAllowed = allowedDuringSetup.any((r) => r.path == currentPath);
      if (!isAllowed) return AppRoutes.roleSelection.path;
      return null;
    }

    if (_isPublicRoute(currentPath)) {
      if (isLoggedIn) {
        if (currentPath == AppRoutes.login.path) {
          final redirectTarget = _getValidatedRedirectTarget(currentUri);
          if (redirectTarget != null) return redirectTarget;
        }
        return _getDashboardRoute();
      }
      return null;
    }

    if (!isLoggedIn) {
      final encodedTarget = Uri.encodeComponent(currentUri.toString());
      return '${AppRoutes.login.path}?redirect=$encodedTarget';
    }

    if (_isDriverRoute(currentPath) && !isDriver) {
      return AppRoutes.home.path;
    }

    if (_isRiderOnlyRoute(currentPath) && isDriver) {
      return AppRoutes.driverHome.path;
    }

    if (isDriver) {
      if (!hasCompletedDriverVehicleStep &&
          !_isDriverOnboardingRoute(currentPath)) {
        return _driverOnboardingRedirectPath;
      }

      if (hasCompletedDriverVehicleStep && isConnectedAccountLoading) {
        return null;
      }

      if (shouldRedirectToSetupPayouts &&
          currentPath != AppRoutes.driverStripeOnboarding.path &&
          !_isAccountEscapeRoute(currentPath)) {
        return AppRoutes.driverStripeOnboarding.path;
      }

      if (hasCompletedDriverPayoutSetup &&
          currentPath == AppRoutes.driverStripeOnboarding.path) {
        return AppRoutes.driverHome.path;
      }
    }

    return null;
  }

  String? _getInitialRoute() {
    if (!isLoggedIn) {
      return hasCompletedOnboarding
          ? AppRoutes.login.path
          : AppRoutes.onboarding.path;
    }
    if (hasVerifiableEmail && !isEmailVerified) {
      return AppRoutes.emailVerification.path;
    }
    return _getDashboardRoute();
  }

  String? _getDashboardRoute() {
    if (!isLoggedIn) return AppRoutes.login.path;

    // Hold landing decisions until the admin claim is known, so a fresh
    // grant redirects on the very next launch instead of after one stray
    // bounce through the role home.
    if (isAdminClaimLoading) return null;

    if (hasAdminClaim) return AppRoutes.adminDashboard.path;

    return user!.map(
      rider: (_) => AppRoutes.home.path,
      driver: (driver) {
        if (!hasCompletedDriverVehicleStep) {
          return _driverOnboardingRedirectPath;
        }

        // While the connected-account provider is still loading we do NOT yet
        // know whether payout setup is complete. Sending the driver to the
        // Stripe onboarding screen here makes an already-set-up driver flash
        // that screen before being bounced back to driverHome. Send them to
        // their dashboard instead; getRedirect() will move them to Stripe
        // onboarding once the account has loaded and we know setup is missing.
        if (isConnectedAccountLoading) {
          return AppRoutes.driverHome.path;
        }

        if (!hasCompletedDriverPayoutSetup) {
          return AppRoutes.driverStripeOnboarding.path;
        }

        return AppRoutes.driverHome.path;
      },
      pending: (_) => _pendingIntentRoute ?? AppRoutes.roleSelection.path,
    );
  }

  bool _isLegalRoute(String path) {
    return path == AppRoutes.terms.path ||
        path == AppRoutes.privacy.path ||
        path.startsWith('/legal');
  }

  bool _isPublicRoute(String path) {
    return path == AppRoutes.onboarding.path ||
        path == AppRoutes.login.path ||
        path == AppRoutes.signupWizard.path ||
        path == AppRoutes.forgotPassword.path;
  }

  bool _isDriverRoute(String path) => path.startsWith('/driver');

  bool _isRiderOnlyRoute(String path) {
    return path == AppRoutes.home.path ||
        path == AppRoutes.riderMyRides.path ||
        path == AppRoutes.riderOnboarding.path;
  }

  bool _isDriverOnboardingRoute(String path) {
    return path == AppRoutes.driverOnboarding.path ||
        path == AppRoutes.driverStripeOnboarding.path;
  }

  /// Routes a driver stuck in incomplete Stripe payout setup must still be
  /// able to reach — signing out, contacting support, or deleting their
  /// account — so an indefinitely-stuck onboarding state (unsupported
  /// country, missing documents, a permanently "additional information
  /// needed" account, etc.) never fully locks them out of the app. This does
  /// NOT weaken the payout requirement itself: ride-posting, earnings, and
  /// every other screen are still gated behind `shouldRedirectToSetupPayouts`.
  bool _isAccountEscapeRoute(String path) {
    return path == AppRoutes.settings.path ||
        path == AppRoutes.helpCenter.path ||
        path == AppRoutes.contactSupport.path ||
        path == AppRoutes.reportIssue.path;
  }

  String? _getValidatedRedirectTarget(Uri currentUri) {
    final raw = currentUri.queryParameters['redirect'];
    if (raw == null || raw.isEmpty) return null;

    final decoded = Uri.decodeComponent(raw);
    if (!decoded.startsWith('/')) return null;
    if (decoded.startsWith('//')) return null;

    const blockedTargets = {
      '/splash',
      '/login',
      '/onboarding',
      '/email-verification',
    };
    final decodedPath = Uri.tryParse(decoded)?.path ?? decoded;
    if (blockedTargets.contains(decodedPath)) return null;

    return decoded;
  }
}
