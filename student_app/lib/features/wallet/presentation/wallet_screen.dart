/// Wallet tab: the available balance, what is held, the next expiry and the
/// most recent movements. Everything here comes from the server snapshot.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/screen_state.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/states.dart';
import '../domain/entities.dart';
import 'ledger_row.dart';
import 'wallet_controller.dart';
import 'wallet_summary.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<LedgerPage> _ledger = _load();

  Future<LedgerPage> _load() => context.services.walletRepository.fetchLedger(limit: 8);

  void _reload() => setState(() => _ledger = _load());

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.walletTitle,
      showBack: false,
      child: RefreshIndicator(
        onRefresh: () async {
          _reload();
          await context.walletController.refresh();
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterOf(context),
            AppSpacing.sm,
            AppSpacing.gutterOf(context),
            AppSpacing.xl,
          ),
          children: <Widget>[
            ListenableBuilder(
              listenable: context.walletController,
              builder: (BuildContext context, Widget? _) {
                final WalletController controller = context.walletController;
                final ScreenState<WalletSnapshot> state = controller.state;
                if (state is ScreenError<WalletSnapshot>) {
                  return Column(
                    children: <Widget>[
                      ErrorView(failure: state.failure, onRetry: controller.refresh, compact: true),
                      if (controller.updatedAt != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        WalletSummaryPanel(
                          wallet: controller.snapshot,
                          updatedAt: controller.updatedAt,
                          stale: true,
                          onTopUp: () => context.push(Routes.packages),
                        ),
                      ],
                    ],
                  );
                }
                if (controller.updatedAt == null) {
                  return const Card(
                    child: SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                return WalletSummaryPanel(
                  wallet: controller.snapshot,
                  updatedAt: controller.updatedAt,
                  onTopUp: () => context.push(Routes.packages),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: context.l10n.ledgerTitle,
              action: TextButton(onPressed: () => context.push(Routes.ledger), child: Text(context.l10n.seeAll)),
            ),
            FutureBuilder<LedgerPage>(
              future: _ledger,
              builder: (BuildContext context, AsyncSnapshot<LedgerPage> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  final Object error = snapshot.error!;
                  return ErrorView(
                    failure: error is AppFailure ? error : const AppFailure.network(),
                    onRetry: _reload,
                    compact: true,
                  );
                }
                final List<LedgerEntry> entries = snapshot.data?.items ?? const <LedgerEntry>[];
                if (entries.isEmpty) {
                  return EmptyView(
                    title: context.l10n.ledgerEmpty,
                    message: context.l10n.ledgerEmptyHint,
                    icon: Icons.receipt_long_outlined,
                  );
                }
                return Card(
                  child: Column(
                    children: <Widget>[
                      for (final LedgerEntry entry in entries) LedgerRow(entry: entry),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
