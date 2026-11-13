import 'dart:typed_data';

import 'payment_models.dart';

abstract interface class PaymentRepository {
  Future<List<CreditPackage>> packages();

  Future<PaymentRequest> createRequest(String packageId);

  Future<List<PaymentRequest>> myRequests();

  Future<PaymentRequest> getRequest(String id);

  Future<PaymentRequest> cancelRequest(String id);

  Future<ReceiptFile> uploadReceipt(ReceiptDraft draft);

  /// Poll after an upload until [ReceiptFile.extraction] is no longer pending.
  Future<ReceiptFile> receiptStatus(String id);

  Future<PaymentRequest> submitReceipt(String requestId, PaymentSubmission submission);

  Future<Uint8List> receiptBytes(String receiptId);
}
