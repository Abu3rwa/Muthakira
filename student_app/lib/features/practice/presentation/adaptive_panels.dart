/// Small adaptive-practice surfaces: progress and the no-more-questions state.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/tokens.dart';

class AdaptiveHeader extends StatelessWidget {
  const AdaptiveHeader({super.key, required this.asked, required this.remaining});

  final int asked;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            context.l10n.answeredCount(asked),
            style: context.text.labelLarge,
          ),
        ),
        Text(
          context.l10n.adaptiveRemaining(remaining),
          style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// The server returned no next question: say why and what genuinely works.
class AdaptiveTerminal extends StatelessWidget {
  const AdaptiveTerminal({super.key, required this.exhausted, required this.onFinish});

  final bool exhausted;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterOf(context),
        AppSpacing.xl,
        AppSpacing.gutterOf(context),
        AppSpacing.xl,
      ),
      children: <Widget>[
        Icon(
          exhausted ? Icons.task_alt_rounded : Icons.lock_outline_rounded,
          size: 52,
          color: context.scheme.outline,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.adaptiveNoQuestions,
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          exhausted ? context.l10n.adaptiveExhausted : context.l10n.adaptiveNoAccess,
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextButton(
          onPressed: () => context.go(Routes.exams),
          child: Text(context.l10n.browseExams),
        ),
        TextButton(
          onPressed: onFinish,
          child: Text(context.l10n.finishPractice),
        ),
      ],
    );
  }
}
