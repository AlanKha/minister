import '../models/transaction.dart';
import '../store/json_store.dart';

class Filters {
  final String? startDate;
  final String? endDate;
  final String? account;
  final String? category;

  Filters({this.startDate, this.endDate, this.account, this.category});
}

List<CleanTransaction> _applyFilters(
    List<CleanTransaction> transactions, Filters filters) {
  var filtered = transactions;

  if (filters.startDate != null) {
    filtered = filtered.where((tx) => tx.date.compareTo(filters.startDate!) >= 0).toList();
  }
  if (filters.endDate != null) {
    filtered = filtered.where((tx) => tx.date.compareTo(filters.endDate!) <= 0).toList();
  }
  if (filters.account != null) {
    final acct = filters.account!.toLowerCase();
    filtered = filtered
        .where((tx) => tx.accountLabel.toLowerCase().contains(acct))
        .toList();
  }
  if (filters.category != null) {
    final cat = filters.category!.toLowerCase();
    filtered = filtered
        .where((tx) => tx.category.toLowerCase() == cat)
        .toList();
  }

  return filtered;
}

List<Map<String, dynamic>> getCategoryBreakdown(Filters filters) {
  final transactions = _applyFilters(loadCleanTransactions(), filters);

  final categories = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final cat = tx.category;
    categories.putIfAbsent(cat, () => {'count': 0, 'total_cents': 0});
    categories[cat]!['count'] = (categories[cat]!['count'] as int) + 1;
    categories[cat]!['total_cents'] =
        (categories[cat]!['total_cents'] as int) + tx.amount;
  }

  final entries = categories.entries.toList()
    ..sort((a, b) =>
        (a.value['total_cents'] as int).compareTo(b.value['total_cents'] as int));

  return entries
      .map((e) => {
            'category': e.key,
            'count': e.value['count'],
            'total_cents': e.value['total_cents'],
            'total':
                '\$${((e.value['total_cents'] as int).abs() / 100).toStringAsFixed(2)}',
          })
      .toList();
}

List<Map<String, dynamic>> getMonthlyBreakdown(Filters filters) {
  final transactions = _applyFilters(loadCleanTransactions(), filters);

  final months = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    final key = '${tx.year}-${tx.month.toString().padLeft(2, '0')}';
    months.putIfAbsent(key, () => {'count': 0, 'total_cents': 0});
    months[key]!['count'] = (months[key]!['count'] as int) + 1;
    months[key]!['total_cents'] =
        (months[key]!['total_cents'] as int) + tx.amount;
  }

  final entries = months.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return entries
      .map((e) => {
            'month': e.key,
            'count': e.value['count'],
            'total_cents': e.value['total_cents'],
            'total':
                '\$${((e.value['total_cents'] as int).abs() / 100).toStringAsFixed(2)}',
          })
      .toList();
}

String _getWeekStart(String dateStr) {
  final d = DateTime.parse('${dateStr}T00:00:00Z');
  final day = d.weekday % 7; // Sunday = 0
  final weekStart = d.subtract(Duration(days: day));
  return weekStart.toIso8601String().substring(0, 10);
}

List<Map<String, dynamic>> getWeeklyBreakdown(Filters filters) {
  final transactions = _applyFilters(loadCleanTransactions(), filters);

  final weeks = <String, Map<String, dynamic>>{};
  for (final tx in transactions) {
    if (tx.date.isEmpty) continue;
    final week = _getWeekStart(tx.date);
    weeks.putIfAbsent(week, () => {'count': 0, 'total_cents': 0});
    weeks[week]!['count'] = (weeks[week]!['count'] as int) + 1;
    weeks[week]!['total_cents'] =
        (weeks[week]!['total_cents'] as int) + tx.amount;
  }

  final entries = weeks.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return entries
      .map((e) => {
            'week_start': e.key,
            'count': e.value['count'],
            'total_cents': e.value['total_cents'],
            'total':
                '\$${((e.value['total_cents'] as int).abs() / 100).toStringAsFixed(2)}',
          })
      .toList();
}
