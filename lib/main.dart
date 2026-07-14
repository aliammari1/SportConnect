import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:riverpod_devtools_tracker/riverpod_devtools_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Config & Services
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/core/config/stripe_config.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/cupertino_app_theme.dart';
import 'package:sport_connect/core/theme/material_app_theme.dart';
import 'package:sport_connect/features/profile/view_models/settings_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:upgrader/upgrader.dart';

/// Top-level FCM handler for data-only push messages when the app is
/// terminated or backgrounded.  Must be a top-level function annotated with
/// @pragma('vm:entry-point') so the AOT compiler does not tree-shake it.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized before any Firebase call.
  await Firebase.initializeApp();
  TalkerService.info('FCM background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only fast, local work before runApp so the native launch screen dismisses
  // immediately. Network-dependent work (App Check, Crashlytics collection
  // toggle) is deferred to _initializeAppAfterFirstFrame.
  //
  // Wrapped in try-catch with a timeout: if Firebase.initializeApp() hangs
  // (seen on some iPadOS versions), we still call runApp() so the Flutter
  // splash renders and its 10-second timeout safely redirects the user.
  // Start Firebase and SharedPreferences in parallel — they're independent.
  FirebaseService? firebase;
  final firebaseFuture = FirebaseService.instance.initializeCore().timeout(
    const Duration(seconds: 8),
  );
  final prefsFuture = SharedPreferences.getInstance();

  try {
    firebase = await firebaseFuture;
    TalkerService.info('✅ Firebase core initialized');
  } on TimeoutException {
    TalkerService.error(
      '❌ Firebase initialization timed out — continuing without Firebase',
    );
  } on Exception catch (e, st) {
    TalkerService.error(
      '❌ Firebase initialization failed — continuing without Firebase',
      e,
      st,
    );
  }

  if (firebase != null) {
    FlutterError.onError = (details) {
      unawaited(firebase!.crashlytics.recordFlutterFatalError(details));
      TalkerService.error(
        'FlutterError: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(firebase!.crashlytics.recordError(error, stack, fatal: true));
      TalkerService.error('PlatformDispatcher error', error, stack);
      return true;
    };
  }

  final prefs = await prefsFuture;

  _runApp(prefs);
}

/// Runs non-critical startup work after the first frame.
///
/// This prevents App Review/users from getting stuck on the native launch
/// screen if push notifications, Stripe, App Check, or other
/// network-related startup work is slow.
///
/// [analyticsCollectionEnabled] is the user's persisted analytics/crash
/// reporting consent choice, read from [SettingsRepository] before this is
/// called, so Crashlytics/Analytics never gets force-enabled against the
/// user's Settings choice.
Future<void> _initializeAppAfterFirstFrame({
  required bool analyticsCollectionEnabled,
}) async {
  TalkerService.info('🚀 Starting post-launch initialization...');

  // Run non-critical startup tasks in parallel so the app becomes fully
  // interactive sooner on slow networks/devices.
  await Future.wait<void>([
    // App Check activation makes a network call on production iOS
    // (DeviceCheck). Running it here keeps the native splash short.
    FirebaseService.instance.activateAppCheck(
      analyticsCollectionEnabled: analyticsCollectionEnabled,
    ),
    _initializePushNotifications(),
    _initializeStripe(),
  ]);

  TalkerService.info('✅ Post-launch initialization completed');
}

Future<void> _initializePushNotifications() async {
  if (kIsWeb) return;

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await PushNotificationService.instance.initialize().timeout(
      const Duration(seconds: 6),
    );

    TalkerService.info('✅ Push notifications initialized');
  } on Exception catch (e, st) {
    TalkerService.error('❌ Failed to initialize push notifications', e, st);
  }
}

Future<void> _initializeStripe() async {
  try {
    if (!StripeConfig.isConfigured) {
      TalkerService.warning('⚠️ Stripe not configured - payments disabled.');
      return;
    }

    await StripeService()
        .initialize(
          publishableKey: StripeConfig.publishableKey,
        )
        .timeout(const Duration(seconds: 6));

    TalkerService.info('✅ Stripe initialized');
  } on Exception catch (e, st) {
    TalkerService.error('❌ Failed to initialize Stripe', e, st);
  }
}

void _runApp(SharedPreferences prefs) {
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      observers: [
        if (kDebugMode) ...[
          TalkerService.riverpodObserver,
          RiverpodDevToolsObserver(
            config: TrackerConfig.forPackage('com.sportconnect.app'),
          ),
        ],
      ],
      child: const SportConnectApp(),
    ),
  );
}

class SportConnectApp extends ConsumerStatefulWidget {
  const SportConnectApp({super.key});

  @override
  ConsumerState<SportConnectApp> createState() => _SportConnectAppState();
}

class _SportConnectAppState extends ConsumerState<SportConnectApp> {
  final Upgrader _upgrader = Upgrader(countryCode: 'FR');

  bool _deepLinksInitialized = false;
  bool _fcmTokenSaved = false;
  bool _postLaunchStartupStarted = false;
  bool _postLaunchStartupCompleted = false;
  bool _showUpgradeAlert = false;

  ProviderSubscription<AsyncValue<User?>>? _authSubscription;

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual(authStateProvider, (prev, next) {
      if (!_isFirebaseInitialized) return;

      if (next.value != null) {
        if (_postLaunchStartupCompleted) {
          _saveFcmTokenIfNeeded();
        }
      } else {
        _fcmTokenSaved = false;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_runPostLaunchStartup());
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  Future<void> _runPostLaunchStartup() async {
    if (_postLaunchStartupStarted) return;

    _postLaunchStartupStarted = true;

    if (_isFirebaseInitialized) {
      final router = ref.read(appRouterProvider);
      _initializeDeepLinks(router);
    }

    final analyticsCollectionEnabled = ref
        .read(settingsRepositoryProvider)
        .analyticsCollectionEnabled;

    await _initializeAppAfterFirstFrame(
      analyticsCollectionEnabled: analyticsCollectionEnabled,
    );

    if (!mounted) return;

    _postLaunchStartupCompleted = true;

    if (_isFirebaseInitialized) {
      _saveFcmTokenIfNeeded();
      // Best practice: verify the user's Sign in with Apple credential is still
      // valid on launch and sign out if it was revoked externally. Best-effort
      // and a no-op on non-Apple platforms / the emulator.
      unawaited(ref.read(authRepositoryProvider).verifyAppleCredentialState());
    }

    if (!mounted) return;

    setState(() {
      _showUpgradeAlert = true;
    });
  }

  void _initializeDeepLinks(GoRouter router) {
    if (_deepLinksInitialized || !_isFirebaseInitialized) return;

    _deepLinksInitialized = true;

    PushNotificationService.navigatorKey = rootNavigatorKey;

    unawaited(ref.read(deepLinkServiceProvider).initialize(router));

    // The GoRouter navigator key context is null at this point because the
    // router hasn't rendered its first route yet.  Schedule a second
    // post-frame callback so navigation runs after the router is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        ref
            .read(pushNotificationServiceProvider)
            .handlePendingInitialMessage(ctx);
      }
    });
  }

  void _saveFcmTokenIfNeeded() {
    if (_fcmTokenSaved || !_isFirebaseInitialized) return;
    if (!_postLaunchStartupCompleted) return;

    final authUser = ref.read(authStateProvider).value;

    if (authUser != null) {
      _fcmTokenSaved = true;

      unawaited(
        ref.read(pushNotificationServiceProvider).saveFcmToken(authUser.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(settingsViewModelProvider.select((s) => s.locale));

    // Tablet/iPad strategy — "true responsive", not a magnified phone.
    //
    // PHONES are unchanged: they keep the legacy ResponsiveScaledBox(width:428)
    // fixed-width scaling, so iPhone rendering is byte-for-byte identical.
    //
    // TABLETS/iPads no longer get ResponsiveScaledBox. That wrapper made the
    // whole app believe it was a 428-pt phone (so MediaQuery reported 428
    // everywhere and every `isTablet` / MaxWidthContainer check was dead on
    // iPad) and then FittedBox-scaled the result ~2.4× to fill the screen —
    // which is exactly why text looked huge and inconsistent vs iPhone. On
    // tablets we now let MediaQuery expose the REAL width so the existing
    // responsive layouts (breakpoints, isTablet, MaxWidthContainer used by ~48
    // screens) finally activate, while ScreenUtil is still capped at 428pt so
    // .sp/.w/.h text stays phone-scaled (consistent typography) and each screen
    // uses the extra width for real multi-column layouts.
    final app = ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (context, child) {
        // ScreenUtilInit reads MediaQueryData.fromView() and would otherwise
        // scale .sp/.w/.h by realWidth/375 (~2.7× on a 13" iPad). Re-configure
        // with the width clamped to a design cap. Phones (realWidth ≤ 430) are
        // unaffected — the cap only bites on tablets, where we use 576pt so the
        // whole UI scales up ~1.5× SHARPLY (real sizes, not the old blurry
        // FittedBox) to fill the larger screen. MediaQuery still exposes the
        // real device size, so responsive breakpoints/layouts keep working.
        final view = View.maybeOf(context);
        if (view != null) {
          final real = MediaQueryData.fromView(view);
          final cappedW = real.size.width.clamp(0.0, 576.0);
          // Use the DESIGN aspect ratio (375:812), not the device's real
          // aspect, so ScreenUtil's scaleHeight equals scaleWidth. Otherwise
          // on iPad .sp/.w scale ~1.5× while .h only scales ~0.95× — the
          // asymmetry makes 1.5× text overflow the 0.95× SizedBox/card heights
          // that hold it (the carousel/card overflow stripes). Symmetric
          // scaling keeps heights in step with text.
          var designW = cappedW;
          var designH = cappedW * (812.0 / 375.0);
          // Landscape fix: the symmetric design height above is derived from the
          // (capped) WIDTH, so in landscape — where the real screen is short and
          // wide — it far exceeds the real height and every vertical layout
          // overflows (the landscape overflow stripes). When that happens, clamp
          // the scale to the real height instead, keeping width:height symmetric
          // so .sp/.w/.h stay proportional and content fits. Portrait is
          // unaffected (there the height-derived path is never shorter).
          final isLandscape = real.size.width > real.size.height;
          if (isLandscape && designH > real.size.height) {
            final scale = real.size.height / 812.0;
            designW = 375.0 * scale;
            designH = 812.0 * scale;
          }
          ScreenUtil.configure(
            data: real.copyWith(size: Size(designW, designH)),
            designSize: const Size(375, 812),
            minTextAdapt: false,
            splitScreenMode: false,
          );
        }
        return ResponsiveBreakpoints.builder(
          child: AdaptiveApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: ThemeMode.light,
            materialLightTheme: AppMaterialTheme.lightTheme,
            materialDarkTheme: AppMaterialTheme.darkTheme,
            cupertinoLightTheme: AppCupertinoTheme.lightTheme,
            cupertinoDarkTheme: AppCupertinoTheme.darkTheme,
            routerConfig: router,
            builder: (context, child) {
              final appChild = child ?? const SizedBox.shrink();

              var wrappedChild = appChild;

              if (_isFirebaseInitialized && _showUpgradeAlert) {
                wrappedChild = UpgradeAlert(
                  upgrader: _upgrader,
                  navigatorKey: rootNavigatorKey,
                  dialogStyle: UpgradeDialogStyle.cupertino,
                  showIgnore: false,
                  showReleaseNotes: false,
                  child: appChild,
                );
              }

              // Transparent root Material so Material widgets (InkWell,
              // TextField, etc.) inside Cupertino-scaffold screens
              // (AdaptiveScaffold renders CupertinoPageScaffold on iOS, which
              // has no Material) always find a Material ancestor — fixes the
              // "No Material widget found" crashes app-wide from one place.
              return Material(
                type: MaterialType.transparency,
                child: _DismissKeyboardOnTap(child: wrappedChild),
              );
            },
          ),
          breakpoints: [
            const Breakpoint(start: 0, end: 600, name: MOBILE),
            const Breakpoint(start: 601, end: 900, name: TABLET),
            const Breakpoint(start: 901, end: 1200, name: DESKTOP),
            const Breakpoint(
              start: 1201,
              end: double.infinity,
              name: '4K',
            ),
          ],
        );
      },
    );

    // Device class is rotation-invariant (shortestSide), so an iPhone in
    // landscape is never mistaken for a tablet. Phones keep the legacy
    // fixed-width scaling; tablets render responsively at real width.
    final isTabletClass =
        MediaQueryData.fromView(View.of(context)).size.shortestSide >= 600;

    return isTabletClass ? app : ResponsiveScaledBox(width: 428, child: app);
  }
}

class _DismissKeyboardOnTap extends StatelessWidget {
  const _DismissKeyboardOnTap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        final currentFocus = FocusManager.instance.primaryFocus;

        if (currentFocus == null || !currentFocus.hasFocus) return;

        // If an EditableText (TextField/CupertinoTextField) currently holds
        // focus, skip the unfocus here. The tap may land on another text field,
        // which will claim focus itself. Each text field's onTapOutside callback
        // handles dismissal when the user taps a non-input area. Calling
        // unfocus() unconditionally on iPad (iPadOS 26+) triggers a
        // keyboard-hide animation that races with the incoming focus request,
        // causing the keyboard not to reappear for the new field.
        if (currentFocus.context?.widget is EditableText) return;

        currentFocus.unfocus();
      },
      child: child,
    );
  }
}
