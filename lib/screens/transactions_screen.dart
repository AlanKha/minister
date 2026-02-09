import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/filter_bar.dart';
import '../theme.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(transactionsProvider);
    final filters = ref.watch(transactionFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              'Transactions',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const FilterBar(),
          Expanded(
            child: page.when(
              data: (txPage) {
                if (txPage.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.surfaceContainer,
                        onRefresh: () async {
                          ref.invalidate(transactionsProvider);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: txPage.data.length,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PaginationButton(
                              icon: Icons.chevron_left_rounded,
                              enabled: filters.page > 1,
                              onTap: () {
                                ref
                                    .read(
                                        transactionFiltersProvider.notifier)
                                    .state = filters.copyWith(
                                        page: filters.page - 1);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '${txPage.page} / ${txPage.totalPages}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            _PaginationButton(
                              icon: Icons.chevron_right_rounded,
                              enabled: filters.page < txPage.totalPages,
                              onTap: () {
                                ref
                                    .read(
                                        transactionFiltersProvider.notifier)
                                    .state = filters.copyWith(
                                        page: filters.page + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
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

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
