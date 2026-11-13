/// Encrypts sensitive cache payloads (paid keys, wallet snapshot) with an
/// AES-GCM key held in secure storage. Cheaper than full SQLCipher.
library;

import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/constants.dart';

class SecretBox {
  SecretBox({FlutterSecureStorage? storage})
    : _storage = storage ??
          const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _storage;
  Encrypter? _encrypter;

  Future<Encrypter> _cipher() async {
    final Encrypter? existing = _encrypter;
    if (existing != null) return existing;
    final String? stored = await _storage.read(key: StorageKeys.cacheKey);
    final Key key = stored == null ? Key.fromSecureRandom(32) : Key(base64Decode(stored));
    if (stored == null) {
      await _storage.write(key: StorageKeys.cacheKey, value: base64Encode(key.bytes));
    }
    final Encrypter created = Encrypter(AES(key, mode: AESMode.gcm));
    _encrypter = created;
    return created;
  }

  Future<String> seal(String plainText) async {
    final Encrypter cipher = await _cipher();
    final IV iv = IV.fromSecureRandom(12);
    final Encrypted encrypted = cipher.encrypt(plainText, iv: iv);
    return '${base64Encode(iv.bytes)}.${encrypted.base64}';
  }

  Future<String> open(String sealed) async {
    final int split = sealed.indexOf('.');
    if (split <= 0) throw const FormatException('Malformed sealed payload');
    final Encrypter cipher = await _cipher();
    final IV iv = IV(base64Decode(sealed.substring(0, split)));
    return cipher.decrypt(Encrypted.fromBase64(sealed.substring(split + 1)), iv: iv);
  }

  Future<void> destroyKey() async {
    _encrypter = null;
    await _storage.delete(key: StorageKeys.cacheKey);
  }
}