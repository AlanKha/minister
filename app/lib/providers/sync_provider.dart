import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accounts_provider.dart';
import 'refresh_helpers.dart';

class SyncState {
  final bool isSyncing;
  final String? lastResult;
  final String? error;

  const SyncState({this.isSyncing = false, this.lastResult, this.error});
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref ref;

  SyncNotifier(this.ref) : super(const SyncState());

  Future<void> syncAll() async {
    state = const SyncState(isSyncing: true);
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.sync();
      final fetch = result['fetch'] as Map<String, dynamic>;
      final clean = result['clean'] as Map<String, dynamic>;
      state = SyncState(
        lastResult:
            'Fetched ${fetch['newCount']} new, cleaned ${clean['count']} total',
      );
      _refreshAll();
    } catch (e) {
      state = SyncState(error: e.toString());
    }
  }

  Future<void> cleanOnly() async {
    state = const SyncState(isSyncing: true);
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.syncClean();
      state = SyncState(lastResult: 'Cleaned ${result['count']} transactions');
      _refreshAll();
    } catch (e) {
      state = SyncState(error: e.toString());
    }
  }

  void _refreshAll() {
    invalidateTransactionsAndAnalytics(ref);
    invalidateAccounts(ref);
  }
}

final syncProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) => SyncNotifier(ref));
