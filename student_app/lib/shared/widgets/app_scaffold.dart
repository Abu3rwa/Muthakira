/// Page chrome shared by every screen: a titled app bar, or a centred,
/// width-capped form shell for the signed-out flows.
library;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBack = true,
    this.floatingActionButton,
    this.bottom,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBack,
        actions: actions,
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(top: false, child: child),
    );
  }
}

/// Signed-out flows stay readable on a tablet but never stretch past 460dp.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.footer,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutterOf(context),
                AppSpacing.md,
                AppSpacing.gutterOf(context),
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (showBack)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                    ),
                  if (title != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(title!, style: text.headlineSmall, textAlign: TextAlign.center),
                  ],
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: text.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  child,
                  if (footer != null) ...<Widget>[const SizedBox(height: AppSpacing.lg), footer!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A group of related settings or form fields.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.title, this.padding});

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null) ...<Widget>[
              Text(title!, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
            ],
            child,
          ],
        ),
      ),
    );
  }
}