import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transactions_provider.dart';
import 'analytics_provider.dart';
import 'accounts_provider.dart';
import 'balances_provider.dart';
import 'categories_provider.dart';

/// Invalidate all transaction-related providers (list, analytics, uncategorized).
/// Use after any operation that changes transaction data or categories.
void invalidateTransactions(Ref ref) {
  ref.invalidate(transactionsProvider);
  ref.invalidate(allTransactionsProvider);
  ref.invalidate(uncategorizedTransactionsProvider);
}

/// Invalidate analytics breakdown providers.
void invalidateAnalytics(Ref ref) {
  ref.invalidate(categoryBreakdownProvider);
  ref.invalidate(monthlyBreakdownProvider);
  ref.invalidate(weeklyBreakdownProvider);
}

/// Invalidate everything related to transactions and their analytics.
/// Use after category rule changes, recategorization, etc.
void invalidateTransactionsAndAnalytics(Ref ref) {
  invalidateTransactions(ref);
  invalidateAnalytics(ref);
}

/// Invalidate account-related providers.
void invalidateAccounts(Ref ref) {
  ref.invalidate(accountsProvider);
  ref.invalidate(balancesProvider);
}

/// Invalidate category rules.
void invalidateCategoryRules(Ref ref) {
  ref.invalidate(categoryRulesNotifierProvider);
}

/// Full refresh of everything. Use after backup restore or sync.
void invalidateAll(Ref ref) {
  invalidateTransactionsAndAnalytics(ref);
  invalidateAccounts(ref);
  invalidateCategoryRules(ref);
}

// WidgetRef variants for use in widgets/screens

void invalidateTransactionsWidget(WidgetRef ref) {
  ref.invalidate(transactionsProvider);
  ref.invalidate(allTransactionsProvider);
  ref.invalidate(uncategorizedTransactionsProvider);
}

void invalidateAnalyticsWidget(WidgetRef ref) {
  ref.invalidate(categoryBreakdownProvider);
  ref.invalidate(monthlyBreakdownProvider);
  ref.invalidate(weeklyBreakdownProvider);
}

void invalidateTransactionsAndAnalyticsWidget(WidgetRef ref) {
  invalidateTransactionsWidget(ref);
  invalidateAnalyticsWidget(ref);
}

void invalidateAccountsWidget(WidgetRef ref) {
  ref.invalidate(accountsProvider);
  ref.invalidate(balancesProvider);
}

void invalidateCategoryRulesWidget(WidgetRef ref) {
  ref.invalidate(categoryRulesNotifierProvider);
}

void invalidateAllWidget(WidgetRef ref) {
  invalidateTransactionsAndAnalyticsWidget(ref);
  invalidateAccountsWidget(ref);
  invalidateCategoryRulesWidget(ref);
}
