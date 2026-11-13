/// A living sample of the design system: colour, type and core controls.
///
/// This is the first implementation gate of the redesign: every token pair and
/// control variant must render without clipping at 320dp and 1.5× text.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/copy_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';

class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SemanticColors colors = context.semantics;
    final EdgeInsets gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterOf(context));
    return AppPage(
      title: context.l10n.designGallery,
      child: ListView(
        padding: gutter.add(const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xl)),
        children: <Widget>[
          SectionHeader(title: context.l10n.galleryColors),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _Swatch(name: 'primary', color: scheme.primary),
              _Swatch(name: 'primaryContainer', color: scheme.primaryContainer),
              _Swatch(name: 'secondary', color: scheme.secondary),
              _Swatch(name: 'tertiary', color: scheme.tertiary),
              _Swatch(name: 'error', color: scheme.error),
              _Swatch(name: 'surface', color: scheme.surface),
              _Swatch(name: 'surfaceContainerLow', color: scheme.surfaceContainerLow),
              _Swatch(name: 'success', color: colors.success),
              _Swatch(name: 'warning', color: colors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.l10n.galleryTypography),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(context.l10n.appName, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(context.l10n.tagline, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(context.l10n.aboutBody, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'المذكّرة التعليميّة — تَشكيلٌ واضح',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'اقرأ النصّ العربي كاملًا دون قصّ الحروف أو التشكيل.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.l10n.galleryComponents),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PrimaryButton(
                    label: context.l10n.continueLabel,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const PrimaryButton(label: 'إرسال', isLoading: true, onPressed: null),
                  const SizedBox(height: AppSpacing.sm),
                  const PrimaryButton(label: 'غير متاح الآن', onPressed: null),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(label: context.l10n.cancel, onPressed: () {}),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: context.l10n.email,
                    controller: _controller,
                    hint: context.l10n.emailHint,
                    helper: context.l10n.passwordHint,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      const ChoiceChip(label: Text('الكل'), selected: true),
                      ChoiceChip(label: const Text('رياضيات'), selected: false, onSelected: (_) {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Align(alignment: AlignmentDirectional.centerStart, child: SavedBadge()),
                  const SizedBox(height: AppSpacing.sm),
                  const Align(alignment: AlignmentDirectional.centerStart, child: SavedBadge(pending: true)),
                  const SizedBox(height: AppSpacing.md),
                  CopyField(label: context.l10n.accountNumber, value: '249900000000', monospace: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 84,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(name, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
