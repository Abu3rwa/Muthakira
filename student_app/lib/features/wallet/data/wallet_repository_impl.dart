/// Wallet reads with a stale-while-revalidate cache of the snapshot and the
/// first ledger page.
library;

import '../../../core/config/constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/storage/user_scope.dart';
import '../../../core/utils/parse.dart';
import '../domain/entities.dart';
import '../domain/wallet_repository.dart';

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository({required ApiClient api, required CacheStore cache, required UserScope scope})
    : _api = api,
      _cache = cache,
      _scope = scope;

  static const String snapshotKey = 'wallet.snapshot';
  static const String ledgerKey = 'wallet.ledger.first';

  final ApiClient _api;
  final CacheStore _cache;
  final UserScope _scope;

  @override
  Future<WalletSnapshot> fetchWallet() async {
    final Map<String, dynamic> body = await _api.getJson(ApiPaths.wallet);
    final WalletSnapshot snapshot = WalletSnapshot.fromJson(body);
    await _cache.put(_scope.cacheOwner, snapshotKey, snapshot.toJson(), sensitive: true);
    return snapshot;
  }

  @override
  Future<LedgerPage> fetchLedger({int limit = Limits.ledgerPageSize, String? cursor}) async {
    final Map<String, dynamic> body = await _api.getJson(
      ApiPaths.ledger,
      query: <String, dynamic>{'limit': limit, 'cursor': cursor},
    );
    final LedgerPage page = LedgerPage.fromJson(body);
    if (cursor == null) {
      await _cache.put(
        _scope.cacheOwner,
        ledgerKey,
        <String, Object?>{
          'items': page.items.map((LedgerEntry entry) => entry.toJson()).toList(),
          'next_cursor': page.nextCursor,
        },
      );
    }
    return page;
  }

  Future<WalletSnapshot?> cachedWallet() async {
    final CacheHit? hit = await _cache.read(_scope.cacheOwner, snapshotKey);
    if (hit == null) return null;
    return WalletSnapshot.fromJson(Parse.map(hit.value));
  }

  Future<LedgerPage?> cachedLedger() async {
    final CacheHit? hit = await _cache.read(_scope.cacheOwner, ledgerKey);
    if (hit == null) return null;
    return LedgerPage.fromJson(Parse.map(hit.value));
  }

  Future<DateTime?> cachedWalletUpdatedAt() async {
    final CacheHit? hit = await _cache.read(_scope.cacheOwner, snapshotKey);
    return hit?.updatedAt;
  }
}