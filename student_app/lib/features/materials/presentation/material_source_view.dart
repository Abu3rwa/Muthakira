/// The source picker inside S31: mode chips, the active input, preview and the
/// explicit PDF limitation.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

enum MaterialSource { paste, textFile, image }

class MaterialSourceView extends StatelessWidget {
  const MaterialSourceView({
    super.key,
    required this.source,
    required this.text,
    required this.onSource,
    required this.onPickText,
    required this.onPickImage,
    this.error,
    this.fileName,
    this.bytes,
  });

  final MaterialSource source;
  final TextEditingController text;
  final ValueChanged<MaterialSource> onSource;
  final VoidCallback onPickText;
  final VoidCallback onPickImage;
  final String? error;
  final String? fileName;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            ChoiceChip(
              label: Text(context.l10n.materialSourcePaste),
              selected: source == MaterialSource.paste,
              onSelected: (_) => onSource(MaterialSource.paste),
            ),
            ChoiceChip(
              label: Text(context.l10n.materialSourceFile),
              selected: source == MaterialSource.textFile,
              onSelected: (_) => onSource(MaterialSource.textFile),
            ),
            ChoiceChip(
              label: Text(context.l10n.materialSourcePhoto),
              selected: source == MaterialSource.image,
              onSelected: (_) => onSource(MaterialSource.image),
            ),
            const ChoiceChip(label: Text('PDF'), selected: false),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.info_outline_rounded, size: 18, color: context.scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                context.l10n.materialPdfDisabled,
                style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant, height: 1.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (source == MaterialSource.paste)
          AppTextField(
            label: context.l10n.materialTextLabel,
            hint: context.l10n.materialTextHint,
            controller: text,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
          )
        else ...<Widget>[
          Text(
            context.l10n.materialFileHint,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xs),
          SecondaryButton(
            label: context.l10n.materialPickFile,
            icon: Icons.upload_file_outlined,
            onPressed: source == MaterialSource.image ? onPickImage : onPickText,
          ),
          if (bytes != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            if (source == MaterialSource.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: Image.memory(bytes!, height: 150, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Row(
                children: <Widget>[
                  Icon(Icons.description_outlined, color: context.scheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(fileName ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${context.fmt.integer(bytes!.length)} B',
              style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          ],
        ],
        if (error != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(error!, style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
        ],
      ],
    );
  }
}
