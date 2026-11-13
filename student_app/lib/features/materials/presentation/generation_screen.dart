/// S33: inspectable status for one generation job, with honest settlement copy.
///
/// Refreshing only re-reads the job; it never starts or retries a paid request.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/grade_labels.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../domain/material_models.dart';

class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  GenerationJob? _job;
  AppFailure? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final GenerationJob job = await context.services.materialsRepository.generation(widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _error = null;
          _loading = false;
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) {
        setState(() {
          _error = failure;
          _loading = false;
        });
      }
    }
  }

  void _refresh() {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _fetch();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.materials);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GenerationJob? job = _job;
    return AppPage(
      title: context.l10n.generationStatusTitle,
      actions: <Widget>[
        IconButton(
          onPressed: _loading ? null : _refresh,
          tooltip: context.l10n.generationRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: _content(job),
    );
  }

  Widget _content(GenerationJob? job) {
    final double gutter = AppSpacing.gutterOf(context);
    if (job == null) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      return ErrorView(
        failure: _error ?? const AppFailure.network(),
        onRetry: _refresh,
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
      children: <Widget>[
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        if (_error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.generationRefreshFailed,
            style: context.text.bodySmall?.copyWith(color: context.scheme.error),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        _StatusCard(job: job, onOpenSet: job.isReady ? () => context.push<void>(Routes.exam(job.examId!)) : null),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: context.l10n.generationRefresh,
          icon: Icons.refresh_rounded,
          isLoading: _loading,
          onPressed: _loading ? null : _refresh,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(onPressed: _back, child: Text(context.l10n.generationBack)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.job, this.onOpenSet});

  final GenerationJob job;
  final VoidCallback? onOpenSet;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String title, String body) = switch (job.status) {
      GenerationStatus.review => (
        Icons.hourglass_top_rounded,
        context.semantics.warning,
        context.l10n.generationReviewStatus,
        context.l10n.generationReviewBody,
      ),
      GenerationStatus.ready => (
        Icons.check_circle_outline_rounded,
        context.semantics.success,
        context.l10n.materialStatusReady,
        context.l10n.generationReadyBody,
      ),
      GenerationStatus.failed => (
        Icons.error_outline_rounded,
        context.scheme.error,
        context.l10n.generationFailedStatus,
        job.errorCode == 'AI_CONTENT_UNSAFE' ? context.l10n.generationUnsafe : context.l10n.generationFailedBody,
      ),
      GenerationStatus.rejected => (
        Icons.block_outlined,
        context.scheme.error,
        context.l10n.materialStatusRejected,
        context.l10n.generationRejectedBody,
      ),
      GenerationStatus.unknown => (
        Icons.help_outline_rounded,
        context.scheme.outline,
        context.l10n.generationUnknown,
        context.l10n.generationUnknownBody,
      ),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(title, style: context.text.titleMedium?.copyWith(color: color, height: 1.4)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(body, style: context.text.bodyMedium?.copyWith(height: 1.6)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${job.subject} · ${gradeLabel(context.l10n, job.classLevel)} · ${context.l10n.questionCount(job.count)}',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
            if (job.status == GenerationStatus.ready) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.generationOrigin,
                style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.5),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            if (_chargeLine(context) != null)
              Text(_chargeLine(context)!, style: context.text.labelMedium),
            if (onOpenSet != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: context.l10n.generationOpen,
                icon: Icons.menu_book_rounded,
                onPressed: onOpenSet,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _chargeLine(BuildContext context) {
    if (job.status == GenerationStatus.failed) return context.l10n.generationNoCharge;
    if (job.status == GenerationStatus.rejected || job.status == GenerationStatus.unknown) {
      return null;
    }
    if (job.creditsCharged > 0) return context.l10n.generationCharged(job.creditsCharged);
    return context.l10n.generationNoCharge;
  }
}
