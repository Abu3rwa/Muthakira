/// dio adapter that answers every request from the in-memory fake backend.
///
/// Injected only when `--dart-define=USE_FAKE_API=true`, so release builds
/// keep the real HTTP adapter and tree-shake this file away.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'fake_backend.dart';

class FakeApiAdapter implements HttpClientAdapter {
  FakeApiAdapter(this._backend);

  final FakeBackend _backend;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final FakeReply reply = _backend.handle(options);
    final Map<String, List<String>> headers = <String, List<String>>{
      Headers.contentTypeHeader: <String>[reply.contentType],
    };
    final List<int>? bytes = reply.bytes;
    if (bytes != null) {
      return ResponseBody.fromBytes(bytes, reply.status, headers: headers);
    }
    return ResponseBody.fromString(jsonEncode(reply.body), reply.status, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}
