import 'package:flutter/foundation.dart';

import '../../../core/utils/parse.dart';

enum PaymentStatus {
  pendingPayment,
  submitted,
  underReview,
  needsInfo,
  approved,
  rejected,
  expired,
  cancelled,
  unknown;

  static PaymentStatus parse(Object? raw) => switch (raw) {
    'pending_payment' => PaymentStatus.pendingPayment,
    'submitted' => PaymentStatus.submitted,
    'under_review' => PaymentStatus.underReview,
    'needs_info' => PaymentStatus.needsInfo,
    'approved' => PaymentStatus.approved,
    'rejected' => PaymentStatus.rejected,
    'expired' => PaymentStatus.expired,
    'cancelled' => PaymentStatus.cancelled,
    _ => PaymentStatus.unknown,
  };

  String get wire => switch (this) {
    PaymentStatus.pendingPayment => 'pending_payment',
    PaymentStatus.submitted => 'submitted',
    PaymentStatus.underReview => 'under_review',
    PaymentStatus.needsInfo => 'needs_info',
    PaymentStatus.approved => 'approved',
    PaymentStatus.rejected => 'rejected',
    PaymentStatus.expired => 'expired',
    PaymentStatus.cancelled => 'cancelled',
    PaymentStatus.unknown => 'unknown',
  };

  bool get isOpen => switch (this) {
    PaymentStatus.pendingPayment ||
    PaymentStatus.submitted ||
    PaymentStatus.underReview ||
    PaymentStatus.needsInfo => true,
    _ => false,
  };

  bool get isWaiting => this == PaymentStatus.submitted || this == PaymentStatus.underReview;

  bool get needsAction => this == PaymentStatus.pendingPayment || this == PaymentStatus.needsInfo || this == PaymentStatus.rejected;
}

class CreditPackage {
  const CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceSdg,
  });

  final String id;
  final LocalizedText name;
  final int credits;
  final int priceSdg;

  factory CreditPackage.fromJson(Map<String, Object?> json) => CreditPackage(
    id: Parse.string(json['id']),
    name: LocalizedText.fromJson(json['name']),
    credits: Parse.integer(json['credits']),
    priceSdg: Parse.integer(json['price_sdg']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name.toJson(),
    'credits': credits,
    'price_sdg': priceSdg,
  };
}

class LocalizedText {
  const LocalizedText({this.ar, this.en});

  final String? ar;
  final String? en;

  String resolve(String locale) {
    final arabic = (ar ?? '').trim();
    final english = (en ?? '').trim();
    if (locale.startsWith('ar')) return arabic.isNotEmpty ? arabic : english;
    return english.isNotEmpty ? english : arabic;
  }

  factory LocalizedText.fromJson(Object? raw) {
    if (raw is String) return LocalizedText(ar: raw, en: raw);
    if (raw is Map) {
      return LocalizedText(ar: Parse.stringOrNull(raw['ar']), en: Parse.stringOrNull(raw['en']));
    }
    return const LocalizedText();
  }

  Map<String, Object?> toJson() => {'ar': ar, 'en': en};
}

class PaymentPackage {
  const PaymentPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceSdg,
  });

  final String id;
  final LocalizedText name;
  final int credits;
  final int priceSdg;

  factory PaymentPackage.fromJson(Map<String, Object?> json) => PaymentPackage(
    id: Parse.string(json['id']),
    name: LocalizedText.fromJson(json['name']),
    credits: Parse.integer(json['credits']),
    priceSdg: Parse.integer(json['price_sdg']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name.toJson(),
    'credits': credits,
    'price_sdg': priceSdg,
  };
}

class ReceivingBank {
  const ReceivingBank({this.bankName, this.accountName, this.accountNumber});

  final String? bankName;
  final String? accountName;
  final String? accountNumber;

  bool get isConfigured => (accountNumber ?? '').trim().isNotEmpty;

  factory ReceivingBank.fromJson(Object? raw) {
    final json = raw is Map ? raw : const <String, dynamic>{};
    return ReceivingBank(
      bankName: Parse.stringOrNull(json['bank_name']),
      accountName: Parse.stringOrNull(json['account_name']),
      accountNumber: Parse.stringOrNull(json['account_number']),
    );
  }

  Map<String, Object?> toJson() => {
    'bank_name': bankName,
    'account_name': accountName,
    'account_number': accountNumber,
  };
}

class PaymentRequest {
  const PaymentRequest({
    required this.id,
    required this.status,
    required this.paymentCode,
    required this.package,
    required this.receivingAccount,
    required this.bank,
    required this.baseAmountSdg,
    required this.amountIncrement,
    required this.expectedAmountSdg,
    required this.duplicateAcrossAccounts,
    this.reference,
    this.senderName,
    this.submittedAt,
    this.decidedAt,
    this.rejectReason,
    this.createdAt,
    this.receipt,
  });

  final String id;
  final PaymentStatus status;
  final String paymentCode;
  final PaymentPackage package;
  final String receivingAccount;
  final ReceivingBank bank;
  final int baseAmountSdg;
  final int amountIncrement;
  final int expectedAmountSdg;
  final bool duplicateAcrossAccounts;
  final String? reference;
  final String? senderName;
  final DateTime? submittedAt;
  final DateTime? decidedAt;
  final String? rejectReason;
  final DateTime? createdAt;
  final ReceiptFile? receipt;

  bool get canSubmit => status == PaymentStatus.pendingPayment || status == PaymentStatus.needsInfo || status == PaymentStatus.rejected;

  bool get canCancel => status == PaymentStatus.pendingPayment;

  factory PaymentRequest.fromJson(Map<String, Object?> json, {Object? receipt}) => PaymentRequest(
    id: Parse.string(json['id']),
    status: PaymentStatus.parse(json['status']),
    paymentCode: Parse.string(json['payment_code']),
    package: PaymentPackage.fromJson(Parse.map(json['package'])),
    receivingAccount: Parse.string(json['receiving_account']),
    bank: ReceivingBank.fromJson(json['bank']),
    baseAmountSdg: Parse.integer(json['base_amount_sdg']),
    amountIncrement: Parse.integer(json['amount_increment']),
    expectedAmountSdg: Parse.integer(json['expected_amount_sdg']),
    duplicateAcrossAccounts: Parse.boolean(json['duplicate_across_accounts']),
    reference: Parse.stringOrNull(json['reference']),
    senderName: Parse.stringOrNull(json['sender_name']),
    submittedAt: Parse.date(json['submitted_at']),
    decidedAt: Parse.date(json['decided_at']),
    rejectReason: Parse.stringOrNull(json['reject_reason']),
    createdAt: Parse.date(json['created_at']),
    receipt: receipt == null ? null : ReceiptFile.fromJson(Parse.map(receipt)),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'status': status.wire,
    'payment_code': paymentCode,
    'package': package.toJson(),
    'receiving_account': receivingAccount,
    'bank': bank.toJson(),
    'base_amount_sdg': baseAmountSdg,
    'amount_increment': amountIncrement,
    'expected_amount_sdg': expectedAmountSdg,
    'duplicate_across_accounts': duplicateAcrossAccounts,
    'reference': reference,
    'sender_name': senderName,
    'submitted_at': submittedAt?.toIso8601String(),
    'decided_at': decidedAt?.toIso8601String(),
    'reject_reason': rejectReason,
    'created_at': createdAt?.toIso8601String(),
    'receipt': receipt?.toJson(),
  };

  PaymentRequest copyWith({PaymentStatus? status, ReceiptFile? receipt, String? rejectReason}) => PaymentRequest(
    id: id,
    status: status ?? this.status,
    paymentCode: paymentCode,
    package: package,
    receivingAccount: receivingAccount,
    bank: bank,
    baseAmountSdg: baseAmountSdg,
    amountIncrement: amountIncrement,
    expectedAmountSdg: expectedAmountSdg,
    duplicateAcrossAccounts: duplicateAcrossAccounts,
    reference: reference,
    senderName: senderName,
    submittedAt: submittedAt,
    decidedAt: decidedAt,
    rejectReason: rejectReason ?? this.rejectReason,
    createdAt: createdAt,
    receipt: receipt ?? this.receipt,
  );
}

enum ReceiptExtraction {
  pending,
  done,
  failed,
  off;

  /// Anything the server did not say is treated as "not read automatically".
  static ReceiptExtraction parse(Object? raw) => switch (raw) {
    'pending' => ReceiptExtraction.pending,
    'done' => ReceiptExtraction.done,
    'failed' => ReceiptExtraction.failed,
    _ => ReceiptExtraction.off,
  };

  String get wire => name;
}

class ReceiptFile {
  const ReceiptFile({
    required this.id,
    required this.contentType,
    required this.sizeBytes,
    this.sha256,
    this.uploadedAt,
    this.extraction = ReceiptExtraction.off,
    this.extractedReference,
    this.extractedSenderName,
  });

  final String id;
  final String contentType;
  final int sizeBytes;
  final String? sha256;
  final DateTime? uploadedAt;

  /// What the server made of the image: the reference and sender name it read,
  /// or why it could not. The student can always type them instead.
  final ReceiptExtraction extraction;
  final String? extractedReference;
  final String? extractedSenderName;

  bool get isPdf => contentType == 'application/pdf';

  bool get isReading => extraction == ReceiptExtraction.pending;

  factory ReceiptFile.fromJson(Map<String, Object?> json) => ReceiptFile(
    id: Parse.string(json['id']),
    contentType: Parse.string(json['content_type'], fallback: 'application/octet-stream'),
    sizeBytes: Parse.integer(json['size_bytes']),
    sha256: Parse.stringOrNull(json['sha256']),
    uploadedAt: Parse.date(json['uploaded_at']),
    extraction: ReceiptExtraction.parse(json['extraction_status']),
    extractedReference: Parse.stringOrNull(json['extracted_reference']),
    extractedSenderName: Parse.stringOrNull(json['extracted_sender_name']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'content_type': contentType,
    'size_bytes': sizeBytes,
    'sha256': sha256,
    'uploaded_at': uploadedAt?.toIso8601String(),
    'extraction_status': extraction.wire,
    'extracted_reference': extractedReference,
    'extracted_sender_name': extractedSenderName,
  };
}

/// A local receipt ready for upload; [bytes] is compressed before sending.
class ReceiptDraft {
  const ReceiptDraft({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  int get sizeBytes => bytes.lengthInBytes;
}

class PaymentSubmission {
  const PaymentSubmission({required this.reference, this.senderName, this.receiptId});

  final String reference;
  final String? senderName;
  final String? receiptId;
}
