/// The shared balance. Every feature reads it; unlock and payment approval
/// refresh it so no screen shows a stale number.
library;

import 'package:flutter/foundation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/utils/screen_state.dart';
import '../data/wallet_repository_impl.dart';
import '../domain/entities.dart';
import '../domain/wallet_repository.dart';

class WalletController extends ChangeNotifier {
  WalletController({required WalletRepository repository}) : _repository = repository;

  final WalletRepository _repository;

  WalletSnapshot _snapshot = WalletSnapshot.empty;
  ScreenState<WalletSnapshot> _state = const ScreenLoading<WalletSnapshot>();
  DateTime? _updatedAt;
  bool _isRefreshing = false;
  bool _disposed = false;

  WalletSnapshot get snapshot => _snapshot;
  ScreenState<WalletSnapshot> get state => _state;
  DateTime? get updatedAt => _updatedAt;
  bool get isRefreshing => _isRefreshing;
  int get available => _snapshot.available;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> load() async {
    final WalletRepository repository = _repository;
    final ApiWalletRepository? cached = repository is ApiWalletRepository ? repository : null;
    if (cached != null) {
      final WalletSnapshot? saved = await cached.cachedWallet();
      if (saved != null) {
        _snapshot = saved;
        _updatedAt = await cached.cachedWalletUpdatedAt();
        _state = ScreenData<WalletSnapshot>(saved);
        notifyListeners();
      }
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();
    try {
      final WalletSnapshot next = await _repository.fetchWallet();
      _snapshot = next;
      _updatedAt = DateTime.now();
      _state = ScreenData<WalletSnapshot>(next);
    } on AppFailure catch (failure) {
      if (_state is! ScreenData<WalletSnapshot>) {
        _state = ScreenError<WalletSnapshot>(failure);
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void reset() {
    _snapshot = WalletSnapshot.empty;
    _state = const ScreenLoading<WalletSnapshot>();
    _updatedAt = null;
    notifyListeners();
  }
}