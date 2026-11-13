/// Waits for the server to finish reading an uploaded receipt, then fills the
/// form fields it read.
library;

import 'package:flutter/material.dart';

import '../domain/payment_models.dart';
import '../domain/payment_repository.dart';

const Duration _pollEvery = Duration(milliseconds: 1200);
const int _maxPolls = 25;

/// What the form says about the automatic reading of the uploaded receipt.
enum ReceiptRead { none, reading, filled, manual }

/// Returns the receipt once the server has read it, or null if it is still
/// reading, the upload was replaced, or the wait ran out. [isCurrent] lets the
/// screen cancel a wait as soon as the student picks another file.
Future<ReceiptFile?> readUploadedReceipt(
  PaymentRepository repository,
  String receiptId, {
  required bool Function() isCurrent,
  Duration interval = _pollEvery,
  int maxPolls = _maxPolls,
}) async {
  for (int attempt = 0; attempt < maxPolls; attempt += 1) {
    await Future<void>.delayed(interval);
    if (!isCurrent()) return null;
    final ReceiptFile receipt = await repository.receiptStatus(receiptId);
    if (!isCurrent()) return null;
    if (!receipt.isReading) return receipt;
  }
  return null;
}

/// Fills only what the student left empty — a typed value always wins — and
/// reports whether the receipt was readable.
ReceiptRead applyReceiptFields({
  required ReceiptFile receipt,
  required TextEditingController reference,
  required TextEditingController sender,
}) {
  final String extracted = (receipt.extractedReference ?? '').trim();
  final String name = (receipt.extractedSenderName ?? '').trim();
  if (extracted.isNotEmpty && reference.text.trim().isEmpty) reference.text = extracted;
  if (name.isNotEmpty && sender.text.trim().isEmpty) sender.text = name;
  return extracted.isEmpty ? ReceiptRead.manual : ReceiptRead.filled;
}
