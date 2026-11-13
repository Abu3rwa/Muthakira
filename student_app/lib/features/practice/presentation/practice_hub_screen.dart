/// Practice tab: the papers this student has unlocked, ready to open.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/exam_repository.dart';
import '../../exams/presentation/exam_card.dart';

class _HubData {
  const _HubData({required this.papers, this.failed = 0});

  final List<ExamSummary> papers;
  final int failed;
}

class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  static const int _pageSize = 8;

  late Future<_HubData> _future = _load();
  int _visible = _pageSize;

  Future<_HubData> _load() async {
    final ExamRepository repository = context.services.examRepository;
    final List<UnlockedExam> unlocks = await repository.myUnlocks();
    final List<ExamSummary> papers = <ExamSummary>[];
    int failed = 0;
    for (final UnlockedExam unlock in unlocks) {
      try {
        papers.add((await repository.detail(unlock.examId)).summary);
      } on AppFailure {
        failed += 1;
      }
    }
    return _HubData(papers: papers, failed: failed);
  }

  void _reload() {
    setState(() {
      _future = _load();
      _visible = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.practiceTitle)),
      body: FutureBuilder<_HubData>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<_HubData> snapshot) {
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
          final _HubData data = snapshot.data ?? const _HubData(papers: <ExamSummary>[]);
          final List<ExamSummary> shown = data.papers.take(_visible).toList();
          final bool hasMore = data.papers.length > shown.length;
          final bool empty = data.papers.isEmpty && data.failed == 0;
          final double gutter = AppSpacing.gutterOf(context);
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
              children: <Widget>[
                if (data.failed > 0) ...<Widget>[
                  _PartialLoadNotice(failed: data.failed, onRetry: _reload),
                  const SizedBox(height: AppSpacing.md),
                ],
                _EntryCard(
                  title: context.l10n.adaptivePractice,
                  body: context.l10n.adaptiveEntryHint,
                  icon: Icons.insights_outlined,
                  onTap: () => context.push<void>(Routes.adaptive),
                ),
                const SizedBox(height: AppSpacing.xs),
                _EntryCard(
                  title: context.l10n.myMaterials,
                  body: context.l10n.materialsEntryHint,
                  icon: Icons.auto_awesome_mosaic_outlined,
                  onTap: () => context.push<void>(Routes.materials),
                ),
                const SizedBox(height: AppSpacing.md),
                if (empty)
                  EmptyView(
                    title: context.l10n.emptyPractice,
                    message: context.l10n.emptyPracticeHint,
                    icon: Icons.edit_note_rounded,
                    action: PrimaryButton(
                      label: context.l10n.browseExams,
                      icon: Icons.menu_book_rounded,
                      onPressed: () => context.go(Routes.exams),
                      expanded: false,
                    ),
                  )
                else ...<Widget>[
                  Text(context.l10n.yourOpenPapers, style: context.text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  for (final ExamSummary exam in shown)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ExamCard(
                        exam: exam,
                        onTap: () => context.push(Routes.exam(exam.id)),
                      ),
                    ),
                  if (hasMore) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryButton(label: context.l10n.showMore, onPressed: () => setState(() => _visible += _pageSize)),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.title, required this.body, required this.icon, required this.onTap});

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Icon(icon, color: context.scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: context.text.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: context.text.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_left_rounded, color: context.scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartialLoadNotice extends StatelessWidget {
  const _PartialLoadNotice({required this.failed, required this.onRetry});

  final int failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 20, color: context.scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              context.l10n.partialPapersFailed(failed),
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
