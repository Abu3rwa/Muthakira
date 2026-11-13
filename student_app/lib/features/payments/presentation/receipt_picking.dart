/// Reading a receipt off the device: the privacy explanation, the camera, the
/// gallery and the file picker. Nothing here uploads or talks to the server.
library;

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_context.dart';
import '../data/receipt_media.dart';
import 'receipt_picker.dart';
import 'receipt_source_sheet.dart';

/// A receipt read from the device, before any upload.
class ReceiptPick {
  const ReceiptPick({required this.bytes, required this.name, this.contentType});

  final Uint8List bytes;
  final String name;
  final String? contentType;
}

/// The student could not get a receipt from the device; the message is already
/// in their language and belongs under the attachment field.
class ReceiptPickException implements Exception {
  const ReceiptPickException(this.message);

  final String message;
}

Future<ReceiptPick?> pickReceipt(BuildContext context, ReceiptSource source) => switch (source) {
  ReceiptSource.camera => _pickImage(context, ImageSource.camera),
  ReceiptSource.gallery => _pickImage(context, ImageSource.gallery),
  ReceiptSource.file => _pickFile(context),
};

/// Why a picked file cannot be used, in the student's language.
String receiptMediaMessage(BuildContext context, ReceiptMediaException error) => switch (error.problem) {
  ReceiptMediaProblem.tooLarge => context.l10n.receiptTooLargeLocal,
  ReceiptMediaProblem.unsupportedType => context.l10n.receiptTypeInvalidLocal,
  ReceiptMediaProblem.empty => context.l10n.errorReceiptFileMissing,
};

Future<ReceiptPick?> _pickImage(BuildContext context, ImageSource source) async {
  final bool allowed = await confirmReceiptAccess(
    context,
    title: source == ImageSource.camera ? context.l10n.cameraRationaleTitle : context.l10n.galleryRationaleTitle,
    body: source == ImageSource.camera ? context.l10n.cameraRationaleBody : context.l10n.galleryRationaleBody,
  );
  if (!allowed) return null;
  try {
    final XFile? file = await ImagePicker().pickImage(source: source, maxWidth: 2400, imageQuality: 90);
    if (file == null) return null;
    return ReceiptPick(bytes: await file.readAsBytes(), name: file.name, contentType: file.mimeType);
  } on Exception {
    if (!context.mounted) return null;
    throw ReceiptPickException(context.l10n.errorReceiptFileMissing);
  }
}

Future<ReceiptPick?> _pickFile(BuildContext context) async {
  final PlatformFile file;
  try {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    file = result.files.single;
  } on Exception {
    if (!context.mounted) return null;
    throw ReceiptPickException(context.l10n.errorReceiptFileMissing);
  }
  final Uint8List? bytes = file.bytes;
  if (bytes == null) {
    if (!context.mounted) return null;
    throw ReceiptPickException(context.l10n.errorReceiptFileMissing);
  }
  return ReceiptPick(bytes: bytes, name: file.name);
}
