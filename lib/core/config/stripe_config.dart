import 'package:sport_connect/core/config/environment.dart';

/// Stripe Configuration for SportConnect
///
/// This configuration uses:
/// - Firebase Cloud Functions for serverless payment processing
/// - Firebase Firestore for data storage
/// - Stripe for payment processing
///
/// All values can be overridden via --dart-define at build time
class StripeConfig {
  StripeConfig._();

  /// Stripe Publishable Key
  /// This is safe to include in client code (it's meant to be public)
  ///
  /// Override with: --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
  static const String publishableKey = Environment.stripePublishableKey;

  /// Platform fee percentage (taken from each payment)
  /// Default: 15%
  static const double platformFeePercent = 15;

  /// Stripe processing fee percentage
  static const double stripeFeePercent = 2.9;

  /// Stripe fixed fee in euro cents
  static const double stripeFixedFee = 30;

  /// Default currency for payments
  static const String defaultCurrency = 'eur';

  /// Custom return URL scheme registered in ios/Runner/Info.plist.
  static const String urlScheme = 'flutterstripe';

  /// Whether we're in test mode
  static bool get isTestMode => publishableKey.startsWith('pk_test_');

  /// Validate that all required configuration is present
  static bool get isConfigured {
    return publishableKey != 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
  }

  /// Get a human-readable configuration status
  static String get configurationStatus {
    if (isConfigured) {
      return 'Stripe configured (${isTestMode ? "TEST" : "LIVE"} mode)';
    }
    return 'Stripe NOT configured - update StripeConfig values';
  }
}
