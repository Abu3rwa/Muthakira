part of 'fake_backend.dart';

const Set<String> _receiptTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
};

const Set<String> _submittableStatuses = <String>{'pending_payment', 'needs_info', 'rejected'};

extension _FakePaymentRoutes on FakeBackend {
  FakeReply _payments(RequestOptions options, String method, List<String> segments) {
  if (segments.length < 2) throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
  switch (segments[1]) {
    case 'receipts':
      if (segments.length == 2 && method == 'POST') {
        return FakeReply.json(200, _uploadReceipt(options));
      }
      if (segments.length == 3 && method == 'GET') {
        return FakeReply.json(200, _receiptStatus(segments[2]));
      }
      if (segments.length == 4 && segments[3] == 'file' && method == 'GET') {
        return _receiptFile(segments[2]);
      }
      break;
    case 'requests':
      _settlePayments();
      if (segments.length == 2) {
        if (method == 'GET') {
          final List<Map<String, Object?>> items = List<Map<String, Object?>>.of(store.payments)
            ..sort((Map<String, Object?> left, Map<String, Object?> right) =>
                _string(right['created_at']).compareTo(_string(left['created_at'])));
          return FakeReply.json(200, <String, Object?>{'items': items});
        }
        if (method == 'POST') {
          return FakeReply.json(200, <String, Object?>{'request': _createRequest(_body(options))});
        }
      }
      if (segments.length == 3 && method == 'GET') {
        final Map<String, Object?> request = _findPayment(segments[2]);
        _settlePayments();
        return FakeReply.json(200, request);
      }
      if (segments.length == 4) {
        if (segments[3] == 'cancel' && method == 'POST') {
          return FakeReply.json(200, _cancelPayment(segments[2]));
        }
        if (segments[3] == 'receipt' && method == 'POST') {
          return FakeReply.json(200, _submitPayment(segments[2], _body(options)));
        }
      }
      break;
  }
  throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
}

Map<String, Object?> _findPayment(String id) {
  for (final Map<String, Object?> request in store.payments) {
    if (request['id'] == id) return request;
  }
  throw const _FakeHttpError(404, ErrorCodes.paymentRequestNotFound, 'Payment request not found');
}

Map<String, Object?> _createRequest(Map<String, Object?> body) {
  final String packageId = _string(body['packageId']);
  Map<String, Object?>? package;
  for (final Map<String, Object?> candidate in FakeStore.packages) {
    if (candidate['id'] == packageId) {
      package = candidate;
      break;
    }
  }
  if (package == null) throw const _FakeHttpError(404, ErrorCodes.packageNotFound, 'Package not found');
  final int open = store.payments
      .where((Map<String, Object?> request) => _openStatuses.contains(_string(request['status'])))
      .length;
  if (open >= 3) {
    throw const _FakeHttpError(409, ErrorCodes.tooManyOpenPayments, 'Finish your open payments first');
  }

  final int base = (package['price_sdg'] as num).toInt();
  const int increment = 50;
  final int expected = base + (store.payments.length % 40) * increment;
  final String id = store.nextId('pay');
  final Map<String, Object?> request = <String, Object?>{
    'id': id,
    'status': 'pending_payment',
    'payment_code': 'MTH-${id.split('_').last}',
    'package': package,
    'receiving_account': '1234567890',
    'bank': <String, Object?>{
      'bank_name': 'بنكك',
      'account_name': 'مذكرة',
      'account_number': '1234567890',
    },
    'base_amount_sdg': base,
    'amount_increment': increment,
    'expected_amount_sdg': expected,
    'duplicate_across_accounts': false,
    'reference': null,
    'sender_name': null,
    'submitted_at': null,
    'decided_at': null,
    'reject_reason': null,
    'created_at': _iso(DateTime.now()),
    'receipt': null,
  };
  store.payments.insert(0, request);
  return request;
}

Map<String, Object?> _cancelPayment(String id) {
  final Map<String, Object?> request = _findPayment(id);
  if (_string(request['status']) != 'pending_payment') {
    throw const _FakeHttpError(409, ErrorCodes.paymentNotCancellable, 'This payment can no longer be cancelled');
  }
  request['status'] = 'cancelled';
  return request;
}

Map<String, Object?> _submitPayment(String id, Map<String, Object?> body) {
  final Map<String, Object?> request = _findPayment(id);
  if (!_submittableStatuses.contains(_string(request['status']))) {
    throw const _FakeHttpError(409, ErrorCodes.paymentNotSubmittable, 'This payment cannot be submitted now');
  }
  final String reference = _string(body['reference']).toUpperCase();
  if (reference.length < 4 || reference.length > 64) {
    throw const _FakeHttpError(422, ErrorCodes.invalidReference, 'Enter the transfer reference (4–64 characters)');
  }
  final bool reused = store.payments.any(
    (Map<String, Object?> other) =>
        other['id'] != id && _string(other['reference']).toUpperCase() == reference,
  );
  if (reused) {
    throw const _FakeHttpError(409, ErrorCodes.referenceAlreadyUsed, 'This reference was already used');
  }
  final String receiptId = _string(body['receiptId']);
  if (receiptId.isNotEmpty) {
    final Map<String, Object?>? receipt = store.receipts[receiptId];
    if (receipt == null) throw const _FakeHttpError(404, ErrorCodes.receiptNotFound, 'Receipt not found');
    request['receipt'] = receipt;
  }
  final String senderName = _string(body['senderName']);
  request
    ..['reference'] = reference
    ..['sender_name'] = senderName.isEmpty ? null : senderName
    ..['status'] = 'submitted'
    ..['submitted_at'] = _iso(DateTime.now())
    ..['reject_reason'] = null;
  return request;
}

/// Fake review: payments are approved automatically 25 seconds after
/// submission so the approved → credits flow can be exercised end to end.
void _settlePayments() {
  final DateTime now = DateTime.now();
  for (final Map<String, Object?> request in store.payments) {
    if (_string(request['status']) != 'submitted') continue;
    final DateTime? submittedAt = DateTime.tryParse(_string(request['submitted_at']));
    if (submittedAt == null || now.difference(submittedAt) < const Duration(seconds: 25)) continue;
    request
      ..['status'] = 'approved'
      ..['decided_at'] = _iso(now);
    final Map<String, Object?> package = (request['package'] as Map).cast<String, Object?>();
    final int credits = (package['credits'] as num?)?.toInt() ?? 0;
    store.balance += credits;
    store.addLedger(
      type: 'payment_approved',
      amount: credits,
      paymentId: _string(request['id']),
      reason: 'شراء نقاط',
    );
  }
}

Map<String, Object?> _uploadReceipt(RequestOptions options) {
  final Object? data = options.data;
  if (data is! FormData || data.files.isEmpty) {
    throw const _FakeHttpError(422, ErrorCodes.receiptFileMissing, 'Attach the transfer receipt');
  }
  final MultipartFile file = data.files.first.value;
  final String contentType = file.contentType?.mimeType ?? '';
  if (!_receiptTypes.contains(contentType)) {
    throw const _FakeHttpError(415, ErrorCodes.receiptTypeNotAllowed, 'Unsupported receipt type');
  }
  if (file.length > 8 * 1024 * 1024) {
    throw const _FakeHttpError(413, ErrorCodes.receiptTooLarge, 'Receipt is larger than 8 MB');
  }
  final String id = store.nextId('rcpt');
  final Map<String, Object?> receipt = <String, Object?>{
    'id': id,
    'content_type': contentType,
    'size_bytes': file.length,
    'sha256': 'fake-sha-$id',
    'uploaded_at': _iso(DateTime.now()),
    'extraction_status': contentType == 'application/pdf' ? 'off' : 'pending',
    'extracted_reference': null,
    'extracted_sender_name': null,
  };
  store.receipts[id] = receipt;
  store.receiptFiles[id] = contentType == 'application/pdf' ? _fakePdf() : _fakePng();
  return receipt;
}

/// The fake server "reads" the receipt on the first status poll after upload.
Map<String, Object?> _receiptStatus(String id) {
  final Map<String, Object?>? receipt = store.receipts[id];
  if (receipt == null) throw const _FakeHttpError(404, ErrorCodes.receiptNotFound, 'Receipt not found');
  if (receipt['extraction_status'] == 'pending') {
    receipt['extraction_status'] = 'done';
    receipt['extracted_reference'] = 'BK-FAKE-123456';
    receipt['extracted_sender_name'] = 'Test Student';
  }
  return receipt;
}

FakeReply _receiptFile(String id) {
  final Map<String, Object?>? receipt = store.receipts[id];
  if (receipt == null) throw const _FakeHttpError(404, ErrorCodes.receiptNotFound, 'Receipt not found');
  return FakeReply.bytes(200, store.receiptFiles[id] ?? const <int>[], _string(receipt['content_type']));
}
}

const Set<String> _openStatuses = <String>{'pending_payment', 'submitted', 'under_review', 'needs_info'};

Uint8List _fakePng() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Uint8List _fakePdf() => Uint8List.fromList(
  utf8.encode(
    '%PDF-1.4\n'
    '1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n'
    '2 0 obj<</Type/Pages/Kids[]/Count 0>>endobj\n'
    'trailer<</Root 1 0 R>>\n'
    '%%EOF\n',
  ),
);
