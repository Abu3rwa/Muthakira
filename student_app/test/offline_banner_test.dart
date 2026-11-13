import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:student_app/app/app_services.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/network/connectivity_controller.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/shared/widgets/offline_banner.dart';

class _MockServices extends Mock implements AppServices {}

class _MockConnectivity extends Mock implements ConnectivityController {}

void main() {
  testWidgets('offline banner explains saved content vs network steps and hides when online', (
    WidgetTester tester,
  ) async {
    final _MockServices services = _MockServices();
    final _MockConnectivity connectivity = _MockConnectivity();
    when(() => services.connectivity).thenReturn(connectivity);
    when(() => connectivity.isOffline).thenReturn(true);

    Widget build() => Provider<AppServices>.value(
      value: services,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: OfflineBanner()),
      ),
    );

    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(find.text(lookupAppLocalizations(const Locale('ar')).offlineBanner), findsOneWidget);

    when(() => connectivity.isOffline).thenReturn(false);
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
  });
}
