/// Read-only paper: every question in order, no answers.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/content_text.dart';
import '../../../shared/widgets/states.dart';
import '../domain/exam_models.dart';
import '../domain/question_tree.dart';

class PaperViewerScreen extends StatefulWidget {
  const PaperViewerScreen({super.key, required this.examId});

  final String examId;

  @override
  State<PaperViewerScreen> createState() => _PaperViewerScreenState();
}

class _PaperViewerScreenState extends State<PaperViewerScreen> {
  late Future<ExamDetail> _detail = context.services.examRepository.detail(widget.examId);
  final ScrollController _scroll = ScrollController();
  List<GlobalKey> _anchors = const <GlobalKey>[];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _detail = context.services.examRepository.detail(widget.examId);
      _anchors = const <GlobalKey>[];
    });
  }

  Future<void> _openContents(List<PracticeEntry> entries) async {
    final int? index = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => _ContentsSheet(
        entries: entries,
        onSelected: (int value) => Navigator.of(sheetContext).pop(value),
      ),
    );
    if (index != null) _jumpTo(index);
  }

  void _jumpTo(int index) {
    if (!_scroll.hasClients || index < 0 || index >= _anchors.length) return;
    final BuildContext? anchor = _anchors[index].currentContext;
    if (anchor != null) {
      Scrollable.ensureVisible(anchor, duration: const Duration(milliseconds: 280), alignment: 0.05);
      return;
    }
    final ScrollPosition position = _scroll.position;
    final double estimate =
        position.maxScrollExtent * (index / math.max(1, _anchors.length - 1));
    _scroll.jumpTo(estimate.clamp(position.minScrollExtent, position.maxScrollExtent));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? nearby = _anchors[index].currentContext;
      if (nearby != null) {
        Scrollable.ensureVisible(nearby, duration: const Duration(milliseconds: 220), alignment: 0.05);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExamDetail>(
      future: _detail,
      builder: (BuildContext context, AsyncSnapshot<ExamDetail> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppPage(title: context.l10n.paperViewer, child: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          final Object error = snapshot.error!;
          return AppPage(
            title: context.l10n.paperViewer,
            child: ErrorView(failure: error is AppFailure ? error : const AppFailure.network(), onRetry: _reload),
          );
        }
        final ExamDetail detail = snapshot.data!;
        final List<PracticeEntry> entries = QuestionTree.flatten(detail);
        if (_anchors.length != entries.length) {
          _anchors = List<GlobalKey>.generate(entries.length, (_) => GlobalKey());
        }
        if (entries.isEmpty) {
          return AppPage(
            title: detail.summary.subject,
            child: EmptyView(
              title: context.l10n.emptyTitle,
              message: context.l10n.questionCount(0),
              icon: Icons.menu_book_rounded,
            ),
          );
        }
        final bool isEnglish = detail.summary.language == 'en';
        final List<String> letters = isEnglish ? AppConstants.englishLetters : AppConstants.arabicLetters;
        final double gutter = AppSpacing.gutterOf(context);
        return AppPage(
          title: detail.summary.subject,
          actions: <Widget>[
            IconButton(
              onPressed: () => _openContents(entries),
              icon: const Icon(Icons.toc_rounded),
              tooltip: context.l10n.paperContents,
            ),
          ],
          child: Directionality(
            textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
            child: ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
              itemCount: entries.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) return _PaperHeader(detail: detail, leafCount: entries.length);
                final int position = index - 1;
                return _PaperQuestion(
                  key: _anchors[position],
                  entry: entries[position],
                  previous: position == 0 ? null : entries[position - 1],
                  letters: letters,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

TextStyle _reading(String text) => AppTheme.reading(
  scale: text.length > 600 ? AppType.readingSizeLong / AppType.readingSize : 1,
);

/// Naskh is reserved for passages and model answers, not question prompts.
TextStyle _prompt(BuildContext context) =>
    context.text.bodyLarge?.copyWith(height: 1.6, fontWeight: FontWeight.w500) ?? const TextStyle();

class _PaperHeader extends StatelessWidget {
  const _PaperHeader({required this.detail, required this.leafCount});

  final ExamDetail detail;
  final int leafCount;

  @override
  Widget build(BuildContext context) {
    final ExamSummary summary = detail.summary;
    final String facts = <String>[
      context.l10n.questionCount(leafCount),
      context.l10n.totalMarks(context.fmt.marks(summary.totalMarks)),
      if (summary.durationMinutes > 0) context.l10n.durationMinutes(summary.durationMinutes),
    ].join(' · ');
    final String? instructions = detail.instructions?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${summary.session} ${summary.examYear}',
          style: context.text.labelLarge?.copyWith(color: context.scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(summary.subject, style: context.text.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          <String>[summary.classLevel, if (summary.stream != null) summary.stream!].join(' · '),
          style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(facts, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant)),
        if (instructions != null && instructions.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: context.scheme.outlineVariant, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  context.l10n.instructions,
                  style: context.text.labelLarge?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xxs),
                ContentText(instructions, style: _reading(instructions)),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Divider(height: 1, color: context.scheme.outlineVariant),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _PaperQuestion extends StatelessWidget {
  const _PaperQuestion({super.key, required this.entry, this.previous, required this.letters});

  final PracticeEntry entry;
  final PracticeEntry? previous;
  final List<String> letters;

  bool get _newSection =>
      entry.sections.isNotEmpty &&
      (previous == null ||
          previous!.sections.isEmpty ||
          previous!.sections.last.id != entry.sections.last.id);

  bool get _newStimulus => entry.stimulus != null && previous?.stimulus?.id != entry.stimulus!.id;

  @override
  Widget build(BuildContext context) {
    final Question question = entry.question;
    final Stimulus? stimulus = entry.stimulus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_newSection)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  entry.sections.last.path,
                  style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                ContentText(entry.sections.last.text, style: context.text.titleSmall),
              ],
            ),
          ),
        if (_newStimulus && stimulus != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: context.scheme.outline, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (stimulus.title != null) ...<Widget>[
                    ContentText(
                      stimulus.title!,
                      style: context.text.labelLarge?.copyWith(color: context.scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                  ],
                  ContentText(stimulus.text, style: _reading(stimulus.text)),
                ],
              ),
            ),
          ),
        Padding(
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
                    child: Text(question.path, style: context.text.labelSmall),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      context.l10n.marksAwarded(context.fmt.marks(question.marks)),
                      style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ContentText(question.text, style: _prompt(context)),
              if (question.options.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                for (int option = 0; option < question.options.length; option++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${option < letters.length ? letters[option] : option + 1}.',
                            style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: ContentText(question.options[option], style: context.text.bodyLarge),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: context.scheme.outlineVariant),
      ],
    );
  }
}

class _ContentsSheet extends StatelessWidget {
  const _ContentsSheet({required this.entries, required this.onSelected});

  final List<PracticeEntry> entries;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
              child: Text(context.l10n.paperContents, style: context.text.titleLarge),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  final PracticeEntry entry = entries[index];
                  final bool newSection = index == 0 ||
                      entry.sections.isEmpty ||
                      entries[index - 1].sections.isEmpty ||
                      entries[index - 1].sections.last.id != entry.sections.last.id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (newSection && entry.sections.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.xxs,
                          ),
                          child: ContentText(
                            entry.sections.last.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleSmall,
                          ),
                        ),
                      ListTile(
                        onTap: () => onSelected(index),
                        leading: Container(
                          constraints: const BoxConstraints(minWidth: 36),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            entry.question.path,
                            textAlign: TextAlign.center,
                            style: context.text.labelSmall,
                          ),
                        ),
                        title: ContentText(
                          entry.question.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          context.l10n.marksAwarded(context.fmt.marks(entry.question.marks)),
                          style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
