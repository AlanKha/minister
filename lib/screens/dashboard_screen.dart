import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/sync_button.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
import '../theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoryBreakdownProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceContainer,
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

            // Summary cards row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: accounts.when(
                        data: (accts) => _MetricCard(
                          label: 'ACCOUNTS',
                          value: '${accts.length}',
                          icon: Icons.account_balance_outlined,
                          accentColor: AppColors.info,
                        ),
                        loading: () => const _MetricCardLoading(),
                        error: (e, _) =>
                            _MetricCardError(error: e.toString()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: transactions.when(
                        data: (page) => _MetricCard(
                          label: 'TRANSACTIONS',
                          value: '${page.total}',
                          icon: Icons.receipt_long_outlined,
                          accentColor: AppColors.accent,
                        ),
                        loading: () => const _MetricCardLoading(),
                        error: (e, _) =>
                            _MetricCardError(error: e.toString()),
                      ),
                    ),
                  ],
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
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
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
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: page.data.take(8).map((tx) {
                          return TransactionTile(
                            transaction: tx,
                            onTap: () =>
                                context.go('/transactions/${tx.id}'),
                          );
                        }).toList(),
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

// ── Metric Card ────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(18),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
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
