/// The student's payment requests: open requests first, then history.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/states.dart';
import '../domain/payment_models.dart';
import 'payment_widgets.dart';

class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  late Future<List<PaymentRequest>> _future = _load();

  Future<List<PaymentRequest>> _load() => context.services.paymentRepository.myRequests();

  Future<void> _refresh() async {
    final Future<List<PaymentRequest>> next = _load();
    setState(() => _future = next);
    try {
      await next;
    } on AppFailure {
      // The list shows the failure through FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.paymentsTitle,
      actions: <Widget>[
        IconButton(
          onPressed: () => context.push(Routes.packages),
          icon: const Icon(Icons.add_card_outlined),
          tooltip: context.l10n.addCredit,
        ),
      ],
      child: FutureBuilder<List<PaymentRequest>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<PaymentRequest>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            return ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: _refresh,
            );
          }
          final List<PaymentRequest> requests = snapshot.data!;
          if (requests.isEmpty) {
            return EmptyView(
              title: context.l10n.paymentsEmpty,
              message: context.l10n.paymentsEmptyHint,
              icon: Icons.receipt_long_outlined,
              action: PrimaryButton(
                label: context.l10n.addCredit,
                expanded: false,
                icon: Icons.add_card_outlined,
                onPressed: () => context.push(Routes.packages),
              ),
            );
          }
          final List<PaymentRequest> open = requests.where((PaymentRequest r) => r.status.isOpen).toList(growable: false);
          final List<PaymentRequest> history = requests.where((PaymentRequest r) => !r.status.isOpen).toList(growable: false);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutterOf(context),
                AppSpacing.sm,
                AppSpacing.gutterOf(context),
                AppSpacing.xl,
              ),
              children: <Widget>[
                if (open.isNotEmpty) ...<Widget>[
                  SectionHeader(title: context.l10n.openPayments),
                  for (final PaymentRequest request in open) _RequestTile(request: request),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (history.isNotEmpty) ...<Widget>[
                  SectionHeader(title: context.l10n.paymentHistory),
                  for (final PaymentRequest request in history) _RequestTile(request: request),
                ],
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: context.l10n.addCredit,
                  icon: Icons.add_card_outlined,
                  onPressed: () => context.push(Routes.packages),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String name = request.package.name.resolve(context.localeController.languageCode);
    final StatusTone tone = statusTone(context, request.status);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: AppRadii.cardAll,
        onTap: () => context.push(Routes.payment(request.id)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name.isEmpty ? context.l10n.paymentsTitle : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${context.fmt.sdg(request.expectedAmountSdg)} · ${context.fmt.dateTime(request.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: tone.foreground, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            statusLabel(context, request.status),
                            style: theme.textTheme.labelMedium?.copyWith(color: tone.foreground),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
