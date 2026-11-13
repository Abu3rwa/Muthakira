import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/config/constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/storage/user_scope.dart';
import '../../../core/utils/parse.dart';
import '../domain/payment_models.dart';
import '../domain/payment_repository.dart';

/// Payments API. The last request list is cached (encrypted) so the student
/// still sees their status while offline; amounts always come from the server.
class ApiPaymentRepository implements PaymentRepository {
  ApiPaymentRepository(this._api, this._cache, this._scope);

  final ApiClient _api;
  final CacheStore _cache;
  final UserScope _scope;

  static const String _requestsKey = 'payments.requests';

  @override
  Future<List<CreditPackage>> packages() async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.packages);
    return Parse.mapList(json['items']).map(CreditPackage.fromJson).toList(growable: false);
  }

  @override
  Future<PaymentRequest> createRequest(String packageId) async {
    final Map<String, dynamic> json = await _api.postJson(
      ApiPaths.paymentRequests,
      body: <String, Object?>{'packageId': packageId},
    );
    return PaymentRequest.fromJson(Parse.map(json['request']));
  }

  @override
  Future<List<PaymentRequest>> myRequests() async {
    try {
      final Map<String, dynamic> json = await _api.getJson(ApiPaths.paymentRequests);
      final List<PaymentRequest> items =
          Parse.mapList(json['items']).map(PaymentRequest.fromJson).toList(growable: false);
      await _remember(items);
      return items;
    } on AppFailure catch (failure) {
      final List<PaymentRequest>? cached = await _cachedRequests();
      if (cached != null && failure.isOffline) return cached;
      rethrow;
    }
  }

  @override
  Future<PaymentRequest> getRequest(String id) async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.paymentRequest(id));
    return PaymentRequest.fromJson(json, receipt: json['receipt']);
  }

  @override
  Future<PaymentRequest> cancelRequest(String id) async {
    final Map<String, dynamic> json = await _api.postJson(ApiPaths.paymentCancel(id));
    return PaymentRequest.fromJson(json);
  }

  @override
  Future<ReceiptFile> uploadReceipt(ReceiptDraft draft) async {
    final FormData form = FormData.fromMap(<String, Object?>{
      'file': MultipartFile.fromBytes(
        draft.bytes,
        filename: draft.fileName,
        contentType: DioMediaType.parse(draft.contentType),
      ),
    });
    final Map<String, dynamic> json = await _api.upload(ApiPaths.receipts, formData: form);
    return ReceiptFile.fromJson(json);
  }

  @override
  Future<ReceiptFile> receiptStatus(String id) async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.receiptStatus(id));
    return ReceiptFile.fromJson(json);
  }

  @override
  Future<PaymentRequest> submitReceipt(String requestId, PaymentSubmission submission) async {
    final Map<String, dynamic> json = await _api.postJson(
      ApiPaths.paymentReceipt(requestId),
      body: <String, Object?>{
        'reference': submission.reference,
        if (submission.senderName != null) 'senderName': submission.senderName,
        if (submission.receiptId != null) 'receiptId': submission.receiptId,
      },
    );
    return PaymentRequest.fromJson(json, receipt: json['receipt']);
  }

  @override
  Future<Uint8List> receiptBytes(String receiptId) => _api.getBytes(ApiPaths.receiptFile(receiptId));

  Future<void> _remember(List<PaymentRequest> items) async {
    final String? userId = _scope.userId;
    if (userId == null) return;
    await _cache.put(
      userId,
      _requestsKey,
      <String, Object?>{'items': items.map((item) => item.toJson()).toList(growable: false)},
      sensitive: true,
    );
  }

  Future<List<PaymentRequest>?> _cachedRequests() async {
    final String? userId = _scope.userId;
    if (userId == null) return null;
    final CacheHit? hit = await _cache.read(userId, _requestsKey);
    if (hit?.value is! Map) return null;
    return Parse.mapList((hit!.value as Map)['items'])
        .map(PaymentRequest.fromJson)
        .toList(growable: false);
  }
}
