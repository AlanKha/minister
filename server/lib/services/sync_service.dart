import '../stripe_client.dart';
import '../models/transaction.dart';
import '../store/json_store.dart';

class SyncResult {
  final int newCount;
  final int totalCount;
  final List<String> errors;

  SyncResult({
    required this.newCount,
    required this.totalCount,
    required this.errors,
  });

  Map<String, dynamic> toJson() => {
        'newCount': newCount,
        'totalCount': totalCount,
        'errors': errors,
      };
}

Future<void> _refreshAccount(String accountId) async {
  await stripeClient.refreshAccount(accountId, ['transactions']);

  const maxAttempts = 30;
  for (var i = 0; i < maxAttempts; i++) {
    final account = await stripeClient.getAccount(accountId);
    final refresh = account['transaction_refresh'] as Map<String, dynamic>?;
    final status = refresh?['status'] as String?;

    if (status == 'succeeded') return;
    if (status == 'failed') throw Exception('Transaction refresh failed');
    if (i == maxAttempts - 1) throw Exception('Refresh timed out after 60s');

    await Future.delayed(const Duration(seconds: 2));
  }
}

Future<List<Map<String, dynamic>>> _fetchTransactions(
    String accountId) async {
  final txs = <Map<String, dynamic>>[];
  String? startingAfter;

  while (true) {
    final page = await stripeClient.listTransactions(
      accountId: accountId,
      limit: 100,
      startingAfter: startingAfter,
    );

    final data = page['data'] as List<dynamic>;
    txs.addAll(data.cast<Map<String, dynamic>>());

    if (page['has_more'] != true) break;
    startingAfter = (data.last as Map<String, dynamic>)['id'] as String;
  }

  return txs;
}

Future<SyncResult> syncFromStripe([List<String>? accountIds]) async {
  final accountData = readAccountData();
  var accounts = accountData.accounts;

  if (accounts.isEmpty) {
    return SyncResult(
        newCount: 0, totalCount: 0, errors: ['No linked accounts found']);
  }

  if (accountIds != null && accountIds.isNotEmpty) {
    final idSet = accountIds.toSet();
    accounts = accounts.where((a) => idSet.contains(a.id)).toList();
    if (accounts.isEmpty) {
      return SyncResult(
          newCount: 0, totalCount: 0, errors: ['No matching accounts found']);
    }
  }

  final existing = loadTransactions();
  final knownIds = existing.map((tx) => tx.id).toSet();
  final newTxs = <StoredTransaction>[];
  final errors = <String>[];

  for (final acct in accounts) {
    final label = accountLabel(acct);

    try {
      await _refreshAccount(acct.id);
    } catch (err) {
      errors.add('[$label] Refresh failed: $err');
      continue;
    }

    try {
      final txs = await _fetchTransactions(acct.id);
      for (final tx in txs) {
        final id = tx['id'] as String;
        if (!knownIds.contains(id)) {
          tx['account_id'] = acct.id;
          tx['account_label'] = label;
          newTxs.add(StoredTransaction(tx));
          knownIds.add(id);
        }
      }
    } catch (err) {
      errors.add('[$label] Fetch failed: $err');
      continue;
    }
  }

  final all = [...existing, ...newTxs];
  all.sort((a, b) => b.transactedAt.compareTo(a.transactedAt));
  saveTransactions(all);

  return SyncResult(
      newCount: newTxs.length, totalCount: all.length, errors: errors);
}
