/// Model answers for an unlocked paper, in paper order.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/states.dart';
import '../domain/exam_models.dart';
import '../domain/question_tree.dart';

String _formatKey(Object? key) {
  return switch (key) {
    null => '—',
    final String value => value,
    final bool value => value ? '✓' : '✗',
    final num value => value.toString(),
    final List<Object?> value => value.map((Object? item) => item?.toString() ?? '').join(' · '),
    final Map<Object?, Object?> value =>
      value.entries.map((MapEntry<Object?, Object?> entry) => '${entry.key}: ${entry.value}').join('\n'),
    _ => key.toString(),
  };
}

class AnswerKeysScreen extends StatefulWidget {
  const AnswerKeysScreen({super.key, required this.examId});

  final String examId;

  @override
  State<AnswerKeysScreen> createState() => _AnswerKeysScreenState();
}

class _AnswerKeysScreenState extends State<AnswerKeysScreen> {
  late Future<Map<String, AnswerKeyItem>> _keys = context.services.examRepository.keys(widget.examId);

  void _reload() => setState(() => _keys = context.services.examRepository.keys(widget.examId));

  static bool _hasContent(AnswerKeyItem item) =>
      item.key != null ||
      (item.modelAnswer?.trim().isNotEmpty ?? false) ||
      (item.explanation?.trim().isNotEmpty ?? false) ||
      item.criteria.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, AnswerKeyItem>>(
      future: _keys,
      builder: (BuildContext context, AsyncSnapshot<Map<String, AnswerKeyItem>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppPage(title: context.l10n.viewKeys, child: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final Object error = snapshot.error!;
          return AppPage(
            title: context.l10n.viewKeys,
            child: ErrorView(failure: error is AppFailure ? error : const AppFailure.network(), onRetry: _reload),
          );
        }
        final List<AnswerKeyItem> items = (snapshot.data?.values.toList(growable: false) ?? const <AnswerKeyItem>[])
            .where(_hasContent)
            .toList()
          ..sort((AnswerKeyItem a, AnswerKeyItem b) => QuestionTree.comparePaths(a.path, b.path));
        if (items.isEmpty) {
          return AppPage(
            title: context.l10n.viewKeys,
            child: EmptyView(
              title: context.l10n.emptyTitle,
              message: context.l10n.keyUnavailable,
              icon: Icons.key_outlined,
            ),
          );
        }
        final double gutter = AppSpacing.gutterOf(context);
        return AppPage(
          title: context.l10n.viewKeys,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) => _KeyBlock(item: items[index]),
          ),
        );
      },
    );
  }
}

class _KeyBlock extends StatelessWidget {
  const _KeyBlock({required this.item});

  final AnswerKeyItem item;

  @override
  Widget build(BuildContext context) {
    final String? model = item.modelAnswer?.trim();
    final String? explanation = item.explanation?.trim();
    final bool hasKey = item.key != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: context.scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(item.path, style: context.text.labelSmall),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  context.l10n.answerKey,
                  style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (hasKey)
            ContentText(_formatKey(item.key), style: AppTheme.reading())
          else if (model == null)
            Text(
              context.l10n.keyUnavailable,
              style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          if (explanation != null && explanation.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.explanation, style: context.text.labelLarge),
            const SizedBox(height: 2),
            ContentText(explanation, style: context.text.bodyMedium?.copyWith(height: 1.6)),
          ],
          if (model != null && model.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.modelAnswer, style: context.text.labelLarge),
            const SizedBox(height: 2),
            ContentText(model, style: AppTheme.reading()),
          ],
          if (item.criteria.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.criteria, style: context.text.labelLarge),
            const SizedBox(height: 2),
            for (final String criterion in item.criteria)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('• ', style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant)),
                    Expanded(
                      child: ContentText(criterion, style: context.text.bodyMedium?.copyWith(height: 1.5)),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: context.scheme.outlineVariant),
        ],
      ),
    );
  }
}
