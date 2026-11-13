/// Screens the router can land on outside the normal feature flow.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/env.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../widgets/primary_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _slowTimer;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    // Session restore gives up after 12 seconds; say so instead of spinning
    // silently if the network is slow.
    _slowTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterOf(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const AppMark(size: 88),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.appName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.tagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5)),
              if (_slow) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.splashBusyHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The brand mark: a drawn notebook, so no bitmap asset is needed at startup.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.menu_book_rounded, size: size * 0.56, color: scheme.onPrimaryContainer),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _MessageScreen(
      icon: Icons.explore_off_outlined,
      title: l10n.notFoundTitle,
      body: l10n.notFoundBody,
      actionLabel: l10n.goHome,
      onAction: () => context.go('/home'),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _MessageScreen(
      icon: Icons.construction_rounded,
      title: l10n.maintenanceTitle,
      body: l10n.maintenanceBody,
      actionLabel: l10n.retry,
      onAction: () => context.go('/splash'),
    );
  }
}

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // No store destination is configured for this build, so no working update
    // button is offered; the copy names the real place to update.
    return _MessageScreen(
      icon: Icons.system_update_alt_rounded,
      title: l10n.forceUpdateTitle,
      body: l10n.forceUpdateBody,
      footer: l10n.version(Env.appVersion),
    );
  }
}

class _MessageScreen extends StatelessWidget {
  const _MessageScreen({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 64, color: scheme.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  if (actionLabel != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(label: actionLabel!, onPressed: onAction),
                  ],
                  if (footer != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      footer!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}