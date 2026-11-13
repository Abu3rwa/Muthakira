/// Explicit, opt-in AI marking for one submitted open-ended answer.
///
/// Marks and the fee always come from the server. The panel never guesses a
/// price and never marks anything automatically. It stays mounted for every
/// ai_rubric state (pending, in flight, in review, marked, rejected, voided)
/// so paid feedback never disappears when the status flips to marked.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/error_codes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../domain/practice_models.dart';

class AiGradePanel extends StatefulWidget {
  const AiGradePanel({
    super.key,
    required this.attemptId,
    required this.record,
    required this.totalMarks,
    this.onUpdated,
  });

  final String attemptId;
  final AnswerRecord record;
  final double totalMarks;
  final ValueChanged<AnswerRecord>? onUpdated;

  @override
  State<AiGradePanel> createState() => _AiGradePanelState();
}

class _AiGradePanelState extends State<AiGradePanel> {
  bool _busy = false;
  AppFailure? _failure;
  AiGradeOutcome? _outcome;

  bool get _reviewPending =>
      widget.record.aiReview?.isPending == true || _outcome?.awaitingReview == true;

  bool get _eligible =>
      widget.record.markingStatus == MarkingStatus.pendingAi &&
      !_reviewPending &&
      !widget.record.aiInflight &&
      !_busy &&
      _outcome == null;

  @override
  void didUpdateWidget(covariant AiGradePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record != widget.record) {
      _failure = null;
      // Once the parent holds the server truth, render from the record so the
      // feedback survives rebuilds instead of living only in panel state.
      if (widget.record.aiMarked || widget.record.aiReview != null) _outcome = null;
    }
  }

  Future<void> _request() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(dialogContext.l10n.aiGradeConfirmTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(dialogContext.l10n.aiGradeBody),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  dialogContext.l10n.aiGradeCostNote,
                  style: dialogContext.text.bodySmall?.copyWith(
                    color: dialogContext.scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dialogContext.l10n.aiGradeUnofficial,
                  style: dialogContext.text.labelMedium?.copyWith(
                    color: dialogContext.semantics.warning,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dialogContext.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(dialogContext.l10n.aiGradeTitle),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final AiGradeOutcome outcome = await context.services.practiceRepository
          .aiGrade(widget.attemptId, widget.record.id);
      if (!mounted) return;
      setState(() => _outcome = outcome);
      widget.onUpdated?.call(_apply(outcome));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      // The server may have charged (or released) even when the response was
      // lost, so the balance is re-read after every attempt, never assumed.
      if (mounted) await context.refreshWalletAfterAi();
      if (mounted) setState(() => _busy = false);
    }
  }

  AnswerRecord _apply(AiGradeOutcome outcome) => AnswerRecord(
    id: widget.record.id,
    questionId: widget.record.questionId,
    markingStatus: outcome.awaitingReview ? MarkingStatus.pendingAi : MarkingStatus.marked,
    correct: outcome.correct,
    awardedMarks: outcome.awardedMarks,
    attemptsCount: widget.record.attemptsCount,
    answeredAt: widget.record.answeredAt,
    answer: widget.record.answer,
    markingMethod: 'ai_rubric',
    aiFeedback: outcome.feedback,
    missingPoints: outcome.missingPoints,
    aiReview: outcome.review,
  );

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Note(
            icon: Icons.hourglass_top_rounded,
            color: context.semantics.info,
            title: context.l10n.aiGradeInProgress,
            body: context.l10n.aiGradeInProgressHint,
          ),
          const SizedBox(height: AppSpacing.xs),
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill)),
            child: LinearProgressIndicator(minHeight: 4),
          ),
        ],
      );
    }
    if (_reviewPending) {
      final int charged = _outcome?.creditsCharged ?? 0;
      return _Note(
        icon: Icons.fact_check_outlined,
        color: context.semantics.info,
        title: context.l10n.aiGradeReviewPending,
        body: context.l10n.aiGradeReviewBody,
        extra: charged > 0 ? context.l10n.aiGradeCharged(charged) : context.l10n.aiGradeReviewNoCharge,
      );
    }
    if (_outcome != null) {
      return _Note(
        icon: Icons.auto_awesome_outlined,
        color: context.semantics.info,
        title: context.l10n.aiGradeUnofficial,
        body: _outcome!.feedback ?? '',
        extra: _outcome!.creditsCharged > 0
            ? context.l10n.aiGradeCharged(_outcome!.creditsCharged)
            : (_outcome!.replayed ? context.l10n.aiGradeRecovered : null),
        marks: _marksLine(_outcome!.awardedMarks),
        missingPoints: _outcome!.missingPoints,
      );
    }
    final String? stored = widget.record.aiFeedback;
    if (widget.record.aiMarked && stored != null && stored.trim().isNotEmpty) {
      return _Note(
        icon: Icons.auto_awesome_outlined,
        color: context.semantics.info,
        title: context.l10n.aiGradeUnofficial,
        body: stored,
        marks: _marksLine(widget.record.awardedMarks),
        missingPoints: widget.record.missingPoints,
      );
    }
    if (widget.record.aiInflight) {
      return _Note(
        icon: Icons.hourglass_top_rounded,
        color: context.semantics.info,
        title: context.l10n.aiGradeInProgress,
        body: context.l10n.aiGradeInProgressHint,
      );
    }
    if (!_eligible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.record.reviewRejected) ...<Widget>[
          _Note(
            icon: Icons.undo_rounded,
            color: context.semantics.warning,
            title: context.l10n.aiGradeRejectedTitle,
            body: context.l10n.aiGradeRejectedBody,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (widget.record.reviewVoided) ...<Widget>[
          _Note(
            icon: Icons.edit_note_rounded,
            color: context.semantics.warning,
            title: context.l10n.aiGradeVoidedTitle,
            body: context.l10n.aiGradeVoidedBody,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SecondaryButton(
          label: context.l10n.aiGradeTitle,
          icon: Icons.auto_awesome_outlined,
          isLoading: _busy,
          onPressed: _busy ? null : _request,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.l10n.aiGradeCostNote,
          style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
        ),
        if (_failure != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _failureMessage(_failure!),
            style: context.text.bodySmall?.copyWith(color: context.scheme.error),
          ),
          if (_failure!.code == ErrorCodes.insufficientCredits)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => context.push<void>(Routes.packages),
                child: Text(context.l10n.addCredit),
              ),
            ),
        ],
      ],
    );
  }

  String? _marksLine(double? awarded) {
    if (awarded == null) return null;
    if (awarded >= widget.totalMarks) return context.l10n.marksAwarded(context.fmt.marks(awarded));
    return context.l10n.partlyCorrect(
      context.fmt.marks(awarded),
      context.fmt.marks(widget.totalMarks),
    );
  }

  String _failureMessage(AppFailure failure) {
    if (failure.isTimeout) return context.l10n.aiGradeTimeoutHint;
    return switch (failure.code) {
      ErrorCodes.insufficientCredits => context.l10n.errorInsufficientCredits,
      ErrorCodes.aiInFlight => context.l10n.errorAiInFlight,
      ErrorCodes.aiDisabled ||
      ErrorCodes.aiNotConfigured ||
      ErrorCodes.aiBudgetExceeded ||
      ErrorCodes.aiInvalidOutput ||
      ErrorCodes.aiUpstreamError ||
      ErrorCodes.aiTimeout => failureMessage(context.l10n, failure),
      _ => context.l10n.aiGradeFailed,
    };
  }
}

class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.extra,
    this.marks,
    this.missingPoints = const <String>[],
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String? extra;
  final String? marks;
  final List<String> missingPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.semantics.infoContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(title, style: context.text.titleSmall?.copyWith(color: color, height: 1.4)),
              ),
            ],
          ),
          if (body.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            ContentText(body.trim(), style: context.text.bodyMedium?.copyWith(height: 1.6)),
          ],
          if (marks != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(marks!, style: context.text.labelMedium?.copyWith(color: color)),
          ],
          if (missingPoints.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.aiGradeMissingPoints, style: context.text.labelLarge),
            for (final String point in missingPoints)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: ContentText('• $point', style: context.text.bodySmall),
              ),
          ],
          if (extra != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(extra!, style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}