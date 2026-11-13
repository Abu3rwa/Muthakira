/// S32: confirm a paid question-generation job for one material.
///
/// The fee is set and charged by the server when confirmed; this screen never
/// quotes a client-side price.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_services.dart';
import '../../../core/errors/error_codes.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/grade_labels.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../domain/material_models.dart';

class GenerationConfirmScreen extends StatefulWidget {
  const GenerationConfirmScreen({super.key, required this.materialId, this.material});

  final String materialId;
  final MaterialItem? material;

  @override
  State<GenerationConfirmScreen> createState() => _GenerationConfirmScreenState();
}

class _GenerationConfirmScreenState extends State<GenerationConfirmScreen> {
  late Future<MaterialItem> _material = widget.material != null
      ? Future<MaterialItem>.value(widget.material!)
      : _fetch();
  int _count = generationMinQuestions;
  bool _acknowledged = false;
  bool _busy = false;
  AppFailure? _failure;

  Future<MaterialItem> _fetch() async {
    final List<MaterialItem> items = await context.services.materialsRepository.listMaterials();
    for (final MaterialItem item in items) {
      if (item.id == widget.materialId) return item;
    }
    throw AppFailure.api(code: ErrorCodes.materialNotFound, status: 404);
  }

  Future<void> _submit(MaterialItem material) async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    final AppServices services = context.services;
    try {
      final GenerationJob job = await services.materialsRepository.createGeneration(
        material.id,
        count: _count,
      );
      if (mounted) await context.refreshWalletAfterAi();
      if (mounted) context.pop(job.id);
    } on AppFailure catch (failure) {
      // A lost response may still have reserved credits server-side.
      if (mounted) await context.refreshWalletAfterAi();
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.generationConfirmTitle,
      child: FutureBuilder<MaterialItem>(
        future: _material,
        builder: (BuildContext context, AsyncSnapshot<MaterialItem> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            return ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: () => setState(() => _material = _fetch()),
            );
          }
          final MaterialItem material = snapshot.data!;
          return _body(material);
        },
      ),
    );
  }

  Widget _body(MaterialItem material) {
    final double gutter = AppSpacing.gutterOf(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(material.displayName, style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${material.subject} · ${gradeLabel(context.l10n, material.classLevel)}',
                style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                context.l10n.generationFrom(material.displayName),
                style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          title: context.l10n.generationCount,
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              for (int count = generationMinQuestions; count <= generationMaxQuestions; count += 1)
                ChoiceChip(
                  label: Text(context.fmt.integer(count)),
                  selected: _count == count,
                  onSelected: (_) => setState(() => _count = count),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Note(icon: Icons.category_outlined, text: context.l10n.generationTypes),
              const SizedBox(height: AppSpacing.xs),
              _Note(icon: Icons.fact_check_outlined, text: context.l10n.generationReviewNote),
              const SizedBox(height: AppSpacing.xs),
              _Note(icon: Icons.payments_outlined, text: context.l10n.generationPriceServer, strong: true),
              const SizedBox(height: AppSpacing.xxs),
              _Note(icon: Icons.info_outline_rounded, text: context.l10n.generationCostNote),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        CheckboxListTile(
          value: _acknowledged,
          onChanged: (bool? value) => setState(() => _acknowledged = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.generationAck, style: context.text.bodyMedium),
        ),
        if (_failure != null) ...<Widget>[
          Text(_message(_failure!), style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
          if (_failure!.code == ErrorCodes.insufficientCredits)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => context.push<void>(Routes.packages),
                child: Text(context.l10n.addCredit),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.xs),
        PrimaryButton(
          label: context.l10n.generationConfirm,
          icon: Icons.auto_awesome_outlined,
          isLoading: _busy,
          onPressed: _busy || !_acknowledged ? null : () => _submit(material),
        ),
      ],
    );
  }

  String _message(AppFailure failure) => switch (failure.code) {
    ErrorCodes.insufficientCredits => context.l10n.errorInsufficientCredits,
    ErrorCodes.aiContentUnsafe => context.l10n.generationUnsafe,
    ErrorCodes.materialNotFound => context.l10n.errorMaterialNotFound,
    _ => failureMessage(context.l10n, failure),
  };
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: context.scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: (strong ? context.text.titleSmall : context.text.bodySmall)?.copyWith(
              color: strong ? context.scheme.onSurface : context.scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
