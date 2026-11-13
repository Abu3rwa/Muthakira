/// One exam row, used by home and the catalogue.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/labels.dart';
import '../../../shared/widgets/content_text.dart';
import '../domain/exam_models.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({super.key, required this.exam, required this.onTap, this.trailing});

  final ExamSummary exam;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SemanticColors colors = context.semantics;
    final String facts = <String>[
      context.l10n.questionCount(exam.leafQuestionCount),
      context.l10n.totalMarks(context.fmt.marks(exam.totalMarks)),
      if (exam.durationMinutes > 0) context.l10n.durationMinutes(exam.durationMinutes),
    ].join(' · ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ContentText(
                      exam.subject,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                    ),
                  ),
                  if (trailing != null) ...<Widget>[const SizedBox(width: AppSpacing.xs), trailing!],
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              ContentText(
                '${exam.session} ${exam.examYear}',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              ContentText(
                classLabel(context, exam.classLevel) ?? exam.classLevel,
                style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                facts,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: <Widget>[
                  _CostLabel(exam: exam, colors: colors),
                  const Spacer(),
                  Text(
                    context.l10n.viewPaper,
                    style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_left_rounded, size: 20, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostLabel extends StatelessWidget {
  const _CostLabel({required this.exam, required this.colors});

  final ExamSummary exam;
  final SemanticColors colors;

  @override
  Widget build(BuildContext context) {
    final String label = exam.isFree
        ? context.l10n.free
        : context.l10n.creditsCount(exam.unlockCost ?? 0);
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: exam.isFree ? colors.success : colors.credit,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
