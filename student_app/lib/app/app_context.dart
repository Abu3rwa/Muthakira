/// One-line access to services, localisation and formatting from any widget.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/formatters.dart';
import '../core/l10n/generated/app_localizations.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/wallet/presentation/wallet_controller.dart';
import 'app_services.dart';

extension AppContext on BuildContext {
  AppServices get services => Provider.of<AppServices>(this, listen: false);
  AuthController get auth => services.auth;
  WalletController get walletController => services.wallet;
  LocaleController get localeController => services.locale;
  ThemeController get themeController => services.theme;

  AppLocalizations get l10n => AppLocalizations.of(this);
  Formatters get fmt => Provider.of<Formatters>(this);
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  /// One shared refresh after every paid AI call — success, timeout recovery
  /// or failure — so the balance never shows a stale number.
  Future<void> refreshWalletAfterAi() => walletController.refresh();

  void snack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}