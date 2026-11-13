/// Validates and shrinks a receipt before upload. The server re-validates the
/// type and size; this only keeps the request small and the message local.
library;

import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';

import '../../../core/config/constants.dart';
import '../domain/payment_models.dart';

enum ReceiptMediaProblem { empty, unsupportedType, tooLarge }

class ReceiptMediaException implements Exception {
  const ReceiptMediaException(this.problem);

  final ReceiptMediaProblem problem;
}

const Set<String> allowedReceiptTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
};

String? receiptContentType(Uint8List bytes, String fileName, {String? reported}) {
  String type = (reported ?? '').trim().toLowerCase();
  if (type == 'image/jpg') type = 'image/jpeg';
  if (!allowedReceiptTypes.contains(type)) {
    final String? detected = lookupMimeType(fileName, headerBytes: bytes);
    type = detected == 'image/jpg' ? 'image/jpeg' : (detected ?? type);
  }
  return allowedReceiptTypes.contains(type) ? type : null;
}

Future<ReceiptDraft> prepareReceipt({
  required Uint8List bytes,
  required String fileName,
  String? contentType,
}) async {
  if (bytes.isEmpty) throw const ReceiptMediaException(ReceiptMediaProblem.empty);
  final String? type = receiptContentType(bytes, fileName, reported: contentType);
  if (type == null) throw const ReceiptMediaException(ReceiptMediaProblem.unsupportedType);

  if (type == 'application/pdf') {
    if (bytes.lengthInBytes > Limits.maxReceiptBytes) {
      throw const ReceiptMediaException(ReceiptMediaProblem.tooLarge);
    }
    return ReceiptDraft(bytes: bytes, fileName: fileName, contentType: type);
  }

  Uint8List current = bytes;
  String name = fileName;
  String resolved = type;
  if (bytes.lengthInBytes > Limits.targetReceiptBytes) {
    int quality = 85;
    int bound = 1600;
    for (int attempt = 0; attempt < 6 && current.lengthInBytes > Limits.targetReceiptBytes; attempt += 1) {
      try {
        current = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: bound,
          minHeight: bound,
          quality: quality,
        );
      } on Exception {
        break;
      }
      quality = quality > 50 ? quality - 10 : 45;
      bound = (bound * 0.8).round();
    }
    if (current.lengthInBytes < bytes.lengthInBytes) {
      resolved = 'image/jpeg';
      name = _withJpgExtension(fileName);
    } else {
      current = bytes;
    }
  }
  if (current.lengthInBytes > Limits.maxReceiptBytes) {
    throw const ReceiptMediaException(ReceiptMediaProblem.tooLarge);
  }
  return ReceiptDraft(bytes: current, fileName: name, contentType: resolved);
}

String _withJpgExtension(String fileName) {
  final int dot = fileName.lastIndexOf('.');
  final String base = dot > 0 ? fileName.substring(0, dot) : fileName;
  return '$base.jpg';
}
