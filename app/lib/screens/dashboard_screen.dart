import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minister_shared/models/account.dart';
import 'package:minister_shared/models/analytics.dart';
import 'package:minister_shared/models/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/sync_button.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
import '../theme.dart';

bool get _isDesktop {
  try {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  } catch (_) {
    return false;
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoryBreakdownProvider);

    final width = MediaQuery.of(context).size.width;
    final showSidebar = _isDesktop && width > 900;

    final mainContent = _buildMainContent(
        context, ref, accounts, transactions, categories, width);

    if (!showSidebar) return mainContent;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          Expanded(flex: 3, child: mainContent),
          SizedBox(
            width: 280,
            child: _DesktopSidebar(
              accounts: accounts,
              transactions: transactions,
              categories: categories,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LinkedAccount>> accounts,
    AsyncValue<TransactionPage> transactions,
    AsyncValue<List<CategoryBreakdown>> categories,
    double width,
  ) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(categoryBreakdownProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your financial snapshot',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SyncButton(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 4 Metric cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MetricCardsGrid(
                  accounts: accounts,
                  transactions: transactions,
                  categories: categories,
                  narrow: width < 600,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Spending chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spending by Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      categories.when(
                        data: (data) => SizedBox(
                          height: 200,
                          child: CategoryPieChart(data: data),
                        ),
                        loading: () => const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        error: (e, _) => SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'Failed to load',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Recent transactions header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/transactions'),
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Recent transactions list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: transactions.when(
                  data: (page) {
                    if (page.data.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No transactions yet',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                        ),
                      );
                    }
                    final items = page.data.take(8).toList();
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.border,
                        ),
                        itemBuilder: (context, index) {
                          final tx = items[index];
                          return TransactionTile(
                            transaction: tx,
                            onTap: () =>
                                context.go('/transactions/${tx.id}'),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Failed to load transactions',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── 4 Metric Cards Grid ───────────────────────────────────────
class _MetricCardsGrid extends StatelessWidget {
  final AsyncValue<List<LinkedAccount>> accounts;
  final AsyncValue<TransactionPage> transactions;
  final AsyncValue<List<CategoryBreakdown>> categories;
  final bool narrow;

  const _MetricCardsGrid({
    required this.accounts,
    required this.transactions,
    required this.categories,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    final accountsCard = accounts.when(
      data: (accts) =>
          _MetricCard(label: 'ACCOUNTS', value: '${accts.length}'),
      loading: () => const _MetricCardLoading(),
      error: (e, _) => _MetricCardError(error: e.toString()),
    );

    final txCountCard = transactions.when(
      data: (page) => _MetricCard(label: 'TRANSACTIONS', value: '${page.total}'),
      loading: () => const _MetricCardLoading(),
      error: (e, _) => _MetricCardError(error: e.toString()),
    );

    final spendingCard = categories.when(
      data: (cats) {
        int totalCents = 0;
        for (final c in cats) {
          totalCents += c.totalCents.abs();
        }
        return _MetricCard(
          label: 'TOTAL SPENDING',
          value: '\$${(totalCents / 100).toStringAsFixed(0)}',
        );
      },
      loading: () => const _MetricCardLoading(),
      error: (e, _) => _MetricCardError(error: e.toString()),
    );

    final avgCard = _buildAvgCard();

    if (narrow) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: accountsCard),
            const SizedBox(width: 12),
            Expanded(child: txCountCard),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: spendingCard),
            const SizedBox(width: 12),
            Expanded(child: avgCard),
          ]),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: accountsCard),
        const SizedBox(width: 12),
        Expanded(child: txCountCard),
        const SizedBox(width: 12),
        Expanded(child: spendingCard),
        const SizedBox(width: 12),
        Expanded(child: avgCard),
      ],
    );
  }

  Widget _buildAvgCard() {
    // Need both categories (for total) and transactions (for count)
    return categories.when(
      data: (cats) {
        return transactions.when(
          data: (page) {
            int totalCents = 0;
            for (final c in cats) {
              totalCents += c.totalCents.abs();
            }
            final count = page.total;
            final avg = count > 0 ? totalCents / count / 100 : 0.0;
            return _MetricCard(
              label: 'AVG TRANSACTION',
              value: '\$${avg.toStringAsFixed(0)}',
            );
          },
          loading: () => const _MetricCardLoading(),
          error: (e, _) => _MetricCardError(error: e.toString()),
        );
      },
      loading: () => const _MetricCardLoading(),
      error: (e, _) => _MetricCardError(error: e.toString()),
    );
  }
}

// ── Metric Card ────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardLoading extends StatelessWidget {
  const _MetricCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _MetricCardError extends StatelessWidget {
  final String error;
  const _MetricCardError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.negative.withValues(alpha: 0.3)),
      ),
      child: Text(
        error,
        style: const TextStyle(fontSize: 12, color: AppColors.negative),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Desktop Summary Sidebar ───────────────────────────────────
class _DesktopSidebar extends StatelessWidget {
  final AsyncValue<List<LinkedAccount>> accounts;
  final AsyncValue<TransactionPage> transactions;
  final AsyncValue<List<CategoryBreakdown>> categories;

  const _DesktopSidebar({
    required this.accounts,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                accounts.when(
                  data: (accts) => _SummaryRow(
                      label: 'Total Accounts',
                      value: '${accts.length}'),
                  loading: () =>
                      const _SummaryRow(label: 'Total Accounts', value: '...'),
                  error: (_, __) =>
                      const _SummaryRow(label: 'Total Accounts', value: '--'),
                ),
                const Divider(color: AppColors.border, height: 20),
                transactions.when(
                  data: (page) => _SummaryRow(
                      label: 'Total Transactions', value: '${page.total}'),
                  loading: () => const _SummaryRow(
                      label: 'Total Transactions', value: '...'),
                  error: (_, __) => const _SummaryRow(
                      label: 'Total Transactions', value: '--'),
                ),
                const Divider(color: AppColors.border, height: 20),
                categories.when(
                  data: (cats) {
                    int totalCents = 0;
                    for (final c in cats) {
                      totalCents += c.totalCents.abs();
                    }
                    return _SummaryRow(
                      label: 'Total Spending',
                      value:
                          '\$${(totalCents / 100).toStringAsFixed(2)}',
                    );
                  },
                  loading: () => const _SummaryRow(
                      label: 'Total Spending', value: '...'),
                  error: (_, __) => const _SummaryRow(
                      label: 'Total Spending', value: '--'),
                ),
                const Divider(color: AppColors.border, height: 20),
                _buildAvgRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvgRow() {
    return categories.when(
      data: (cats) {
        return transactions.when(
          data: (page) {
            int totalCents = 0;
            for (final c in cats) {
              totalCents += c.totalCents.abs();
            }
            final count = page.total;
            final avg = count > 0 ? totalCents / count / 100 : 0.0;
            return _SummaryRow(
              label: 'Avg Transaction',
              value: '\$${avg.toStringAsFixed(2)}',
            );
          },
          loading: () =>
              const _SummaryRow(label: 'Avg Transaction', value: '...'),
          error: (_, __) =>
              const _SummaryRow(label: 'Avg Transaction', value: '--'),
        );
      },
      loading: () =>
          const _SummaryRow(label: 'Avg Transaction', value: '...'),
      error: (_, __) =>
          const _SummaryRow(label: 'Avg Transaction', value: '--'),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
