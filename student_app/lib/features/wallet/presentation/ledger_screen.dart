/// Full credit history, paged with the server cursor. Server order is kept;
/// day headings only group rows visually.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../domain/entities.dart';
import 'ledger_row.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final List<LedgerEntry> _items = <LedgerEntry>[];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  AppFailure? _failure;
  AppFailure? _moreFailure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || _cursor == null)) return;
    setState(() {
      if (more) {
        _loadingMore = true;
        _moreFailure = null;
      } else {
        _loading = true;
        _failure = null;
      }
    });
    try {
      final LedgerPage page = await context.services.walletRepository.fetchLedger(
        cursor: more ? _cursor : null,
      );
      if (!mounted) return;
      setState(() {
        if (!more) _items.clear();
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _loading = false;
        _loadingMore = false;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (more) {
          _moreFailure = failure;
        } else {
          _failure = failure;
        }
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(title: context.l10n.ledgerTitle, child: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failure != null && _items.isEmpty) return ErrorView(failure: _failure!, onRetry: _load);
    if (_items.isEmpty) {
      return EmptyView(
        title: context.l10n.ledgerEmpty,
        message: context.l10n.ledgerEmptyHint,
        icon: Icons.receipt_long_outlined,
      );
    }
    final List<Widget> rows = <Widget>[];
    DateTime? lastDay;
    for (final LedgerEntry entry in _items) {
      final DateTime day = DateUtils.dateOnly(entry.createdAt.toLocal());
      if (lastDay == null || !DateUtils.isSameDay(lastDay, day)) {
        rows.add(_DayHeading(label: context.fmt.date(entry.createdAt), first: lastDay == null));
        lastDay = day;
      }
      rows.add(LedgerRow(entry: entry, showDate: false));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          AppSpacing.xs,
          AppSpacing.gutterOf(context),
          AppSpacing.xl,
        ),
        itemCount: rows.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < rows.length) return rows[index];
          return _Footer(
            hasMore: _cursor != null,
            loading: _loadingMore,
            failure: _moreFailure,
            onMore: () => _load(more: true),
          );
        },
      ),
    );
  }
}

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.label, required this.first});

  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? AppSpacing.xs : AppSpacing.md, bottom: AppSpacing.xxs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.hasMore,
    required this.loading,
    required this.failure,
    required this.onMore,
  });

  final bool hasMore;
  final bool loading;
  final AppFailure? failure;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Text(
          context.l10n.ledgerAllShown,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (failure != null) ...<Widget>[
            Text(
              context.l10n.ledgerLoadMoreFailed,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              failureMessage(context.l10n, failure!),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          SecondaryButton(label: context.l10n.loadMoreLedger, isLoading: loading, onPressed: loading ? null : onMore),
        ],
      ),
    );
  }
}
