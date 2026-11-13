/// Landing tab: greeting, balance, study shortcuts and fresh papers.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/screen_state.dart';
import '../../../shared/labels.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/states.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/exam_repository.dart';
import '../../exams/presentation/exam_card.dart';
import '../../wallet/domain/entities.dart';
import '../../wallet/presentation/wallet_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ExamPage> _recent = _load();

  Future<ExamPage> _load() => context.services.examRepository.list(const ExamFilter(), limit: 6);

  void _reload() => setState(() => _recent = _load());

  @override
  Widget build(BuildContext context) {
    final String name = context.auth.user?.name ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.go(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.settingsTitle,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _reload();
          await context.walletController.refresh();
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterOf(context),
            AppSpacing.xs,
            AppSpacing.gutterOf(context),
            AppSpacing.xl,
          ),
          children: <Widget>[
            _Greeting(name: name.isEmpty ? context.l10n.appName : name),
            const SizedBox(height: AppSpacing.sm),
            _BalancePanel(onTopUp: () => context.push(Routes.packages)),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: context.l10n.browseExams,
              icon: Icons.menu_book_rounded,
              onPressed: () => context.go(Routes.exams),
            ),
            const SizedBox(height: AppSpacing.xs),
            HomeShortcuts(
              onPractice: () => context.go(Routes.practice),
              onPayments: () => context.push(Routes.payments),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: context.l10n.newPapers,
              action: TextButton(onPressed: () => context.go(Routes.exams), child: Text(context.l10n.seeAll)),
            ),
            FutureBuilder<ExamPage>(
              future: _recent,
              builder: (BuildContext context, AsyncSnapshot<ExamPage> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  final Object error = snapshot.error!;
                  return error is AppFailure
                      ? ErrorView(failure: error, onRetry: _reload, compact: true)
                      : ErrorView(failure: const AppFailure.network(), onRetry: _reload, compact: true);
                }
                final List<ExamSummary> items = snapshot.data?.items ?? const <ExamSummary>[];
                if (items.isEmpty) {
                  return EmptyView(title: context.l10n.noExams, message: context.l10n.noExamsHint);
                }
                return Column(
                  children: <Widget>[
                    for (final ExamSummary exam in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ExamCard(exam: exam, onTap: () => context.push(Routes.exam(exam.id))),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String? classLevel = context.auth.profile?.classLevel;
    final String? stream = context.auth.profile?.stream;
    final String? classText = classLevel == null ? null : classLabel(context, classLevel) ?? classLevel;
    final String? streamText = stream == null || stream.isEmpty ? null : streamLabel(context, stream) ?? stream;
    final String? contextLine = classText == null
        ? null
        : streamText == null
            ? classText
            : '$classText · $streamText';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(context.l10n.greeting(name), style: Theme.of(context).textTheme.headlineSmall),
        if (contextLine != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            contextLine,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BalancePanel extends StatelessWidget {
  const _BalancePanel({required this.onTopUp});

  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SemanticColors colors = context.semantics;
    return ListenableBuilder(
      listenable: context.walletController,
      builder: (BuildContext context, Widget? _) {
        final WalletController wallet = context.walletController;
        final ScreenState<WalletSnapshot> state = wallet.state;
        final String balanceText = state is ScreenData<WalletSnapshot>
            ? context.fmt.integer(wallet.available)
            : '—';
        return Card(
          color: scheme.primaryContainer,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        context.l10n.balanceShort,
                        style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ),
                    if (wallet.isRefreshing)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: AppSpacing.xs),
                    TextButton.icon(
                      onPressed: onTopUp,
                      style: TextButton.styleFrom(foregroundColor: scheme.onPrimaryContainer),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(context.l10n.addCredit),
                    ),
                  ],
                ),
                Container(width: 40, height: 3, color: colors.credit),
                const SizedBox(height: AppSpacing.xs),
                if (state is ScreenError<WalletSnapshot>)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          context.l10n.walletUnavailable,
                          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
                        ),
                      ),
                      TextButton(
                        onPressed: wallet.refresh,
                        style: TextButton.styleFrom(foregroundColor: scheme.onPrimaryContainer),
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  )
                else ...<Widget>[
                  Text(
                    balanceText,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (state is ScreenData<WalletSnapshot> && wallet.snapshot.nextExpiryAt != null)
                    Text(
                      '${context.l10n.nextExpiry}: ${context.fmt.date(wallet.snapshot.nextExpiryAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Two quiet study shortcuts. The primary action on this screen is browsing
/// the exam library, so these stay outlined.
class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key, required this.onPractice, required this.onPayments});

  final VoidCallback onPractice;
  final VoidCallback onPayments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _ShortcutRow(icon: Icons.edit_note_rounded, label: context.l10n.practiceTitle, onTap: onPractice),
        const SizedBox(height: AppSpacing.xs),
        _ShortcutRow(icon: Icons.receipt_long_outlined, label: context.l10n.paymentsTitle, onTap: onPayments),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 60),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: AlignmentDirectional.centerStart,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurface),
            ),
          ),
          Icon(Icons.chevron_left_rounded, size: 20, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
