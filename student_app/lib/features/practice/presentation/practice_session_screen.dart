/// One practice attempt: navigate questions, save drafts, submit for marking.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/question_tree.dart';
import '../domain/practice_models.dart';
import 'ai_grade_panel.dart';
import 'answer_input.dart';
import 'practice_panels.dart';
import 'question_navigator_sheet.dart';

class _SessionData {
  const _SessionData({
    required this.view,
    required this.exam,
    required this.entries,
    required this.drafts,
  });

  final AttemptView view;
  final ExamDetail exam;
  final List<PracticeEntry> entries;
  final Map<String, Object?> drafts;
}

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({super.key, required this.attemptId, this.startIndex = 0});

  final String attemptId;
  final int startIndex;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

/// Report dialog: a stable reason code plus optional free text.
class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  String _code = 'wrong_key';
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> options = <(String, String)>[
      ('wrong_key', context.l10n.reportReason2),
      ('typo', context.l10n.reportReason3),
      ('unclear', context.l10n.reportReason1),
      ('other', context.l10n.reportReason4),
    ];
    final String selectedLabel = options.firstWhere(((String, String) option) => option.$1 == _code).$2;
    return AlertDialog(
      title: Text(context.l10n.reportQuestion),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (String code, String label) in options)
              RadioListTile<String>(
                value: code,
                groupValue: _code,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label, style: context.text.bodyMedium),
                onChanged: (String? value) => setState(() => _code = value ?? _code),
              ),
            TextField(
              controller: _text,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(hintText: context.l10n.reportTextHint),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final String text = _text.text.trim();
            if (text.isNotEmpty && text.length < Limits.reportReasonMin) {
              context.snack(context.l10n.reportReasonHint);
              return;
            }
            Navigator.of(context).pop((code: _code, label: selectedLabel, text: text.isEmpty ? null : text));
          },
          child: Text(context.l10n.reportQuestion),
        ),
      ],
    );
  }
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  late Future<_SessionData> _future = _load();
  _SessionData? _data;
  final Map<String, Object?> _answers = <String, Object?>{};
  final Map<String, AnswerFeedback> _feedback = <String, AnswerFeedback>{};
  final Set<String> _queued = <String>{};
  final Set<String> _drafts = <String>{};
  Map<String, AnswerRecord> _records = <String, AnswerRecord>{};
  final Map<String, Timer> _draftTimers = <String, Timer>{};
  int _index = 0;
  bool _submitting = false;

  @override
  void dispose() {
    for (final Timer timer in _draftTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _saveDraftDebounced(String questionId, Object value) {
    _draftTimers[questionId]?.cancel();
    _draftTimers[questionId] = Timer(const Duration(milliseconds: 600), () {
      _draftTimers.remove(questionId);
      if (mounted) {
        context.services.practiceRepository.saveDraft(widget.attemptId, questionId, value);
      }
    });
  }

  Future<_SessionData> _load() async {
    final services = context.services;
    final AttemptView view = await services.practiceRepository.fetch(widget.attemptId);
    final ExamDetail exam = await services.examRepository.detail(view.attempt.examId);
    final Map<String, Object?> drafts = await services.practiceRepository.drafts(widget.attemptId);
    return _SessionData(view: view, exam: exam, entries: QuestionTree.flatten(exam), drafts: drafts);
  }

  void _adopt(_SessionData data) {
    _data = data;
    _records = data.view.byQuestion;
    _drafts.addAll(data.drafts.keys);
    _answers.addAll(data.drafts);
    _index = QuestionTree.resumeIndex(data.entries, _records.keys.toSet(), requested: widget.startIndex);
  }

  bool _valid(Object? answer) => hasAnswerContent(answer);

  Future<void> _submit(Question question) async {
    final Object? answer = _answers[question.id];
    if (!_valid(answer)) {
      context.snack(context.l10n.fieldAnswerRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      final AnswerResult result = await context.services.practiceRepository.submit(
        widget.attemptId,
        question.id,
        answer!,
      );
      if (!mounted) return;
      setState(() {
        _records = <String, AnswerRecord>{..._records, question.id: result.answer};
        _feedback[question.id] = result.feedback;
        _queued.remove(question.id);
        _drafts.remove(question.id);
      });
      _draftTimers.remove(question.id)?.cancel();
    } on AppFailure catch (failure) {
      if (!mounted) return;
      if (failure.isOffline) {
        setState(() => _queued.add(question.id));
        context.snack(context.l10n.offlineQueued);
      } else {
        context.snack(failureMessage(context.l10n, failure));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _finish() async {
    // Queued offline answers must reach the server before the attempt closes,
    // otherwise they are dropped with ATTEMPT_CLOSED.
    try {
      final int flushed = await context.services.practiceRepository.flushPending();
      if (!mounted) return;
      if (flushed > 0) {
        final AttemptView view = await context.services.practiceRepository.fetch(widget.attemptId);
        if (!mounted) return;
        setState(() {
          _records = view.byQuestion;
          _queued.clear();
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    }
    if (!mounted) return;
    final int answered = _records.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.finishConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(context.l10n.finishConfirmBody),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${context.l10n.answeredCount(answered)} · '
              '${context.l10n.questionCount(_data?.entries.length ?? 0)}',
              style: context.text.labelMedium,
            ),
            if (_queued.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                context.l10n.pendingUploadCount(_queued.length),
                style: context.text.labelMedium?.copyWith(color: context.semantics.warning),
              ),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.backToQuestions),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.finishPractice),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.services.practiceRepository.close(widget.attemptId);
      if (mounted) context.pushReplacement(Routes.resultOf(widget.attemptId));
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    }
  }

  Future<void> _report(Question question) async {
    final ({String code, String label, String? text})? choice = await showDialog<({String code, String label, String? text})>(
      context: context,
      builder: (BuildContext dialogContext) => const _ReportDialog(),
    );
    if (choice == null || !mounted) return;
    try {
      await context.services.practiceRepository.report(
        question.id,
        choice.text ?? choice.label,
        code: choice.code,
      );
      if (mounted) context.snack(context.l10n.reportSent);
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    }
  }

  void _tryAgain(Question question) {
    final AnswerRecord? record = _records[question.id];
    if (record == null) return;
    if (record.aiMarked) context.snack(context.l10n.tryAgainAiWarning);
    setState(() {
      _answers[question.id] = record.answer;
      _records = <String, AnswerRecord>{..._records}..remove(question.id);
      _feedback.remove(question.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionData>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<_SessionData> snapshot) {
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
        if (_data == null) _adopt(snapshot.data!);
        return _buildSession();
      },
    );
  }

  Widget _buildSession() {
    final _SessionData data = _data!;
    if (data.entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyView(title: context.l10n.emptyPractice, message: context.l10n.emptyPracticeHint),
      );
    }
    final PracticeEntry entry = data.entries[_index];
    final Question question = entry.question;
    final List<String> letters = data.exam.summary.language == 'en' ? AppConstants.englishLetters : AppConstants.arabicLetters;
    final AnswerRecord? record = _records[question.id];
    final AnswerFeedback? feedback = _feedback[question.id];
    final Object? initial = record?.answer ?? _answers[question.id] ?? data.drafts[question.id];
    final bool isLast = _index == data.entries.length - 1;
    final double ratio = data.entries.isEmpty ? 0 : _records.length / data.entries.length;
    final AnswerState? state = record != null
        ? AnswerState.submitted
        : _queued.contains(question.id)
        ? AnswerState.queued
        : _drafts.contains(question.id)
        ? AnswerState.draft
        : null;
    final bool inlineBlanks = question.type == 'fill_blank' || question.type == 'language_analysis';
    final String? instruction = switch (question.type) {
      'fill_blank' || 'language_analysis' => context.l10n.fillBlankInstruction,
      'matching_item' => context.l10n.matchingInstruction,
      'multi_select' => context.l10n.multiInstruction,
      'ordering' => context.l10n.orderingInstruction,
      'table_fill' => context.l10n.tableInstruction,
      'matrix_input' => context.l10n.matrixInstruction,
      'truth_table' => context.l10n.truthTableInstruction,
      'diacritics' => context.l10n.diacriticsInstruction,
      _ => null,
    };
    final Widget answerInput = AnswerInput(
      key: ValueKey<String>(question.id),
      question: question,
      letters: letters,
      initial: initial,
      enabled: record == null,
      revealedKey: feedback?.key ?? record?.key,
      onChanged: (Object? value) {
        setState(() {
          _answers[question.id] = value;
          if (_valid(value)) {
            _drafts.add(question.id);
          }
        });
        if (_valid(value)) {
          _saveDraftDebounced(question.id, value!);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(data.exam.summary.subject, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showNavigator(data),
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: context.l10n.questionNavigator,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'report') _report(question);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'report', child: Text(context.l10n.reportQuestion)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          AppSpacing.sm,
          AppSpacing.gutterOf(context),
          AppSpacing.xl,
        ),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                context.l10n.questionOf('${_index + 1}', '${data.entries.length}'),
                style: context.text.labelLarge,
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  context.l10n.answeredCount(_records.length),
                  style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(value: ratio, minHeight: 4),
          ),
          const SizedBox(height: AppSpacing.md),
          if (entry.stimulus != null) ...<Widget>[
            SectionCard(
              title: context.l10n.stimulusTitle,
              child: QuestionContext(sections: const <Question>[], stimulus: entry.stimulus),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(question.path, style: context.text.labelSmall),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        context.l10n.marksWorth(context.fmt.marks(question.marks)),
                        style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                if (entry.sections.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  QuestionContext(sections: entry.sections),
                ],
                if (!inlineBlanks) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  ContentText(
                    question.text,
                    style: context.text.bodyLarge?.copyWith(height: 1.6, fontWeight: FontWeight.w500),
                  ),
                ],
                if (instruction != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(instruction, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant)),
                ],
                if (inlineBlanks) ...<Widget>[
                  if (record != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.yourAnswer,
                      style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  answerInput,
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!inlineBlanks) ...<Widget>[
            SectionCard(
              title: record != null ? context.l10n.yourAnswer : null,
              child: answerInput,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // A fixed slot keeps the "saved on this device" line from shifting
          // the page once the first keystroke arrives.
          SizedBox(
            height: 22,
            child: state != null && feedback == null ? AnswerStatusLine(state: state) : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (record == null)
            const SizedBox.shrink()
          else if (feedback != null)
            FeedbackPanel(feedback: feedback, totalMarks: question.marks, question: question, letters: letters)
          else
            SectionCard(
              child: MarkedOnlyPanel(
                record: record,
                totalMarks: question.marks,
                attemptId: widget.attemptId,
                onUpdated: (AnswerRecord updated) => setState(() {
                  _records = <String, AnswerRecord>{..._records, question.id: updated};
                  _feedback.remove(question.id);
                }),
              ),
            ),
          if (record != null &&
              !record.aiInflight &&
              (record.markingStatus != MarkingStatus.marked || (record.awardedMarks ?? 0) < question.marks)) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _tryAgain(question),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.l10n.tryAgain),
              ),
            ),
          ],
          if (record != null && record.isAiRubric) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AiGradePanel(
              attemptId: widget.attemptId,
              record: record,
              totalMarks: question.marks,
              onUpdated: (AnswerRecord updated) => setState(() {
                _records = <String, AnswerRecord>{..._records, question.id: updated};
                _feedback.remove(question.id);
              }),
            ),
          ],
          if (isLast) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(label: context.l10n.finishPractice, onPressed: _finish),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterOf(context),
            AppSpacing.xs,
            AppSpacing.gutterOf(context),
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (record == null) ...<Widget>[
                PrimaryButton(
                  label: context.l10n.checkAnswer,
                  isLoading: _submitting,
                  onPressed: _submitting || !_valid(_answers[question.id]) ? null : () => _submit(question),
                ),
                if (!_valid(_answers[question.id]))
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Text(
                      context.l10n.checkDisabledHint,
                      style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Row(
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: _index == 0 ? null : () => setState(() => _index -= 1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: context.l10n.previousQuestion,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SecondaryButton(
                      label: context.l10n.nextQuestion,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: isLast ? null : () => setState(() => _index += 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigator(_SessionData data) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => QuestionNavigatorSheet(
        entries: data.entries,
        records: _records,
        queued: _queued,
        currentIndex: _index,
        onSelect: (int index) {
          Navigator.of(sheetContext).pop();
          setState(() => _index = index);
        },
        onFinish: () {
          Navigator.of(sheetContext).pop();
          _finish();
        },
      ),
    );
  }
}
