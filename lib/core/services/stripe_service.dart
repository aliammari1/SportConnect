import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/core/config/stripe_config.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'stripe_service.g.dart';

// Must match the Stripe SDK API version bundled in flutter_stripe / stripe-android 23.x
const _kStripeApiVersion = '2026-04-22.dahlia';

/// Riverpod provider for StripeService singleton
@Riverpod(keepAlive: true)
StripeService stripeService(Ref ref) => StripeService();

/// Stripe Service for payment processing and Connect functionality
///
/// Architecture:
/// - Uses Firebase Cloud Functions for server-side Stripe operations
/// - Uses Firebase Firestore for data storage
/// - All sensitive operations handled server-side for security
class StripeService {
  factory StripeService() => _instance;

  StripeService._internal() : _functions = FirebaseFunctions.instance;

  static final StripeService _instance = StripeService._internal();

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> getAccountStatus({
    required String accountId,
  }) async {
    final result = await _functions
        .httpsCallable('getAccountStatus')
        .call<Map<String, dynamic>>(<String, dynamic>{
          'accountId': accountId,
        });

    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> syncDriverBalance() async {
    await _functions
        .httpsCallable('syncDriverBalance')
        .call<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getDriverPayoutEligibility({
    required String stripeAccountId,
    required String currency,
  }) async {
    return _callFunction('getDriverPayoutEligibility', {
      'stripeAccountId': stripeAccountId,
      'currency': currency.toLowerCase(),
    });
  }

  /// Initialize Stripe with publishable key
  Future<void> initialize({required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = StripeConfig.urlScheme;
    await Stripe.instance.applySettings();

    // Connect to emulator if in development mode
    if (AppConfig.useEmulators) {
      _functions.useFunctionsEmulator(
        AppConfig.emulatorHost,
        AppConfig.functionsEmulatorPort,
      );
      TalkerService.info(
        'Stripe service using Functions emulator at ${AppConfig.emulatorHost}:${AppConfig.functionsEmulatorPort}',
      );
    }

    TalkerService.info(
      'Stripe initialized with key: ${publishableKey.substring(0, 20)}...',
    );
  }

  /// Call Firebase Cloud Function
  Future<Map<String, dynamic>> _callFunction(
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call<Map<String, dynamic>>(data);
      // On Android/iOS the cloud_functions plugin decodes NESTED objects as
      // Map<Object?, Object?> even when the top level is Map<String, dynamic>
      // (flutterfire #6546/#11872/#13038/#13136). Recursively normalize so
      // callers doing `as Map<String, dynamic>` / JsonSerializable fromJson on
      // nested objects don't throw a type-subtype error.
      final converted = _deepConvert(result.data);
      return converted is Map<String, dynamic>
          ? converted
          : Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      TalkerService.error('Firebase Functions error: ${e.code} - ${e.message}');
      throw StripePaymentException(
        e.message ?? 'Function call failed',
        code: e.code,
      );
    } catch (e) {
      TalkerService.error('Error calling function $name: $e');
      throw StripePaymentException('Failed to call function: $e');
    }
  }

  /// Recursively converts a value decoded by the cloud_functions plugin into
  /// strongly typed Dart collections. Nested maps are coerced to
  /// `Map<String, dynamic>` and lists are walked element-by-element so that
  /// downstream `as Map<String, dynamic>` casts and JsonSerializable fromJson
  /// calls succeed on mobile (see flutterfire #6546/#11872/#13038/#13136).
  static Object? _deepConvert(Object? value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (key, val) => MapEntry(key.toString(), _deepConvert(val)),
      );
    }
    if (value is List) {
      return value.map<dynamic>(_deepConvert).toList();
    }
    return value;
  }

  /// Create Payment Intent for ride booking
  /// Uses Firebase Cloud Functions for secure server-side processing
  ///
  /// [driverStripeAccountId] - Driver's Stripe Connect account ID (from Firestore)
  /// If null, payment goes to platform (driver can be paid manually later)
  Future<Map<String, dynamic>> createPaymentIntent({
    required String rideId,
    required String riderId,
    required String riderName,
    required String driverId,
    required String driverName,
    required int amountInCents,
    required String currency,
    String? customerId,
    String? existingCustomerId,
    String? driverStripeAccountId,
    String? description,
  }) async {
    try {
      final response = await _callFunction('createPaymentIntent', {
        'rideId': rideId,
        'riderId': riderId,
        'riderName': riderName,
        'driverId': driverId,
        'driverName': driverName,
        'amountInCents': amountInCents,
        'currency': currency.toLowerCase(),
        'customerId': customerId ?? existingCustomerId,
        'driverStripeAccountId': driverStripeAccountId,
        'description': description,
        'stripeApiVersion': _kStripeApiVersion,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating payment intent: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create payment: $e');
    }
  }

  /// Process payment using Payment Sheet (Recommended for mobile)
  ///
  /// Uses Stripe's conversion-optimized Payment Sheet UI which supports
  /// saved cards, Apple Pay, Google Pay, and localized payment methods.
  ///
  /// [currency] - ISO 4217 currency code for Google Pay
  Future<bool> processPaymentWithSheet({
    required String paymentIntentClientSecret,
    required String customerId,
    String? ephemeralKeySecret,
    String currency = 'eur',
    String merchantCountryCode = 'FR',
  }) async {
    // P-5: Guard against empty/null clientSecret before touching the Stripe SDK,
    // which would throw a cryptic internal exception.
    if (paymentIntentClientSecret.isEmpty) {
      throw ArgumentError(
        'paymentIntentClientSecret must not be empty. '
        'The payment intent may have failed to create.',
      );
    }

    try {
      final currencyUpper = currency.toUpperCase();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'SportConnect',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKeySecret,
          // Force light mode regardless of device system setting
          style: ThemeMode.light,
          // applePay: PaymentSheetApplePay(
          //   merchantCountryCode: merchantCountryCode,
          //   buttonType: PlatformButtonType.book,
          // ),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: merchantCountryCode,
            currencyCode: currencyUpper,
            testEnv: kDebugMode,
            buttonType: PlatformButtonType.book,
          ),
          returnURL: '${StripeConfig.urlScheme}://redirect',
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
                name: CollectionMode.automatic,
                email: CollectionMode.never,
                phone: CollectionMode.never,
                address: AddressCollectionMode.never,
              ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              // Brand primary — SportConnect emerald
              primary: Color(0xFF40916C),
              // Pure white sheet surface
              background: Color(0xFFFFFFFF),
              // Slightly off-white input fields
              componentBackground: Color(0xFFF8FAF9),
              // Subtle sage border
              componentBorder: Color(0xFFD8E0DB),
              // Dividers between rows
              componentDivider: Color(0xFFE8EDE9),
              // Input text — dark forest
              componentText: Color(0xFF1B2E24),
              // Headings / labels
              primaryText: Color(0xFF1B2E24),
              // Subtitles / helper text
              secondaryText: Color(0xFF5C7266),
              // Empty-state placeholders
              placeholderText: Color(0xFF8FA399),
              // Icons (card brand, lock, etc.)
              icon: Color(0xFF40916C),
              // Validation errors
              error: Color(0xFFC1666B),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 14,
              borderWidth: 1,
              shadow: PaymentSheetShadowParams(opacity: 0.06),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(
                blurRadius: 0,
                borderWidth: 0,
                shadow: PaymentSheetShadowParams(opacity: 0.18),
              ),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF40916C),
                  text: Color(0xFFFFFFFF),
                  border: Color(0xFF40916C),
                  successBackgroundColor: Color(0xFF2D6A4F),
                  successTextColor: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      );

      // Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      TalkerService.info('Payment successful');
      return true;
    } on StripeException catch (e) {
      final msg = e.error.localizedMessage ?? '';
      // User deliberately dismissed the sheet — not an error
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      TalkerService.error('Stripe error: $msg');
      throw StripePaymentException(msg.isNotEmpty ? msg : 'Payment failed');
    } on Exception catch (e) {
      TalkerService.error('Payment error: $e');
      throw StripePaymentException('Payment processing failed');
    }
  }

  /// Create or retrieve Stripe customer
  /// Uses Firebase Cloud Functions
  ///
  /// [existingCustomerId] - If user already has a customer ID in Firestore, pass it here
  Future<Map<String, dynamic>> getOrCreateCustomer({
    required String userId,
    required String email,
    String? name,
    String? phone,
    String? existingCustomerId,
  }) async {
    try {
      final response = await _callFunction('getOrCreateCustomer', {
        'email': email,
        'name': name,
        'phone': phone,
        'existingCustomerId': existingCustomerId,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating/getting customer: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create customer: $e');
    }
  }

  /// Create Connected Account for driver (Stripe Connect).
  /// Server uses France-only Express onboarding; Stripe collects KYC fields.
  Future<Map<String, dynamic>> createDriverConnectedAccount({
    required String userId,
    required String email,
  }) async {
    try {
      final response = await _callFunction('createConnectedAccount', {
        'userId': userId,
        'email': email,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating connected account: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create account: $e');
    }
  }

  /// Create Account Onboarding Link.
  /// Server reads accountId from Firestore and uses hardcoded return URLs.
  Future<Map<String, dynamic>> createAccountLink() async {
    try {
      final response = await _callFunction('createAccountLink', {});

      return response;
    } catch (e) {
      TalkerService.error('Error creating account link: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Failed to create account link: $e');
    }
  }

  /// Create instant payout to driver's debit card
  /// Uses Firebase Cloud Functions
  ///
  /// [stripeAccountId] - Driver's Stripe Connect account ID (from Firestore)
  /// [amountInCents] - Amount in cents (e.g., 100 = 1.00 EUR)
  Future<Map<String, dynamic>> createInstantPayout({
    required String stripeAccountId,
    required int amountInCents,
    required String currency,
  }) async {
    try {
      final response = await _callFunction('createInstantPayout', {
        'stripeAccountId': stripeAccountId,
        'amountInCents': amountInCents,
        'currency': currency.toLowerCase(),
      });

      return response;
    } catch (e) {
      TalkerService.error('Error creating instant payout: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Payout failed: $e');
    }
  }

  Future<Map<String, dynamic>> cancelInstantPayout({
    required String payoutDocId,
    required String stripePayoutId,
  }) async {
    try {
      final response = await _callFunction('cancelInstantPayout', {
        'payoutDocId': payoutDocId,
        'stripePayoutId': stripePayoutId,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error cancelling instant payout: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Payout cancellation failed: $e');
    }
  }

  /// Refund payment (for cancellations)
  /// Uses Firebase Cloud Functions
  Future<Map<String, dynamic>> refundPayment({
    required String paymentIntentId,
    int? amountInCents, // If null, full refund
    String? reason,
  }) async {
    try {
      final response = await _callFunction('refundPayment', {
        'paymentIntentId': paymentIntentId,
        'amountInCents': amountInCents,
        'reason': reason ?? 'requested_by_customer',
      });

      return response;
    } catch (e) {
      TalkerService.error('Error processing refund: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Refund failed: $e');
    }
  }

  /// Request an automatic ride-payment refund.
  ///
  /// The Cloud Function validates the rider and applies the server refund
  /// policy before creating a Stripe refund.
  Future<Map<String, dynamic>> requestRefund({
    required String paymentId,
    required String reason,
    String? details,
  }) async {
    try {
      final response = await _callFunction('requestRefund', {
        'paymentId': paymentId,
        'reason': reason,
        'details': details,
      });

      return response;
    } catch (e) {
      TalkerService.error('Error requesting refund review: $e');
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Refund request failed: $e');
    }
  }

  /// Calculate platform fees (client-side preview)
  Map<String, double> calculateFees({
    required double totalAmount,
    double platformFeePercent = 15.0,
    double stripeFeePercent = 2.9,
    double stripeFixedFee = 0.30,
  }) {
    final platformFee = totalAmount * (platformFeePercent / 100);
    final stripeFee = (totalAmount * (stripeFeePercent / 100)) + stripeFixedFee;
    final driverEarnings = totalAmount - platformFee - stripeFee;

    return {
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'stripeFee': stripeFee,
      'driverEarnings': driverEarnings,
    };
  }

  /// Check if service is properly initialized
  bool get isInitialized => Stripe.publishableKey.isNotEmpty;

  // ── Customer Sheet (beta) ─────────────────────────────────

  /// Fetch SetupIntent + EphemeralKey from Cloud Function
  Future<Map<String, dynamic>> _createCustomerSheetSetup() async {
    return _callFunction('createCustomerSheetSetup', {
      'stripeApiVersion': _kStripeApiVersion,
    });
  }

  /// Initialize and present the Customer Sheet for managing saved payment methods.
  ///
  /// Returns the selected payment option (brand + last4), or null if dismissed.
  Future<CustomerSheetResult?> presentCustomerSheet() async {
    final setup = await _createCustomerSheetSetup();
    final setupIntentClientSecret = setup['setupIntentClientSecret'] as String;
    final customerId = setup['customerId'] as String;
    final ephemeralKeySecret = setup['ephemeralKeySecret'] as String;

    await Stripe.instance.initCustomerSheet(
      customerSheetInitParams: CustomerSheetInitParams.adapter(
        setupIntentClientSecret: setupIntentClientSecret,
        merchantDisplayName: 'SportConnect',
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKeySecret,
        returnURL: '${StripeConfig.urlScheme}://redirect',
        // Force light mode regardless of device system setting
        style: ThemeMode.light,
        billingDetailsCollectionConfiguration:
            const BillingDetailsCollectionConfiguration(
              name: CollectionMode.automatic,
              email: CollectionMode.never,
              phone: CollectionMode.never,
              address: AddressCollectionMode.never,
            ),
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF40916C),
            background: Color(0xFFFFFFFF),
            componentBackground: Color(0xFFF8FAF9),
            componentBorder: Color(0xFFD8E0DB),
            componentDivider: Color(0xFFE8EDE9),
            componentText: Color(0xFF1B2E24),
            primaryText: Color(0xFF1B2E24),
            secondaryText: Color(0xFF5C7266),
            placeholderText: Color(0xFF8FA399),
            icon: Color(0xFF40916C),
            error: Color(0xFFC1666B),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 14,
            borderWidth: 1,
            shadow: PaymentSheetShadowParams(opacity: 0.06),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(
              blurRadius: 0,
              borderWidth: 0,
              shadow: PaymentSheetShadowParams(opacity: 0.18),
            ),
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFF40916C),
                text: Color(0xFFFFFFFF),
                border: Color(0xFF40916C),
                successBackgroundColor: Color(0xFF2D6A4F),
                successTextColor: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );

    final result = await Stripe.instance.presentCustomerSheet();
    return result;
  }
}

/// Custom exception for Stripe payment errors
class StripePaymentException implements Exception {
  StripePaymentException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}
