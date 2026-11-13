/// S28: pick a paper for server-selected adaptive practice.
///
/// Selection itself is free and deterministic; only paid questions need an
/// unlock, and the API accepts no topic or difficulty controls.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/grade_labels.dart';
import '../../../shared/widgets/states.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/exam_repository.dart';
import '../../exams/presentation/exam_card.dart';
import '../domain/practice_models.dart';

class AdaptiveSetupScreen extends StatefulWidget {
  const AdaptiveSetupScreen({super.key});

  @override
  State<AdaptiveSetupScreen> createState() => _AdaptiveSetupScreenState();
}

class _AdaptiveSetupScreenState extends State<AdaptiveSetupScreen> {
  late Future<List<ExamSummary>> _papers = _load();
  String? _subject;
  String? _startingId;

  Future<List<ExamSummary>> _load() async {
    final ExamPage page = await context.services.examRepository.list(
      const ExamFilter(),
      limit: Limits.cataloguePageSize,
    );
    return page.items.where((ExamSummary exam) => exam.practiceEnabled).toList(growable: false);
  }

  void _reload() => setState(() => _papers = _load());

  Future<void> _start(ExamSummary exam) async {
    setState(() => _startingId = exam.id);
    try {
      final StartAttemptResult result = await context.services.practiceRepository.start(exam.id);
      if (!mounted) return;
      await context.services.prefs.setLastAttempt(exam.id, result.attempt.id);
      if (!mounted) return;
      await context.push<void>(Routes.adaptiveSessionOf(result.attempt.id));
    } on AppFailure catch (failure) {
      if (mounted) context.snack(failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _startingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = AppSpacing.gutterOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adaptivePractice)),
      body: FutureBuilder<List<ExamSummary>>(
        future: _papers,
        builder: (BuildContext context, AsyncSnapshot<List<ExamSummary>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            return ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: _reload,
            );
          }
          final List<ExamSummary> papers = snapshot.data ?? const <ExamSummary>[];
          if (papers.isEmpty) {
            return EmptyView(
              title: context.l10n.emptyPractice,
              message: context.l10n.emptyPracticeHint,
              icon: Icons.edit_note_rounded,
              action: TextButton(
                onPressed: () => context.go(Routes.exams),
                child: Text(context.l10n.browseExams),
              ),
            );
          }
          final List<String> subjects = <String>[];
          for (final ExamSummary exam in papers) {
            if (!subjects.contains(exam.subject)) subjects.add(exam.subject);
          }
          final String? subject = _subject;
          final List<ExamSummary> shown = subject == null
              ? papers
              : papers.where((ExamSummary exam) => exam.subject == subject).toList(growable: false);
          return ListView(
            padding: EdgeInsets.fromLTRB(gutter, AppSpacing.md, gutter, AppSpacing.xl),
            children: <Widget>[
              _ContextCard(
                classLabel: gradeLabel(context.l10n, context.auth.profile?.classLevel),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(context.l10n.adaptivePickPaper, style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  ChoiceChip(
                    label: Text(context.l10n.all),
                    selected: subject == null,
                    onSelected: (_) => setState(() => _subject = null),
                  ),
                  for (final String name in subjects)
                    ChoiceChip(
                      label: Text(name),
                      selected: subject == name,
                      onSelected: (_) => setState(() => _subject = name),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final ExamSummary exam in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ExamCard(
                    exam: exam,
                    onTap: () {
                      if (_startingId == null) _start(exam);
                    },
                    trailing: _startingId == exam.id
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.classLabel});

  final String classLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: context.scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            context.l10n.adaptiveClassContext(classLabel),
            style: context.text.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.adaptiveEntryHint,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.6),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.adaptiveNoControls,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.6),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.adaptiveFreeNote,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.6),
          ),
        ],
      ),
    );
  }
}
