/// The balance panel: available credits as the primary figure, total and
/// reserved as separate labels, the next expiry and the top-up action.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../domain/entities.dart';

class WalletSummaryPanel extends StatelessWidget {
  const WalletSummaryPanel({
    super.key,
    required this.wallet,
    required this.updatedAt,
    required this.onTopUp,
    this.stale = false,
  });

  final WalletSnapshot wallet;
  final DateTime? updatedAt;
  final VoidCallback onTopUp;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color ink = scheme.onPrimaryContainer;
    final DateTime? expiry = wallet.nextExpiryAt;
    return Container(
      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: AppRadii.cardAll),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            top: 0,
            end: 0,
            child: CustomPaint(size: const Size(120, 96), painter: _TerraceLines(color: ink.withValues(alpha: 0.14))),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  context.l10n.availableCredits,
                  style: theme.textTheme.labelLarge?.copyWith(color: ink.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.fmt.integer(wallet.available),
                  style: theme.textTheme.displayLarge?.copyWith(color: ink, fontWeight: FontWeight.w700, height: 1.1),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.availableNow,
                  style: theme.textTheme.bodySmall?.copyWith(color: ink.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Divider(color: ink.withValues(alpha: 0.16), height: 1),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(child: _Stat(label: context.l10n.balance, value: context.fmt.integer(wallet.balance), ink: ink)),
                    Expanded(
                      child: _Stat(label: context.l10n.reserved, value: context.fmt.integer(wallet.reserved), ink: ink),
                    ),
                  ],
                ),
                if (wallet.hasReserved) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.reservedNotSpendable,
                    style: theme.textTheme.bodySmall?.copyWith(color: ink.withValues(alpha: 0.75)),
                  ),
                ],
                if (expiry != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.event_outlined, size: 18, color: ink.withValues(alpha: 0.8)),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          expiry.isAfter(DateTime.now()) && expiry.difference(DateTime.now()).inDays <= 30
                              ? context.l10n.expirySoon(context.fmt.date(expiry))
                              : '${context.l10n.nextExpiry}: ${context.fmt.date(expiry)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: ink.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onTopUp,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.topUpBalance),
                ),
                if (updatedAt != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stale
                        ? context.l10n.balanceStaleHint
                        : context.l10n.lastUpdated(context.fmt.time(updatedAt)),
                    style: theme.textTheme.bodySmall?.copyWith(color: ink.withValues(alpha: 0.65)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TerraceLines extends CustomPainter {
  const _TerraceLines({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 0; i < 4; i += 1) {
      final double inset = i * 10.0;
      final Path path = Path()
        ..moveTo(size.width * 0.18 + inset, size.height)
        ..lineTo(size.width, size.height * 0.32 + inset * 0.55);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_TerraceLines oldDelegate) => oldDelegate.color != color;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.ink});

  final String label;
  final String value;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ink)),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ink.withValues(alpha: 0.7))),
      ],
    );
  }
}
