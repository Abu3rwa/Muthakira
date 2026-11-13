/// Wallet entities. Credits and SDG are whole integers; marks may be decimal.
library;

import '../../../core/utils/parse.dart';

class WalletSnapshot {
  const WalletSnapshot({
    required this.balance,
    required this.reserved,
    required this.available,
    this.nextExpiryAt,
  });

  factory WalletSnapshot.fromJson(Map<String, Object?> json) => WalletSnapshot(
    balance: Parse.integer(json['balance']),
    reserved: Parse.integer(json['reserved']),
    available: Parse.integer(json['available']),
    nextExpiryAt: Parse.date(json['next_expiry_at']),
  );

  static const WalletSnapshot empty = WalletSnapshot(balance: 0, reserved: 0, available: 0);

  final int balance;
  final int reserved;
  final int available;
  final DateTime? nextExpiryAt;

  bool get hasReserved => reserved > 0;

  Map<String, Object?> toJson() => <String, Object?>{
    'balance': balance,
    'reserved': reserved,
    'available': available,
    'next_expiry_at': nextExpiryAt?.toIso8601String(),
  };
}

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.entryType,
    required this.amount,
    required this.createdAt,
    this.lotId,
    this.paymentId,
    this.reason,
  });

  factory LedgerEntry.fromJson(Map<String, Object?> json) => LedgerEntry(
    id: Parse.string(json['id']),
    entryType: Parse.string(json['entry_type'], fallback: 'unknown'),
    amount: Parse.integer(json['amount']),
    createdAt: Parse.date(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    lotId: Parse.stringOrNull(json['lot_id']),
    paymentId: Parse.stringOrNull(json['payment_id']),
    reason: Parse.stringOrNull(json['reason']),
  );

  final String id;
  final String entryType;
  final int amount;
  final DateTime createdAt;
  final String? lotId;
  final String? paymentId;
  final String? reason;

  bool get isCredit => amount > 0;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'entry_type': entryType,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
    'lot_id': lotId,
    'payment_id': paymentId,
    'reason': reason,
  };
}

class LedgerPage {
  const LedgerPage({required this.items, this.nextCursor});

  factory LedgerPage.fromJson(Map<String, Object?> json) => LedgerPage(
    items: Parse.mapList(json['items']).map(LedgerEntry.fromJson).toList(growable: false),
    nextCursor: Parse.stringOrNull(json['next_cursor']),
  );

  final List<LedgerEntry> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && items.isNotEmpty;
}