/// The receipt source sheet and the privacy explanation shown before the
/// camera or gallery opens.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import 'receipt_picker.dart';

Future<ReceiptSource?> showReceiptSourceSheet(BuildContext context) {
  return showModalBottomSheet<ReceiptSource>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(sheetContext.l10n.receiptSourceTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(sheetContext.l10n.takePhoto),
            onTap: () => Navigator.of(sheetContext).pop(ReceiptSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(sheetContext.l10n.chooseFromGallery),
            onTap: () => Navigator.of(sheetContext).pop(ReceiptSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(sheetContext.l10n.choosePdf),
            onTap: () => Navigator.of(sheetContext).pop(ReceiptSource.file),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    ),
  );
}

Future<bool> confirmReceiptAccess(BuildContext context, {required String title, required String body}) async {
  final bool? allowed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(dialogContext.l10n.cancel)),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(dialogContext.l10n.confirm),
        ),
      ],
    ),
  );
  return allowed == true;
}
