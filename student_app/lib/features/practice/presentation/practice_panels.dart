/// Shared practice surfaces: question context, answer status and feedback.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../exams/domain/exam_models.dart';
import '../domain/practice_models.dart';

TextStyle _reading(String text) => AppTheme.reading(
  scale: text.length > 600 ? AppType.readingSizeLong / AppType.readingSize : 1,
);

/// Section headings and the shared passage, preserved as written.
class QuestionContext extends StatelessWidget {
  const QuestionContext({super.key, required this.sections, this.stimulus});

  final List<Question> sections;
  final Stimulus? stimulus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final Question section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: ContentText(section.text, style: context.text.titleSmall),
          ),
        if (stimulus != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
              decoration: BoxDecoration(
                border: BorderDirectional(start: BorderSide(color: context.scheme.outline, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (stimulus!.title != null) ...<Widget>[
                    ContentText(
                      stimulus!.title!,
                      style: context.text.labelLarge?.copyWith(color: context.scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                  ],
                  ContentText(stimulus!.text, style: _reading(stimulus!.text)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

enum AnswerState { draft, queued, submitted }

/// One honest line about where the current answer lives.
class AnswerStatusLine extends StatelessWidget {
  const AnswerStatusLine({super.key, required this.state});

  final AnswerState state;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semantics;
    final (IconData icon, String label, Color color) = switch (state) {
      AnswerState.draft => (Icons.edit_note_rounded, context.l10n.savedOnDevice, colors.info),
      AnswerState.queued => (Icons.cloud_off_rounded, context.l10n.waitingToSend, colors.warning),
      AnswerState.submitted => (Icons.check_circle_outline_rounded, context.l10n.answerSubmitted, colors.success),
    };
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(label, style: context.text.bodySmall?.copyWith(color: color)),
        ),
      ],
    );
  }
}

/// Resolves a revealed key into the words a student can learn from: option
/// letters become their full text, blanks become per-blank answers and grids
/// become row.column lines.
String answerKeyLabel(BuildContext context, Question question, Object? rawKey, List<String> letters) {
  String optionTextOf(Object? value) {
    final String token = value?.toString().trim() ?? '';
    final int index = letters.indexOf(token);
    return index >= 0 && index < question.options.length ? question.options[index] : token;
  }

  String joined(Object? value) => value is List
      ? value.map(optionTextOf).where((String item) => item.isNotEmpty).join(' · ')
      : optionTextOf(value);

  if (question.type == 'true_false') {
    final bool? flag = rawKey is bool
        ? rawKey
        : switch (rawKey?.toString().toLowerCase()) {
            'true' => true,
            'false' => false,
            _ => null,
          };
    return flag == null ? '${rawKey ?? ''}' : (flag ? context.l10n.trueLabel : context.l10n.falseLabel);
  }
  if (question.type == 'mcq' || question.type == 'matching_item') return optionTextOf(rawKey);
  if (question.type == 'ordering') return joined(rawKey);
  if (question.type == 'multi_select') {
    final Iterable<String> tokens =
        rawKey is List ? rawKey.map((Object? item) => item.toString()) : '${rawKey ?? ''}'.split('||');
    return tokens.map(optionTextOf).where((String item) => item.isNotEmpty).join(' · ');
  }
  if (question.type == 'fill_blank' || question.type == 'language_analysis') {
    if (rawKey is List) {
      return rawKey.asMap().entries.map((MapEntry<int, Object?> entry) {
        final Object? blank = entry.value;
        final String text = blank is List
            ? blank.map((Object? item) => item.toString()).where((String item) => item.isNotEmpty).join(' / ')
            : '${blank ?? ''}';
        return '${context.fmt.integer(entry.key + 1)}. $text';
      }).join('\n');
    }
    return '${rawKey ?? ''}';
  }
  if (question.type == 'table_fill' && rawKey is Map) {
    return rawKey.entries
        .map(
          (MapEntry<Object?, Object?> entry) =>
              '${entry.key} = ${entry.value is List ? (entry.value as List).join(' / ') : entry.value}',
        )
        .join('\n');
  }
  if ((question.type == 'matrix_input' || question.type == 'truth_table') && rawKey is List) {
    return rawKey.map((Object? row) => row is List ? row.join(' | ') : '$row').join('\n');
  }
  return rawKey is bool ? (rawKey ? 'true' : 'false') : '${rawKey ?? ''}';
}

class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.feedback,
    required this.totalMarks,
    required this.question,
    required this.letters,
  });

  final AnswerFeedback feedback;
  final double totalMarks;
  final Question question;
  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semantics;
    final CreditStatus status = feedback.creditStatus(totalMarks);
    final (String label, Color color, Color background, IconData icon) = switch (status) {
      CreditStatus.pending => (
          feedback.markingStatus == MarkingStatus.pendingAi ? context.l10n.pendingAi : context.l10n.pendingSelf,
          colors.info,
          colors.infoContainer,
          Icons.hourglass_bottom_rounded,
        ),
      CreditStatus.full => (context.l10n.correct, colors.success, colors.successContainer, Icons.check_circle_outline),
      CreditStatus.partial => (
          context.l10n.partlyCorrect(
            context.fmt.marks(feedback.awardedMarks ?? 0),
            context.fmt.marks(totalMarks),
          ),
          colors.warning,
          colors.warningContainer,
          Icons.donut_large_rounded,
        ),
      CreditStatus.zero => (context.l10n.incorrect, context.scheme.error, context.scheme.errorContainer, Icons.cancel_outlined),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: context.text.titleSmall?.copyWith(color: color, height: 1.4),
                ),
              ),
            ],
          ),
          if (feedback.pending)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 28, top: AppSpacing.xxs),
              child: Text(
                feedback.awardedMarks == null
                    ? context.l10n.marksAwarded('—')
                    : context.l10n.marksAwarded(context.fmt.marks(feedback.awardedMarks!)),
                style: context.text.labelMedium?.copyWith(color: color),
              ),
            ),
          if (feedback.explanation != null && feedback.explanation!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.explanation, style: context.text.labelLarge),
            const SizedBox(height: 2),
            ContentText(feedback.explanation!.trim(), style: context.text.bodyMedium?.copyWith(height: 1.6)),
          ],
          if (feedback.keyRevealed) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.answerKey, style: context.text.labelLarge),
            const SizedBox(height: 2),
            ContentText(
              answerKeyLabel(context, question, feedback.key, letters),
              style: AppTheme.reading(scale: 0.85),
            ),
          ],
          if (feedback.modelAnswer != null && feedback.modelAnswer!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.modelAnswer, style: context.text.labelLarge),
            const SizedBox(height: 2),
            ContentText(feedback.modelAnswer!.trim(), style: AppTheme.reading(scale: 0.85)),
          ],
        ],
      ),
    );
  }
}

/// A server-side record without a fresh feedback payload. Pending self-marked
/// answers reveal the model answer and resolve via the server self-mark route.
class MarkedOnlyPanel extends StatefulWidget {
  const MarkedOnlyPanel({
    super.key,
    required this.record,
    required this.totalMarks,
    required this.attemptId,
    required this.onUpdated,
  });

  final AnswerRecord record;
  final double totalMarks;
  final String attemptId;
  final ValueChanged<AnswerRecord> onUpdated;

  @override
  State<MarkedOnlyPanel> createState() => _MarkedOnlyPanelState();
}

class _MarkedOnlyPanelState extends State<MarkedOnlyPanel> {
  bool _busy = false;

  Future<void> _selfMark(double marks) async {
    setState(() => _busy = true);
    try {
      final SelfMarkResult result = await context.services.practiceRepository.selfMark(widget.record.id, marks);
      if (!mounted) return;
      widget.onUpdated(result.answer.copyWith(
        modelAnswer: result.feedback.modelAnswer ?? widget.record.modelAnswer,
        key: result.feedback.key ?? widget.record.key,
        explanation: result.feedback.explanation ?? widget.record.explanation,
      ));
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semantics;
    final AnswerRecord record = widget.record;

    if (record.markingStatus == MarkingStatus.pendingSelf) {
      final String? model = record.modelAnswer?.trim();
      final double half = (widget.totalMarks / 2 * 2).roundToDouble() / 2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(context.l10n.selfMarkTitle, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.selfMarkHint,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.5),
          ),
          if (model != null && model.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.modelAnswer, style: context.text.labelLarge),
            const SizedBox(height: 2),
            ContentText(model, style: AppTheme.reading(scale: 0.85)),
          ],
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: context.l10n.selfMarkGotIt,
            isLoading: _busy,
            onPressed: _busy ? null : () => _selfMark(widget.totalMarks),
          ),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: context.l10n.selfMarkPartial,
            onPressed: _busy ? null : () => _selfMark(half),
          ),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: context.l10n.selfMarkMissed,
            onPressed: _busy ? null : () => _selfMark(0),
          ),
        ],
      );
    }

    final (String label, Color color) = switch (record.creditStatus(widget.totalMarks)) {
      CreditStatus.pending => (
          record.markingStatus == MarkingStatus.pendingAi ? context.l10n.pendingAi : context.l10n.pendingSelf,
          colors.info,
        ),
      CreditStatus.full => (context.l10n.correct, colors.success),
      CreditStatus.partial => (
          context.l10n.partlyCorrect(
            context.fmt.marks(record.awardedMarks ?? 0),
            context.fmt.marks(widget.totalMarks),
          ),
          colors.warning,
        ),
      CreditStatus.zero => (context.l10n.incorrect, context.scheme.error),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: context.text.bodySmall?.copyWith(color: color, height: 1.5)),
        if (record.awardedMarks != null)
          Text(
            context.l10n.marksAwarded(context.fmt.marks(record.awardedMarks!)),
            style: context.text.labelSmall?.copyWith(color: color),
          ),
        if (record.aiMarked && (record.aiFeedback?.trim().isNotEmpty ?? false)) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            record.aiFeedback!.trim(),
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.6),
          ),
        ],
      ],
    );
  }
}
