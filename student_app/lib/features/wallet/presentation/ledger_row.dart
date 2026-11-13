/// One ledger movement: description, signed amount and date or note.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../domain/entities.dart';

class LedgerRow extends StatelessWidget {
  const LedgerRow({super.key, required this.entry, this.showDate = true});

  final LedgerEntry entry;
  final bool showDate;

  String _label(BuildContext context) => switch (entry.entryType) {
    'signup_bonus' => context.l10n.entrySignupBonus,
    'purchase' => context.l10n.entryPurchase,
    'spend' => context.l10n.entrySpend,
    'expiry' => context.l10n.entryExpiry,
    'admin_adjust' => context.l10n.entryAdminAdjust,
    'exam_unlock' => context.l10n.entryUnlockShort,
    'payment_approved' => context.l10n.entryPaymentApprovedShort,
    _ => entry.entryType,
  };

  @override
  Widget build(BuildContext context) {
    final bool credit = entry.isCredit;
    final Color color = credit
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final String? reason = (entry.reason ?? '').trim().isEmpty ? null : entry.reason!.trim();
    final String? meta = showDate ? context.fmt.dateTime(entry.createdAt) : reason;
    return ListTile(
      dense: true,
      leading: Icon(credit ? Icons.add_circle_outline : Icons.remove_circle_outline, color: color),
      title: Text(_label(context)),
      subtitle: meta == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(meta),
                if (showDate && reason != null) Text(reason),
              ],
            ),
      trailing: Text(
        '${credit ? '+' : '−'}${context.fmt.integer(entry.amount.abs())}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
      ),
    );
  }
}
