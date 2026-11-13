/// Question navigator sheet: grouped targets, legend and finish.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../exams/domain/question_tree.dart';
import '../domain/practice_models.dart';

class QuestionNavigatorSheet extends StatelessWidget {
  const QuestionNavigatorSheet({
    super.key,
    required this.entries,
    required this.records,
    required this.queued,
    required this.currentIndex,
    required this.onSelect,
    required this.onFinish,
  });

  final List<PracticeEntry> entries;
  final Map<String, AnswerRecord> records;
  final Set<String> queued;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final List<_NavigatorGroup> groups = _group(entries);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
              child: Text(context.l10n.questionNavigator, style: context.text.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xxs,
                children: <Widget>[
                  _Legend(color: context.scheme.primary, label: context.l10n.currentLabel),
                  _Legend(color: context.scheme.primaryContainer, label: context.l10n.answeredLabel),
                  _Legend(color: context.semantics.infoContainer, label: context.l10n.pendingLabel),
                  _Legend(color: null, label: context.l10n.unansweredLabel),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  for (final _NavigatorGroup group in groups) ...<Widget>[
                    if (group.title != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xxs),
                        child: ContentText(
                          group.title!,
                          style: context.text.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        for (int index = group.start; index < group.start + group.count; index++)
                          _NavTarget(
                            number: index + 1,
                            current: index == currentIndex,
                            record: records[entries[index].question.id],
                            queued: queued.contains(entries[index].question.id),
                            onTap: () => onSelect(index),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: PrimaryButton(label: context.l10n.finishPractice, icon: Icons.flag_outlined, onPressed: onFinish),
            ),
          ],
        ),
      ),
    );
  }

  List<_NavigatorGroup> _group(List<PracticeEntry> list) {
    final List<_NavigatorGroup> groups = <_NavigatorGroup>[];
    for (int index = 0; index < list.length; index++) {
      final String? title = list[index].sections.isEmpty ? null : list[index].sections.last.text;
      if (groups.isEmpty || groups.last.title != title) {
        groups.add(_NavigatorGroup(title: title, start: index, count: 1));
      } else {
        final _NavigatorGroup last = groups.last;
        groups[groups.length - 1] = _NavigatorGroup(title: title, start: last.start, count: last.count + 1);
      }
    }
    return groups;
  }
}

class _NavigatorGroup {
  const _NavigatorGroup({required this.title, required this.start, required this.count});

  final String? title;
  final int start;
  final int count;
}

class _NavTarget extends StatelessWidget {
  const _NavTarget({
    required this.number,
    required this.current,
    required this.record,
    required this.queued,
    required this.onTap,
  });

  final int number;
  final bool current;
  final AnswerRecord? record;
  final bool queued;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semantics;
    final bool pending = record != null && record!.markingStatus != MarkingStatus.marked;
    final bool answered = record != null;
    final Color background = current
        ? context.scheme.primary
        : pending
        ? colors.infoContainer
        : answered
        ? context.scheme.primaryContainer
        : context.scheme.surfaceContainerLow;
    final Color foreground = current ? context.scheme.onPrimary : context.scheme.onSurface;
    final String status = queued
        ? context.l10n.waitingToSend
        : pending
        ? context.l10n.pendingLabel
        : answered
        ? context.l10n.answeredLabel
        : context.l10n.unansweredLabel;
    final String label = '${context.l10n.questionLabel('$number')}، $status'
        '${current ? '، ${context.l10n.currentLabel}' : ''}';
    return Semantics(
      label: label,
      button: true,
      selected: current,
      onTap: onTap,
      child: ExcludeSemantics(
        child: SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: background,
              foregroundColor: foreground,
              side: BorderSide(color: current ? context.scheme.primary : context.scheme.outlineVariant),
            ),
            child: Text(
              '$number',
              style: context.text.labelLarge?.copyWith(fontWeight: current ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color? color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant)),
      ],
    );
  }
}
