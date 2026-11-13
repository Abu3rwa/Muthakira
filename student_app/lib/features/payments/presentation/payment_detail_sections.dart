/// Transfer instructions and the review timeline for one payment request.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/copy_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/payment_models.dart';

class TransferInstructionsCard extends StatelessWidget {
  const TransferInstructionsCard({super.key, required this.request, required this.onOpenBankak});

  final PaymentRequest request;
  final VoidCallback onOpenBankak;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? bank = _clean(request.bank.bankName);
    final String? holder = _clean(request.bank.accountName);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Step(index: 1, text: context.l10n.stepAmount),
            _Step(index: 2, text: context.l10n.stepBank),
            _Step(index: 3, text: context.l10n.stepBankak),
            _Step(index: 4, text: context.l10n.stepReceipt),
            _Step(index: 5, text: context.l10n.stepStatus, last: true),
            const SizedBox(height: AppSpacing.md),
            if (bank != null) CopyField(label: context.l10n.bankName, value: bank),
            if (bank != null) const SizedBox(height: AppSpacing.sm),
            if (holder != null) CopyField(label: context.l10n.accountName, value: holder),
            if (holder != null) const SizedBox(height: AppSpacing.sm),
            CopyField(label: context.l10n.accountNumber, value: request.receivingAccount, monospace: true),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.fact_check_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.manualReviewNotice,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: context.l10n.openBankak,
              icon: Icons.open_in_new_rounded,
              onPressed: request.bank.isConfigured ? onOpenBankak : null,
            ),
          ],
        ),
      ),
    );
  }

  String? _clean(String? value) {
    final String text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }
}

class PaymentTimelineCard extends StatelessWidget {
  const PaymentTimelineCard({super.key, required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context) {
    final List<({String title, DateTime? at, bool done})> entries = <({String title, DateTime? at, bool done})>[
      (title: context.l10n.timelineCreated, at: request.createdAt, done: true),
      (title: context.l10n.timelineSubmitted, at: request.submittedAt, done: request.submittedAt != null),
      (
        title: context.l10n.timelineReviewed,
        at: null,
        done: request.status == PaymentStatus.underReview ||
            request.status == PaymentStatus.approved ||
            request.status == PaymentStatus.rejected ||
            request.status == PaymentStatus.needsInfo,
      ),
      (title: context.l10n.timelineDecided, at: request.decidedAt, done: request.decidedAt != null),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            for (int i = 0; i < entries.length; i++)
              _TimelineRow(
                title: entries[i].title,
                at: entries[i].at,
                done: entries[i].done,
                last: i == entries.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text, this.last = false});

  final int index;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: Text(context.fmt.integer(index), style: Theme.of(context).textTheme.labelSmall),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.title, required this.at, required this.done, required this.last});

  final String title;
  final DateTime? at;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color dot = done ? scheme.primary : scheme.outlineVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? dot : Colors.transparent,
                  border: Border.all(color: dot, width: 2),
                ),
              ),
              if (!last) Expanded(child: Container(width: 2, color: scheme.outlineVariant)),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  if (at != null)
                    Text(
                      context.fmt.dateTime(at),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
