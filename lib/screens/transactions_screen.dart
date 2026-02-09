import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/filter_bar.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(transactionsProvider);
    final filters = ref.watch(transactionFiltersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          const FilterBar(),
          Expanded(
            child: page.when(
              data: (txPage) {
                if (txPage.data.isEmpty) {
                  return const Center(child: Text('No transactions found'));
                }
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(transactionsProvider);
                        },
                        child: ListView.separated(
                          itemCount: txPage.data.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final tx = txPage.data[index];
                            return TransactionTile(
                              transaction: tx,
                              onTap: () =>
                                  context.go('/transactions/${tx.id}'),
                            );
                          },
                        ),
                      ),
                    ),
                    // Pagination
                    if (txPage.totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: filters.page > 1
                                  ? () {
                                      ref
                                          .read(transactionFiltersProvider
                                              .notifier)
                                          .state = filters.copyWith(
                                              page: filters.page - 1);
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              'Page ${txPage.page} of ${txPage.totalPages}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            IconButton(
                              onPressed: filters.page < txPage.totalPages
                                  ? () {
                                      ref
                                          .read(transactionFiltersProvider
                                              .notifier)
                                          .state = filters.copyWith(
                                              page: filters.page + 1);
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 8),
                    Text('Error: $e'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(transactionsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
