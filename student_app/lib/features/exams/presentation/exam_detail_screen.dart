/// Paper overview: what it contains, whether it is unlocked, and how to start.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/screen_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../../practice/domain/practice_models.dart';
import '../../wallet/domain/entities.dart';
import '../../wallet/presentation/wallet_controller.dart';
import '../domain/exam_models.dart';

enum _UnlockChoice { confirm, topUp }

class ExamDetailScreen extends StatefulWidget {
  const ExamDetailScreen({super.key, required this.examId});

  final String examId;

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  late Future<ExamDetail> _detail = _load();
  bool _busy = false;

  Future<ExamDetail> _load() => context.services.examRepository.detail(widget.examId);

  void _reload() => setState(() => _detail = _load());

  Future<void> _unlock(ExamDetail detail) async {
    final WalletController wallet = context.walletController;
    final ScreenState<WalletSnapshot> state = wallet.state;
    final int? balance = state is ScreenData<WalletSnapshot> ? wallet.available : null;
    final _UnlockChoice? choice = await showModalBottomSheet<_UnlockChoice>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => _UnlockSheet(detail: detail, balance: balance),
    );
    if (choice == null || !mounted) return;
    if (choice == _UnlockChoice.topUp) {
      await context.push<void>(Routes.packages);
      return;
    }
    setState(() => _busy = true);
    final services = context.services;
    try {
      await services.examRepository.unlock(widget.examId);
      await wallet.refresh();
      if (!mounted) return;
      context.snack(context.l10n.unlockSuccess);
      _reload();
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startPractice() async {
    setState(() => _busy = true);
    final services = context.services;
    try {
      final StartAttemptResult result = await services.practiceRepository.start(widget.examId);
      if (!mounted) return;
      await services.prefs.setLastAttempt(widget.examId, result.attempt.id);
      if (!mounted) return;
      await context.push<void>(Routes.sessionOf(result.attempt.id));
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExamDetail>(
      future: _detail,
      builder: (BuildContext context, AsyncSnapshot<ExamDetail> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppPage(title: context.l10n.loading, child: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final Object error = snapshot.error!;
          return AppPage(
            title: context.l10n.examsTitle,
            child: ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: _reload,
            ),
          );
        }
        return _buildDetail(snapshot.data!);
      },
    );
  }

  Widget _buildDetail(ExamDetail detail) {
    final ExamSummary exam = detail.summary;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool unlocked = detail.canAnswerAll;
    final String facts = <String>[
      context.l10n.questionCount(exam.leafQuestionCount),
      context.l10n.totalMarks(context.fmt.marks(exam.totalMarks)),
      if (exam.durationMinutes > 0) context.l10n.durationMinutes(exam.durationMinutes),
    ].join(' · ');
    return AppPage(
      title: exam.subject,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          AppSpacing.xs,
          AppSpacing.gutterOf(context),
          AppSpacing.xl,
        ),
        children: <Widget>[
          _PaperCover(exam: exam),
          const SizedBox(height: AppSpacing.md),
          Text(facts, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          if (detail.instructions != null && detail.instructions!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(context.l10n.instructions, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            _ExpandableText(text: detail.instructions!),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (unlocked)
            PrimaryButton(
              label: context.l10n.startPractice,
              icon: Icons.edit_note_rounded,
              isLoading: _busy,
              onPressed: _busy || !exam.practiceEnabled ? null : _startPractice,
            )
          else ...<Widget>[
            _LockedPanel(detail: detail),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: context.l10n.unlockFor(context.fmt.integer(detail.unlockCost)),
              isLoading: _busy,
              onPressed: _busy ? null : () => _unlock(detail),
            ),
          ],
          if (!exam.practiceEnabled) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.practiceDisabledHint,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: unlocked ? context.l10n.paperViewer : context.l10n.previewQuestions,
            icon: Icons.description_outlined,
            onPressed: () => context.push(Routes.paperOf(exam.id)),
          ),
          if (unlocked) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: context.l10n.viewKeys,
              icon: Icons.key_outlined,
              onPressed: () => context.push(Routes.keysOf(exam.id)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaperCover extends StatelessWidget {
  const _PaperCover({required this.exam});

  final ExamSummary exam;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SemanticColors colors = context.semantics;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadii.cardAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: colors.credit,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ContentText(exam.subject, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 2),
                ContentText(
                  '${exam.session} ${exam.examYear} · ${exam.classLevel}',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedPanel extends StatelessWidget {
  const _LockedPanel({required this.detail});

  final ExamDetail detail;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadii.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline_rounded, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.lockedFor(context.fmt.integer(detail.unlockCost)),
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.lockedQuestionHint,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _UnlockSheet extends StatelessWidget {
  const _UnlockSheet({required this.detail, required this.balance});

  final ExamDetail detail;
  final int? balance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final ExamSummary exam = detail.summary;
    final bool insufficient = balance != null && balance! < detail.unlockCost;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.unlockConfirmTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            ContentText(
              '${exam.subject} · ${exam.session} ${exam.examYear}',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(child: Text(context.l10n.locked, style: theme.textTheme.bodyMedium)),
                Text(
                  context.l10n.creditsCount(detail.unlockCost),
                  style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Expanded(child: Text(context.l10n.availableCredits, style: theme.textTheme.bodyMedium)),
                Text(
                  balance == null ? '—' : context.fmt.integer(balance!),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: insufficient ? context.l10n.topUpBalance : context.l10n.unlock,
              onPressed: () => Navigator.of(context).pop(
                insufficient ? _UnlockChoice.topUp : _UnlockChoice.confirm,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SecondaryButton(
              label: context.l10n.cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6);
    final TextDirection direction = contentDirection(widget.text);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: 4,
          textDirection: direction,
        )..layout(maxWidth: constraints.maxWidth);
        final bool overflows = painter.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ContentText(
              widget.text,
              style: style,
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.clip,
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: AlignmentDirectional.centerStart,
                ),
                child: Text(_expanded ? context.l10n.showLess : context.l10n.showMore),
              ),
          ],
        );
      },
    );
  }
}
