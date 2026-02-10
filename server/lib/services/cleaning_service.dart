import 'package:minister_shared/models/transaction.dart';
import '../category_rules.dart';
import '../store/json_store.dart';

const _dropFields = [
  'object',
  'account',
  'livemode',
  'updated',
  'transaction_refresh',
  'transacted_at',
];

String categorize(
    String description, String transactionId, Map<String, String> overrides) {
  final override = overrides[transactionId];
  if (override != null) return override;

  for (final entry in categoryRules) {
    if (entry.key.hasMatch(description)) return entry.value;
  }
  return 'Uncategorized';
}

CleanTransaction cleanTransaction(
    StoredTransaction tx, Map<String, String> overrides) {
  final cleaned = <String, dynamic>{};

  for (final entry in tx.data.entries) {
    if (!_dropFields.contains(entry.key)) {
      cleaned[entry.key] = entry.value;
    }
  }

  cleaned['category'] = categorize(tx.description, tx.id, overrides);

  final transactedAt = tx.data['transacted_at'];
  if (transactedAt is int) {
    final d = DateTime.fromMillisecondsSinceEpoch(transactedAt * 1000, isUtc: true);
    cleaned['date'] = d.toIso8601String().substring(0, 10);
    cleaned['year'] = d.year;
    cleaned['month'] = d.month;
  }

  final st = tx.data['status_transitions'];
  if (st is Map) {
    final normalized = <String, dynamic>{};
    for (final entry in st.entries) {
      if (entry.value is int) {
        final d = DateTime.fromMillisecondsSinceEpoch(
            (entry.value as int) * 1000,
            isUtc: true);
        normalized[entry.key as String] = d.toIso8601String().substring(0, 10);
      } else {
        normalized[entry.key as String] = entry.value;
      }
    }
    cleaned['status_transitions'] = normalized;
  }

  return CleanTransaction(cleaned);
}

List<CleanTransaction> cleanAllTransactions() {
  final transactions = loadTransactions();
  final overrides = loadOverrides();

  final cleaned = transactions
      .where((tx) => tx.amount < 0)
      .map((tx) => cleanTransaction(tx, overrides))
      .toList();

  saveCleanTransactions(cleaned);
  return cleaned;
}
