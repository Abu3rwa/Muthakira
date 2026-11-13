/// Shows the receipt attached to a payment request: images inline, PDFs via
/// the system share/open sheet (no third-party viewer dependency).
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_context.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../domain/payment_models.dart';

class ReceiptViewer extends StatefulWidget {
  const ReceiptViewer({super.key, required this.request});

  final PaymentRequest request;

  @override
  State<ReceiptViewer> createState() => _ReceiptViewerState();
}

class _ReceiptViewerState extends State<ReceiptViewer> {
  late Future<Uint8List> _bytes = _load();
  bool _opening = false;

  ReceiptFile get _receipt => widget.request.receipt!;

  Future<Uint8List> _load() => context.services.paymentRepository.receiptBytes(_receipt.id);

  Future<void> _openFile(Uint8List bytes) async {
    setState(() => _opening = true);
    try {
      await Share.shareXFiles(
        <XFile>[
          XFile.fromData(
            bytes,
            name: _receipt.isPdf ? 'receipt-${_receipt.id}.pdf' : 'receipt-${_receipt.id}.jpg',
            mimeType: _receipt.contentType,
          ),
        ],
        fileNameOverrides: <String>[
          _receipt.isPdf ? 'receipt-${_receipt.id}.pdf' : 'receipt-${_receipt.id}.jpg',
        ],
      );
    } on Exception {
      if (mounted) context.snack(context.l10n.receiptOpenFailed);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.xs, 0),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(context.l10n.receiptPreview, style: theme.textTheme.titleMedium)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Icon(
                    _receipt.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${context.fmt.dateTime(_receipt.uploadedAt)} · ${_sizeLabel(_receipt.sizeBytes)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: FutureBuilder<Uint8List>(
                future: _bytes,
                builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppSpacing.md),
                          Text(context.l10n.loading, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    final Object error = snapshot.error!;
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            failureMessage(
                              context.l10n,
                              error is AppFailure ? error : const AppFailure.network(),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => setState(() => _bytes = _load()),
                            child: Text(context.l10n.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  final Uint8List bytes = snapshot.data!;
                  if (_receipt.isPdf) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.picture_as_pdf_outlined, size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: AppSpacing.md),
                          Text(context.l10n.receiptLabel, style: theme.textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton.icon(
                            onPressed: _opening ? null : () => _openFile(bytes),
                            icon: _opening
                                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.open_in_new_rounded),
                            label: Text(context.l10n.openReceiptFile),
                          ),
                        ],
                      ),
                    );
                  }
                  return InteractiveViewer(
                    maxScale: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.input),
                        child: Image.memory(bytes, gaplessPlayback: true),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  String _sizeLabel(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
    return '$bytes B';
  }
}
