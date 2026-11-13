/// Credit packages: one selectable row per real server package, then a single
/// continue action that creates the request. Nothing is created on selection.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/states.dart';
import '../domain/payment_models.dart';
import 'package_widgets.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  late Future<(List<CreditPackage>, List<PaymentRequest>)> _future = _load();
  String? _selectedId;
  bool _creating = false;
  String? _createError;

  Future<(List<CreditPackage>, List<PaymentRequest>)> _load() async {
    final services = context.services;
    final List<CreditPackage> packages = await services.paymentRepository.packages();
    final List<PaymentRequest> requests = await services.paymentRepository.myRequests();
    return (packages, requests);
  }

  void _reload() => setState(() {
    _future = _load();
  });

  Future<void> _continue(CreditPackage package) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.confirmPackageTitle),
        content: Text(
          context.l10n.confirmPackageBody(
            context.fmt.sdg(package.priceSdg),
            context.fmt.integer(package.credits),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.confirmPackage)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _creating = true;
      _createError = null;
    });
    try {
      final PaymentRequest request = await context.services.paymentRepository.createRequest(package.id);
      if (!mounted) return;
      _selectedId = null;
      _reload();
      await context.push<void>(Routes.payment(request.id));
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() => _createError = failureMessage(context.l10n, failure));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.packagesTitle,
      child: FutureBuilder<(List<CreditPackage>, List<PaymentRequest>)>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<(List<CreditPackage>, List<PaymentRequest>)> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            return ErrorView(failure: error is AppFailure ? error : const AppFailure.network(), onRetry: _reload);
          }
          final (List<CreditPackage> packages, List<PaymentRequest> requests) = snapshot.data!;
          final bool hasOpenRequest = requests.any((PaymentRequest request) => request.status.isOpen);
          CreditPackage? selected;
          for (final CreditPackage package in packages) {
            if (package.id == _selectedId) selected = package;
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.gutterOf(context),
                    AppSpacing.sm,
                    AppSpacing.gutterOf(context),
                    AppSpacing.lg,
                  ),
                  children: <Widget>[
                    if (hasOpenRequest) ...<Widget>[
                      OpenRequestNotice(
                        text: context.l10n.openRequestNotice,
                        onSeeAll: () => context.push(Routes.payments),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    SectionHeader(title: context.l10n.choosePackage),
                    if (packages.isEmpty)
                      EmptyView(title: context.l10n.noPackages, message: context.l10n.noPackagesHint)
                    else ...<Widget>[
                      Text(
                        context.l10n.selectPackageHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final CreditPackage package in packages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: PackageRow(
                            package: package,
                            selected: package.id == _selectedId,
                            onSelect: _creating ? null : () => setState(() => _selectedId = package.id),
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: AppRadii.cardAll,
                      ),
                      child: Text(
                        context.l10n.paymentHelpBody,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (packages.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutterOf(context),
                      AppSpacing.xs,
                      AppSpacing.gutterOf(context),
                      AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (_createError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Text(
                              _createError!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        PrimaryButton(
                          label: context.l10n.continueToPayment,
                          isLoading: _creating,
                          onPressed: _creating || selected == null ? null : () => _continue(selected!),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

