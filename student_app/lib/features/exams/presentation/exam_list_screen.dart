/// Catalogue tab: search, filters, pagination.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/preset_picker.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../domain/exam_models.dart';
import '../domain/exam_repository.dart';
import 'exam_card.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final TextEditingController _search = TextEditingController();
  ExamFilter _filter = const ExamFilter();
  CatalogueValues _catalogue = const CatalogueValues();
  List<ExamSummary> _items = const <ExamSummary>[];
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  AppFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
    _loadCatalogue();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogue() async {
    try {
      final CatalogueValues values = await context.services.examRepository.catalogue();
      if (mounted) setState(() => _catalogue = values);
    } on AppFailure {
      // Filters simply stay limited to "all" when the catalogue is unavailable.
    }
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || _items.length >= _total)) return;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _failure = null;
      }
    });
    try {
      final ExamPage page = await context.services.examRepository.list(
        _filter,
        skip: more ? _items.length : 0,
      );
      if (!mounted) return;
      setState(() {
        _items = more ? <ExamSummary>[..._items, ...page.items] : page.items;
        _total = page.total;
        _loading = false;
        _loadingMore = false;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _failure = failure;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _openFilters() async {
    final ExamFilter? next = await showModalBottomSheet<ExamFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => _FilterSheet(filter: _filter, catalogue: _catalogue),
    );
    if (next == null || !mounted) return;
    setState(() => _filter = next);
    await _load();
  }

  List<ExamSummary> get _visible {
    final String query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items
        .where((ExamSummary exam) =>
            exam.subject.toLowerCase().contains(query) ||
            exam.session.toLowerCase().contains(query) ||
            exam.classLevel.toLowerCase().contains(query) ||
            exam.examYear.toString() == query)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<ExamSummary> visible = _visible;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.examsTitle),
        actions: <Widget>[
          IconButton(onPressed: _openFilters, icon: const Icon(Icons.tune_rounded), tooltip: context.l10n.filters),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.gutterOf(context),
              0,
              AppSpacing.gutterOf(context),
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.searchExams,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(visible),
    );
  }

  Widget _buildBody(List<ExamSummary> visible) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failure != null) {
      return ErrorView(failure: _failure!, onRetry: _load);
    }
    if (visible.isEmpty) {
      return EmptyView(
        title: context.l10n.noExams,
        message: context.l10n.noExamsHint,
        icon: Icons.menu_book_outlined,
        action: _filter.isEmpty
            ? null
            : PrimaryButton(
                label: context.l10n.clearFilters,
                expanded: false,
                onPressed: () {
                  setState(() => _filter = const ExamFilter());
                  _load();
                },
              ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          AppSpacing.sm,
          AppSpacing.gutterOf(context),
          AppSpacing.xl,
        ),
        children: <Widget>[
          if (!_filter.isEmpty) ...<Widget>[
            _ActiveFilters(
              filter: _filter,
              onChanged: (ExamFilter next) {
                setState(() => _filter = next);
                _load();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          for (final ExamSummary exam in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ExamCard(exam: exam, onTap: () => context.push(Routes.exam(exam.id))),
            ),
          if (_items.length < _total)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: PrimaryButton(
                label: context.l10n.seeAll,
                isLoading: _loadingMore,
                onPressed: _loadingMore ? null : () => _load(more: true),
              ),
            ),
        ],
      ),
    );
  }
}

/// The active filters, visible above the list so students never wonder why a
/// paper is missing. Removing a chip reloads the first page.
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.filter, required this.onChanged});

  final ExamFilter filter;
  final ValueChanged<ExamFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<(String, ExamFilter)> chips = <(String, ExamFilter)>[
      if (filter.subject != null)
        (filter.subject!, filter.copyWith(clearSubject: true)),
      if (filter.session != null)
        (filter.session!, filter.copyWith(clearSession: true)),
      if (filter.examYear != null)
        ('${filter.examYear}', filter.copyWith(clearYear: true)),
    ];
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xxs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final (String label, ExamFilter next) in chips)
          InputChip(
            label: Text(label),
            onDeleted: () => onChanged(next),
            deleteIcon: const Icon(Icons.close_rounded, size: 18),
          ),
        TextButton(
          onPressed: () => onChanged(const ExamFilter()),
          child: Text(context.l10n.clearFilters),
        ),
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.filter, required this.catalogue});

  final ExamFilter filter;
  final CatalogueValues catalogue;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ExamFilter _draft = widget.filter;

  @override
  Widget build(BuildContext context) {
    final List<ChoiceOption> subjects = <ChoiceOption>[
      for (final String subject in widget.catalogue.subjects) ChoiceOption(value: subject, label: subject),
    ];
    final List<ChoiceOption> sessions = <ChoiceOption>[
      for (final String session in widget.catalogue.sessions) ChoiceOption(value: session, label: session),
    ];
    final List<ChoiceOption> years = <ChoiceOption>[
      for (final int year in widget.catalogue.years) ChoiceOption(value: '$year', label: '$year'),
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          0,
          AppSpacing.gutterOf(context),
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(context.l10n.filters, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              if (subjects.isNotEmpty)
                PresetPicker(
                  label: context.l10n.subject,
                  noneLabel: context.l10n.allSubjects,
                  initialValue: _draft.subject,
                  options: subjects,
                  onChanged: (String? value) =>
                      setState(() => _draft = _draft.copyWith(subject: value, clearSubject: value == null)),
                ),
              if (sessions.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                PresetPicker(
                  label: context.l10n.session,
                  noneLabel: context.l10n.allSessions,
                  initialValue: _draft.session,
                  options: sessions,
                  onChanged: (String? value) =>
                      setState(() => _draft = _draft.copyWith(session: value, clearSession: value == null)),
                ),
              ],
              if (years.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                PresetPicker(
                  label: context.l10n.year,
                  noneLabel: context.l10n.allYears,
                  initialValue: _draft.examYear?.toString(),
                  options: years,
                  onChanged: (String? value) => setState(
                    () => _draft = _draft.copyWith(
                      examYear: value == null ? null : int.tryParse(value),
                      clearYear: value == null,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SecondaryButton(
                      label: context.l10n.clearFilters,
                      onPressed: () {
                        setState(() => _draft = const ExamFilter());
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: context.l10n.apply,
                      onPressed: () => Navigator.of(context).pop(_draft),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
