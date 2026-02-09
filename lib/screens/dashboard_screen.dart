import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/sync_button.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoryBreakdownProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [SyncButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(categoryBreakdownProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            accounts.when(
              data: (accts) => _SummaryCard(
                title: 'Linked Accounts',
                value: '${accts.length}',
                icon: Icons.account_balance,
                theme: theme,
              ),
              loading: () => const _LoadingCard(),
              error: (e, _) => _ErrorCard(error: e.toString()),
            ),
            const SizedBox(height: 12),
            transactions.when(
              data: (page) => _SummaryCard(
                title: 'Total Transactions',
                value: '${page.total}',
                icon: Icons.receipt_long,
                theme: theme,
              ),
              loading: () => const _LoadingCard(),
              error: (e, _) => _ErrorCard(error: e.toString()),
            ),
            const SizedBox(height: 24),
            // Category breakdown chart
            Text('Spending by Category',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            categories.when(
              data: (data) => SizedBox(
                height: 240,
                child: CategoryPieChart(data: data),
              ),
              loading: () =>
                  const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => _ErrorCard(error: e.toString()),
            ),
            const SizedBox(height: 24),
            // Recent transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: const Text('View all'),
                ),
              ],
            ),
            transactions.when(
              data: (page) => Column(
                children: page.data
                    .take(10)
                    .map((tx) => TransactionTile(
                          transaction: tx,
                          onTap: () =>
                              context.go('/transactions/${tx.id}'),
                        ))
                    .toList(),
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(error: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                Text(value, style: theme.textTheme.headlineMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error),
      ),
    );
  }
}
