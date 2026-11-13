/// The widget tree root: providers, theme, locale and the router.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/l10n/formatters.dart';
import '../core/l10n/generated/app_localizations.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'app_router.dart';
import 'app_services.dart';

class MothakiraApp extends StatefulWidget {
  const MothakiraApp({super.key, required this.services});

  final AppServices services;

  @override
  State<MothakiraApp> createState() => _MothakiraAppState();
}

class _MothakiraAppState extends State<MothakiraApp> {
  late final GoRouter _router = AppRouter.create(widget.services);

  @override
  Widget build(BuildContext context) {
    final AppServices services = widget.services;
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: services),
        ChangeNotifierProvider<LocaleController>.value(value: services.locale),
        ChangeNotifierProvider<ThemeController>.value(value: services.theme),
      ],
      child: ListenableBuilder(
        listenable: Listenable.merge(<Listenable>[services.locale, services.theme]),
        builder: (BuildContext context, Widget? _) {
          return Provider<Formatters>.value(
            value: Formatters(
              locale: services.locale.languageCode,
              digitStyle: services.theme.digitStyle,
            ),
            child: MaterialApp.router(
              onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appName,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: services.theme.themeMode,
              locale: services.locale.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: _router,
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(services.theme.textScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
