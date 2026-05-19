import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/core/widgets/adaptive_shell_scaffold.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

void main() {
  AdaptiveShellScaffold buildShell(Size size) {
    return AdaptiveShellScaffold(
      activeIndex: 0,
      onDestinationSelected: (_) {},
      destinations: const [
        AdaptiveShellDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
        ),
        AdaptiveShellDestination(
          icon: Icons.chat_outlined,
          selectedIcon: Icons.chat,
          label: 'Chat',
        ),
      ],
      child: const SizedBox.expand(),
    );
  }

  Future<void> pumpShell(WidgetTester tester, Size size) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: buildShell(size),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('keeps bottom navigation on compact portrait', (tester) async {
    await pumpShell(tester, const Size(390, 844));

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('keeps bottom navigation on short landscape phones', (
    tester,
  ) async {
    await pumpShell(tester, const Size(700, 390));

    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('keeps bottom navigation on narrow tablets', (tester) async {
    await pumpShell(tester, const Size(700, 900));

    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('promotes to navigation rail on taller tablet widths', (
    tester,
  ) async {
    await pumpShell(tester, const Size(900, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('SportConnect'), findsOneWidget);
  });
}
