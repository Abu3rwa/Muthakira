/// Wallet contract: the balance snapshot and the cursor-paged ledger.
library;

import 'entities.dart';

abstract interface class WalletRepository {
  Future<WalletSnapshot> fetchWallet();
  Future<LedgerPage> fetchLedger({int limit = 50, String? cursor});
}