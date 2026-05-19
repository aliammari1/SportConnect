import 'package:flutter/foundation.dart';

/// Environment mode for Firebase services.
enum EnvironmentMode {
  /// Use Firebase emulators for local development.
  emulator,

  /// Use production Firebase services.
  production,
}

/// App Configuration - Firebase + IAP.
class AppConfig {
  AppConfig._();

  /// Current environment mode.
  ///
  /// Debug builds use Firebase emulators.
  /// Release/Profile builds use production Firebase services.
  static const EnvironmentMode environmentMode = kDebugMode
      ? EnvironmentMode.emulator
      : EnvironmentMode.production;

  /// Check if we're using Firebase emulators.
  static bool get useEmulators => environmentMode == EnvironmentMode.emulator;

  /// Optional override for Firebase emulator host.
  ///
  /// Examples:
  ///
  /// Android emulator:
  /// --dart-define=FIREBASE_USE_ANDROID_EMULATOR_HOST=true
  ///
  /// Physical Android/iOS device over Wi-Fi:
  /// --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.23
  ///
  /// Web/local desktop:
  /// --dart-define=FIREBASE_EMULATOR_HOST=localhost
  static const String emulatorHostOverride = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: '10.241.53.105',
  );

  /// Enable Android emulator loopback host.
  ///
  /// Android emulator uses 10.0.2.2 to access the host machine.
  static const bool useAndroidEmulatorHost = bool.fromEnvironment(
    'FIREBASE_USE_ANDROID_EMULATOR_HOST',
  );

  /// Default local-network host for physical devices.
  ///
  /// Replace this with your computer LAN IP when testing on a real phone,
  /// or override it from the command line:
  ///
  /// --dart-define=FIREBASE_EMULATOR_HOST=192.168.1.23
  static const String defaultPhysicalDeviceEmulatorHost =
      String.fromEnvironment(
        'FIREBASE_DEFAULT_PHYSICAL_DEVICE_EMULATOR_HOST',
      );

  /// Firebase emulator host resolution.
  ///
  /// Priority:
  /// 1. Explicit FIREBASE_EMULATOR_HOST.
  /// 2. Web: localhost.
  /// 3. Android emulator: 10.0.2.2 when enabled.
  /// 4. Physical/mobile fallback: LAN IP.
  static String get emulatorHost {
    final overrideHost = emulatorHostOverride.trim();

    if (overrideHost.isNotEmpty) {
      return overrideHost;
    }

    if (kIsWeb) {
      return 'localhost';
    }

    if (defaultTargetPlatform == TargetPlatform.android &&
        useAndroidEmulatorHost) {
      return '10.0.2.2';
    }

    return defaultPhysicalDeviceEmulatorHost;
  }

  /// Firebase emulator ports.
  ///
  /// These must match your firebase.json.
  static const int authEmulatorPort = int.fromEnvironment(
    'FIREBASE_AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );

  static const int firestoreEmulatorPort = int.fromEnvironment(
    'FIREBASE_FIRESTORE_EMULATOR_PORT',
    defaultValue: 8080,
  );

  static const int storageEmulatorPort = int.fromEnvironment(
    'FIREBASE_STORAGE_EMULATOR_PORT',
    defaultValue: 9199,
  );

  static const int functionsEmulatorPort = int.fromEnvironment(
    'FIREBASE_FUNCTIONS_EMULATOR_PORT',
    defaultValue: 5001,
  );

  static const int databaseEmulatorPort = int.fromEnvironment(
    'FIREBASE_DATABASE_EMULATOR_PORT',
    defaultValue: 9000,
  );

  /// App-level settings.
  static const String appName = 'SportConnect';
  static const String appVersion = '1.1.20';

  static const String supportTicketEmail = String.fromEnvironment(
    'SPORTCONNECT_SUPPORT_EMAIL',
    defaultValue: 'support@sportconnect.app',
  );

  /// API settings.
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);

  /// Map settings.
  static const double defaultMapZoom = 13;
  static const double minMapZoom = 3;
  static const double maxMapZoom = 18;

  /// Pagination.
  static const int pageSize = 20;
  static const int maxSearchRadius = 50; // km

  /// Feature flags.
  static bool get isPremiumEnabled => true;
  static bool get isChatEnabled => true;
  static bool get isGamificationEnabled => true;

  /// Main in-app purchase subscription product ID.
  ///
  /// Latest Google Play subscription model:
  ///
  /// Product:
  /// - sportconnect_premium
  ///
  /// Base plans:
  /// - monthly
  /// - yearly
  ///
  /// Important:
  /// Query this product ID in Flutter.
  /// Do not query the base plan IDs as product IDs.
  static const String premiumSubscriptionProductId = String.fromEnvironment(
    'SPORTCONNECT_IAP_PREMIUM_ID',
    defaultValue: 'sportconnect_premium',
  );

  /// Google Play monthly base plan ID.
  ///
  /// This is selected from the Android product details after querying
  /// [premiumSubscriptionProductId].
  static const String premiumMonthlyBasePlanId = String.fromEnvironment(
    'SPORTCONNECT_IAP_PREMIUM_MONTHLY_BASE_PLAN_ID',
    defaultValue: 'monthly',
  );

  /// Google Play yearly base plan ID.
  ///
  /// This is selected from the Android product details after querying
  /// [premiumSubscriptionProductId].
  static const String premiumYearlyBasePlanId = String.fromEnvironment(
    'SPORTCONNECT_IAP_PREMIUM_YEARLY_BASE_PLAN_ID',
    defaultValue: 'yearly',
  );

  /// Optional Apple App Store subscription product IDs.
  ///
  /// App Store Connect does not use Google Play base plans. If you want one
  /// cross-platform product model, keep these equal to the Google product ID
  /// only if your App Store product IDs are actually the same.
  ///
  /// Many teams prefer separate App Store product IDs:
  /// - sportconnect_premium_monthly
  /// - sportconnect_premium_yearly
  static const String iosPremiumMonthlyProductId = String.fromEnvironment(
    'SPORTCONNECT_IOS_IAP_PREMIUM_MONTHLY_ID',
    defaultValue: 'sportconnect_premium_monthly',
  );

  static const String iosPremiumYearlyProductId = String.fromEnvironment(
    'SPORTCONNECT_IOS_IAP_PREMIUM_YEARLY_ID',
    defaultValue: 'sportconnect_premium_yearly',
  );

  /// Get environment status string for logging.
  static String get environmentStatus {
    if (useEmulators) {
      return 'EMULATOR MODE - Host: $emulatorHost';
    }

    return 'PRODUCTION MODE';
  }
}
