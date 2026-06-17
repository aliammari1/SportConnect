import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/features/auth/views/splash_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

void main() {
  Widget buildApp(Size size) {
    return ScreenUtilInit(
      // Use the surface as the design size so ScreenUtil scales 1:1 in the
      // test. The real app caps ScreenUtil width (and clamps to height in
      // landscape) in main.dart; replicating that here keeps the test focused
      // on responsive layout *selection* without the uncapped 2.4× scaling that
      // a raw 375-wide design size would apply at tablet widths.
      designSize: size,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: const SplashScreen(),
          ),
        );
      },
    );
  }

  testWidgets('shows tablet status card on medium screens', (tester) async {
    // Set the real render surface (not just MediaQuery): ResponsiveLayoutBuilder
    // keys off LayoutBuilder constraints, so the physical size must be set for
    // the >= medium (840) breakpoint to engage the expanded/tablet layout.
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(const Size(900, 900)));
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.byKey(const ValueKey('splash_tablet_status_card')),
      findsOneWidget,
    );
  });

  testWidgets('keeps compact splash layout on phones', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(const Size(390, 844)));
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      find.byKey(const ValueKey('splash_tablet_status_card')),
      findsNothing,
    );
  });
}
