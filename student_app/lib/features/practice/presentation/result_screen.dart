/// Attempt result: score, section breakdown and a marked answer review.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/states.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/question_tree.dart';
import '../domain/practice_models.dart';

class _ResultData {
  const _ResultData({
    required this.view,
    required this.exam,
    required this.entries,
    required this.submitted,
  });

  final AttemptView view;
  final ExamDetail exam;
  final List<PracticeEntry> entries;
  final Map<String, Object?> submitted;
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<_ResultData> _future = _load();
  final ScrollController _scroll = ScrollController();
  final GlobalKey _reviewKey = GlobalKey();
  bool _starting = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<_ResultData> _load() async {
    final services = context.services;
    final AttemptView view = await services.practiceRepository.fetch(widget.attemptId);
    final ExamDetail exam = await services.examRepository.detail(view.attempt.examId);
    final Map<String, Object?> submitted = await services.practiceRepository.submittedAnswers(widget.attemptId);
    return _ResultData(view: view, exam: exam, entries: QuestionTree.flatten(exam), submitted: submitted);
  }

  void _openReview() {
    final BuildContext? target = _reviewKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), alignment: 0.02);
    }
  }

  Future<void> _startNew(_ResultData data) async {
    setState(() => _starting = true);
    try {
      final StartAttemptResult result = await context.services.practiceRepository.start(data.exam.summary.id);
      if (!mounted) return;
      context.pushReplacement(Routes.sessionOf(result.attempt.id));
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ResultData>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<_ResultData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final Object error = snapshot.error!;
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: () => setState(() => _future = _load()),
            ),
          );
        }
        return _buildResult(snapshot.data!);
      },
    );
  }

  Widget _buildResult(_ResultData data) {
    final Map<String, AnswerRecord> records = data.view.byQuestion;
    final double awarded = records.values.fold<double>(0, (double sum, AnswerRecord record) => sum + (record.awardedMarks ?? 0));
    final double total = data.exam.summary.totalMarks;
    final bool anyPending = records.values.any((AnswerRecord record) => record.markingStatus != MarkingStatus.marked);
    final ExamSummary summary = data.exam.summary;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.resultTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.go(Routes.exams),
            icon: const Icon(Icons.close_rounded),
            tooltip: context.l10n.close,
          ),
        ],
      ),
      body: ListView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          AppSpacing.sm,
          AppSpacing.gutterOf(context),
          AppSpacing.xl,
        ),
        children: <Widget>[
          ContentText(
            '${summary.subject} — ${summary.session} ${summary.examYear}',
            style: context.text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          ContentText(
            <String>[summary.classLevel, if (summary.stream != null) summary.stream!].join(' · '),
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScorePanel(awarded: awarded, total: total, pending: anyPending),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: context.l10n.reviewAnswers,
            icon: Icons.rate_review_rounded,
            onPressed: _openReview,
          ),
          if (data.entries.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: context.l10n.sectionBreakdown),
            _Breakdown(entries: data.entries, records: records),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(key: _reviewKey, child: SectionHeader(title: context.l10n.reviewAnswers)),
          for (final PracticeEntry entry in data.entries)
            _ReviewTile(
              entry: entry,
              record: records[entry.question.id],
              submitted: data.submitted[entry.question.id],
            ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: context.l10n.newPractice,
            icon: Icons.replay_rounded,
            isLoading: _starting,
            onPressed: _starting ? null : () => _startNew(data),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => context.go(Routes.exams),
            child: Text(context.l10n.backToExams),
          ),
        ],
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.awarded, required this.total, required this.pending});

  final double awarded;
  final double total;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final double ratio = total <= 0 ? 0 : (awarded / total).clamp(0, 1);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            pending ? context.l10n.provisionalScore : context.l10n.finalScore,
            style: context.text.labelLarge?.copyWith(color: context.scheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.scoreOf(context.fmt.marks(awarded), context.fmt.marks(total)),
            style: context.text.displaySmall?.copyWith(color: context.scheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(value: ratio, minHeight: 8),
          ),
          if (pending)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                context.l10n.resultPendingNote,
                style: context.text.bodySmall?.copyWith(color: context.scheme.onPrimaryContainer),
              ),
            ),
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.entries, required this.records});

  final List<PracticeEntry> entries;
  final Map<String, AnswerRecord> records;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<PracticeEntry>> groups = <String, List<PracticeEntry>>{};
    for (final PracticeEntry entry in entries) {
      final String key = entry.sections.isEmpty ? context.l10n.practiceTitle : entry.sections.last.text;
      groups.putIfAbsent(key, () => <PracticeEntry>[]).add(entry);
    }
    return Card(
      child: Column(
        children: <Widget>[
          for (final MapEntry<String, List<PracticeEntry>> group in groups.entries)
            ListTile(
              title: ContentText(group.key),
              trailing: Text(
                context.l10n.scoreOf(
                  context.fmt.marks(group.value.fold<double>(
                    0,
                    (double sum, PracticeEntry entry) => sum + (records[entry.question.id]?.awardedMarks ?? 0),
                  )),
                  context.fmt.marks(group.value.fold<double>(0, (double sum, PracticeEntry entry) => sum + entry.question.marks)),
                ),
                style: context.text.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.entry, required this.record, required this.submitted});

  final PracticeEntry entry;
  final AnswerRecord? record;
  final Object? submitted;

  String? _submittedText() {
    final Object? value = submitted ?? record?.answer;
    if (value == null) return null;
    return switch (value) {
      final String text => text.trim().isEmpty ? null : text,
      final bool flag => flag ? '✓' : '✗',
      final num number => number.toString(),
      final List<Object?> list => list.map((Object? item) => item?.toString() ?? '').join(' · '),
      _ => value.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semantics;
    final AnswerRecord? answer = record;
    final (Color color, String label) = switch (answer) {
      null => (context.scheme.outline, context.l10n.noAnswer),
      final AnswerRecord value when value.markingStatus != MarkingStatus.marked => (colors.info, context.l10n.pendingLabel),
      final AnswerRecord value when value.correct == true => (colors.success, context.l10n.correct),
      final AnswerRecord value when value.hasPartialCredit => (
        colors.warning,
        context.l10n.partlyCorrect(
          context.fmt.marks(value.awardedMarks ?? 0),
          context.fmt.marks(entry.question.marks),
        ),
      ),
      _ => (context.scheme.error, context.l10n.incorrect),
    };
    final String? given = _submittedText();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(entry.question.path, style: context.text.labelLarge),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: context.text.labelMedium?.copyWith(color: color),
                  textAlign: TextAlign.end,
                ),
              ),
              if (answer?.awardedMarks != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
                  child: Text(
                    context.l10n.marksAwarded(context.fmt.marks(answer!.awardedMarks!)),
                    style: context.text.labelMedium?.copyWith(color: color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          ContentText(entry.question.text, style: context.text.bodyMedium),
          if (given != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(context.l10n.yourAnswer, style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant)),
            ContentText(given, style: context.text.bodyMedium),
          ] else if (answer != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.yourAnswerUnavailable,
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
