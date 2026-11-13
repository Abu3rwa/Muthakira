/// Diagnostics for support calls: build, data source, connection and queue.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/config/env.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  late Future<int> _pending = context.services.practiceRepository.pendingCount();
  DateTime _checkedAt = DateTime.now();
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _pending = context.services.practiceRepository.pendingCount();
      _checkedAt = DateTime.now();
    });
    try {
      await _pending;
    } on Object {
      // The row shows a dash; the refresh action can be tried again.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double gutter = AppSpacing.gutterOf(context);
    return AppPage(
      title: context.l10n.diagnosticsTitle,
      actions: <Widget>[
        IconButton(
          onPressed: _refreshing ? null : _refresh,
          icon: _refreshing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh_rounded),
          tooltip: context.l10n.retry,
        ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
        children: <Widget>[
          Text(
            context.l10n.diagnosticsIntro,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: <Widget>[
                _Row(
                  label: context.l10n.serverUrl,
                  value: Env.apiBaseUrl,
                  hint: context.l10n.diagnosticsApiHint,
                ),
                const Divider(height: 1),
                _Row(label: context.l10n.appVersionLabel, value: Env.appVersion),
                const Divider(height: 1),
                _Row(
                  label: context.l10n.apiMode,
                  value: Env.useFakeApi ? context.l10n.fakeApi : context.l10n.liveApi,
                  hint: context.l10n.diagnosticsApiHint,
                ),
                const Divider(height: 1),
                ListenableBuilder(
                  listenable: context.services.connectivity,
                  builder: (BuildContext context, Widget? _) => _Row(
                    label: context.l10n.connectionLabel,
                    value: context.services.connectivity.isOnline ? context.l10n.online : context.l10n.offline,
                    hint: context.l10n.diagnosticsConnectionHint,
                  ),
                ),
                const Divider(height: 1),
                FutureBuilder<int>(
                  future: _pending,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) => _Row(
                    label: context.l10n.pendingAnswers,
                    value: snapshot.hasData
                        ? context.fmt.integer(snapshot.data!)
                        : snapshot.hasError
                        ? context.l10n.notAvailable
                        : '…',
                    hint: context.l10n.diagnosticsPendingHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.lastChecked(context.fmt.time(_checkedAt)),
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 112,
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  textDirection: _isLatin(value) ? TextDirection.ltr : null,
                  textAlign: _isLatin(value) ? TextAlign.left : null,
                ),
              ),
            ],
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 112 + AppSpacing.sm, top: AppSpacing.xxs),
              child: Text(
                hint!,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  bool _isLatin(String text) => RegExp(r'^[\x20-\x7E]+$').hasMatch(text);
}
