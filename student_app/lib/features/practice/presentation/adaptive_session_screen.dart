/// S28: one question at a time, chosen and difficulty-matched by the server.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_services.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../../exams/domain/exam_models.dart';
import '../domain/practice_models.dart';
import 'adaptive_panels.dart';
import 'ai_grade_panel.dart';
import 'answer_input.dart';
import 'practice_panels.dart';

class _Boot {
  const _Boot({required this.exam, required this.view, required this.step});

  final ExamDetail exam;
  final AttemptView view;
  final AdaptiveStep step;
}

class AdaptiveSessionScreen extends StatefulWidget {
  const AdaptiveSessionScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  State<AdaptiveSessionScreen> createState() => _AdaptiveSessionScreenState();
}

class _AdaptiveSessionScreenState extends State<AdaptiveSessionScreen> {
  late Future<_Boot> _boot = _load();
  ExamDetail? _exam;
  AdaptiveStep? _step;
  AnswerRecord? _record;
  AnswerFeedback? _feedback;
  Object? _answer;
  bool _submitting = false;
  bool _loadingNext = false;
  int _asked = 0;

  Future<_Boot> _load() async {
    final AppServices services = context.services;
    final AttemptView view = await services.practiceRepository.fetch(widget.attemptId);
    final ExamDetail exam = await services.examRepository.detail(view.attempt.examId);
    final AdaptiveStep step = await services.practiceRepository.nextAdaptive(widget.attemptId);
    return _Boot(exam: exam, view: view, step: step);
  }

  void _adopt(_Boot boot) {
    _exam = boot.exam;
    _step = boot.step;
    _asked = boot.view.attempt.answersCount;
  }

  Future<void> _submit(Question question) async {
    final Object? answer = _answer;
    if (!hasAnswerContent(answer)) {
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
        _record = result.answer;
        _feedback = result.feedback;
        _asked += 1;
      });
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _next() async {
    setState(() => _loadingNext = true);
    try {
      final AdaptiveStep step = await context.services.practiceRepository.nextAdaptive(widget.attemptId);
      if (!mounted) return;
      setState(() {
        _step = step;
        _record = null;
        _feedback = null;
        _answer = null;
      });
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _loadingNext = false);
    }
  }

  Future<void> _finish() async {
    try {
      await context.services.practiceRepository.close(widget.attemptId);
      if (mounted) context.pushReplacement(Routes.resultOf(widget.attemptId));
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Boot>(
      future: _boot,
      builder: (BuildContext context, AsyncSnapshot<_Boot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final Object error = snapshot.error!;
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: () => setState(() => _boot = _load()),
            ),
          );
        }
        if (_exam == null) _adopt(snapshot.data!);
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    final ExamDetail exam = _exam!;
    final AdaptiveStep step = _step!;
    final double gutter = AppSpacing.gutterOf(context);
    final Widget content;
    if (!step.hasQuestion) {
      content = AdaptiveTerminal(
        exhausted: step.exhausted,
        onFinish: _finish,
      );
    } else {
      content = _questionBody(exam, step);
    }
    return Scaffold(
      appBar: AppBar(title: Text(exam.summary.subject, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: content,
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(gutter, AppSpacing.xs, gutter, AppSpacing.sm),
        child: TextButton(
          onPressed: _loadingNext ? null : _finish,
          child: Text(context.l10n.finishPractice),
        ),
      ),
    );
  }

  Widget _questionBody(ExamDetail exam, AdaptiveStep step) {
    final Question question = step.question!;
    final double gutter = AppSpacing.gutterOf(context);
    final List<String> letters =
        exam.summary.language == 'en' ? AppConstants.englishLetters : AppConstants.arabicLetters;
    final bool answered = _record != null;
    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
      children: <Widget>[
        AdaptiveHeader(asked: _asked, remaining: step.remainingCount),
        const SizedBox(height: AppSpacing.sm),
        QuestionContext(sections: const <Question>[], stimulus: step.stimulus),
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
            Expanded(
              child: Text(
                '${context.l10n.marksWorth(context.fmt.marks(question.marks))} · ${context.l10n.adaptiveAutoLevel}',
                style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (question.type != 'fill_blank' && question.type != 'language_analysis')
          ContentText(
            question.text,
            style: context.text.bodyLarge?.copyWith(height: 1.6, fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: AppSpacing.md),
        AnswerInput(
          key: ValueKey<String>(question.id),
          question: question,
          letters: letters,
          initial: _answer ?? _record?.answer,
          enabled: !answered,
          revealedKey: _feedback?.key ?? _record?.key,
          onChanged: (Object? value) => setState(() => _answer = value),
        ),
        const SizedBox(height: AppSpacing.md),
        if (!answered) ...<Widget>[
          PrimaryButton(
            label: context.l10n.checkAnswer,
            isLoading: _submitting,
            onPressed: _submitting ? null : () => _submit(question),
          ),
        ] else ...<Widget>[
          if (_feedback != null)
            FeedbackPanel(
              feedback: _feedback!,
              totalMarks: question.marks,
              question: question,
              letters: letters,
            )
          else
            MarkedOnlyPanel(
              record: _record!,
              totalMarks: question.marks,
              attemptId: widget.attemptId,
              onUpdated: (AnswerRecord updated) => setState(() {
                _record = updated;
                _feedback = null;
              }),
            ),
          if (_record!.isAiRubric) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AiGradePanel(
              attemptId: widget.attemptId,
              record: _record!,
              totalMarks: question.marks,
              onUpdated: (AnswerRecord updated) => setState(() {
                _record = updated;
                _feedback = null;
              }),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: context.l10n.nextQuestion,
            icon: Icons.arrow_forward_rounded,
            isLoading: _loadingNext,
            onPressed: _loadingNext ? null : _next,
          ),
        ],
      ],
    );
  }
}
