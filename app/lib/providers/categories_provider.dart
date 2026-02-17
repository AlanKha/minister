import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minister_shared/models/category_rule.dart';
import 'package:minister_shared/models/transaction.dart';
import 'accounts_provider.dart';
import 'refresh_helpers.dart';

final categoryRulesProvider =
    FutureProvider<List<CategoryRule>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getCategoryRules();
});

final uncategorizedTransactionsProvider =
    FutureProvider<List<CleanTransaction>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getUncategorizedTransactions();
});

final shouldImportDefaultsProvider =
    FutureProvider<bool>((ref) async {
  final client = ref.read(apiClientProvider);
  final result = await client.shouldImportDefaults();
  return result['shouldImport'] as bool? ?? false;
});

// Notifier for managing category rules
class CategoryRulesNotifier extends StateNotifier<AsyncValue<List<CategoryRule>>> {
  CategoryRulesNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadRules();
  }

  final Ref ref;

  Future<void> _loadRules() async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      final rules = await client.getCategoryRules();
      state = AsyncValue.data(rules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createRule({
    required String category,
    required String pattern,
    bool caseSensitive = false,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.createCategoryRule(
        category: category,
        pattern: pattern,
        caseSensitive: caseSensitive,
      );
      await _loadRules();
      // Backend re-cleans all transactions on rule CRUD
      invalidateTransactionsAndAnalytics(ref);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateRule({
    required String id,
    String? category,
    String? pattern,
    bool? caseSensitive,
  }) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.updateCategoryRule(
        id: id,
        category: category,
        pattern: pattern,
        caseSensitive: caseSensitive,
      );
      await _loadRules();
      invalidateTransactionsAndAnalytics(ref);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.deleteCategoryRule(id);
      await _loadRules();
      invalidateTransactionsAndAnalytics(ref);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadRules();
  }

  Future<int> importDefaults() async {
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.importDefaultRules();
      await _loadRules();
      ref.invalidate(shouldImportDefaultsProvider);
      invalidateTransactionsAndAnalytics(ref);
      return result['imported'] as int? ?? 0;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final categoryRulesNotifierProvider =
    StateNotifierProvider<CategoryRulesNotifier, AsyncValue<List<CategoryRule>>>(
  (ref) => CategoryRulesNotifier(ref),
);
