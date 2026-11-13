/// The primary action button: full width, 48dp tall, single-flight by design.
///
/// Labels wrap instead of ellipsizing, and a busy button keeps its label width
/// so the layout never jumps.
library;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || onPressed == null;
    final Widget labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[Icon(icon, size: 20), const SizedBox(width: 10)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    final Widget child = isLoading
        ? Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(opacity: 0, child: labelRow),
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          )
        : labelRow;
    final Widget button = FilledButton(
      onPressed: disabled ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size(64, AppSpacing.minTapTarget)),
      child: child,
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Widget labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[Icon(icon, size: 20), const SizedBox(width: 10)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading || onPressed == null ? null : onPressed,
        child: isLoading
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Opacity(opacity: 0, child: labelRow),
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              )
            : labelRow,
      ),
    );
  }
}
