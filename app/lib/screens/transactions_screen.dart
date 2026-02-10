import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minister_shared/models/transaction.dart';
import '../providers/transactions_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/filter_bar.dart';
import '../theme.dart';

bool get _isDesktop {
  try {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  } catch (_) {
    return false;
  }
}

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(transactionsProvider);
    final filters = ref.watch(transactionFiltersProvider);

    final width = MediaQuery.of(context).size.width;
    final showSidebar = _isDesktop && width > 900;

    final mainContent = _buildMain(context, ref, page, filters);

    if (!showSidebar) return mainContent;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          Expanded(flex: 3, child: mainContent),
          SizedBox(
            width: 280,
            child: _TxSidebar(page: page),
          ),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context, WidgetRef ref, AsyncValue<TransactionPage> page,
      TransactionFilters filters) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Text(
                  'Transactions',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.push('/review-uncategorized'),
                  icon: const Icon(Icons.label_outline, size: 18),
                  label: const Text('Review'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
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
                        backgroundColor: AppColors.surface,
                        onRefresh: () async {
                          ref.invalidate(transactionsProvider);
                        },
                        child: _DateGroupedList(transactions: txPage.data),
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

// ── Date-grouped transaction list ─────────────────────────────
class _DateGroupedList extends StatelessWidget {
  final List<CleanTransaction> transactions;
  const _DateGroupedList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final grouped = <String, List<CleanTransaction>>{};
    for (final tx in transactions) {
      grouped.putIfAbsent(tx.date, () => []).add(tx);
    }

    final entries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: entries.length,
      itemBuilder: (context, groupIndex) {
        final date = entries[groupIndex].key;
        final txList = entries[groupIndex].value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...txList.map((tx) => TransactionTile(
                  transaction: tx,
                  onTap: () => context.go('/transactions/${tx.id}'),
                )),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    // date is like "2025-01-15" — format as "January 15, 2025"
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;
      final year = parts[0];
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      if (month < 1 || month > 12) return date;
      return '${months[month]} $day, $year';
    } catch (_) {
      return date;
    }
  }
}

// ── Desktop sidebar ───────────────────────────────────────────
class _TxSidebar extends StatelessWidget {
  final AsyncValue<TransactionPage> page;
  const _TxSidebar({required this.page});

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
            child: page.when(
              data: (txPage) {
                final txList = txPage.data;
                int totalCents = 0;
                int largest = 0;
                for (final tx in txList) {
                  final abs = tx.amount.abs();
                  totalCents += abs;
                  if (abs > largest) largest = abs;
                }
                final avg = txList.isEmpty
                    ? 0.0
                    : totalCents / txList.length / 100;
                return Column(
                  children: [
                    _SRow(
                        label: 'Transactions',
                        value: '${txPage.total}'),
                    const Divider(color: AppColors.border, height: 20),
                    _SRow(
                      label: 'Total on Page',
                      value:
                          '\$${(totalCents / 100).toStringAsFixed(2)}',
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _SRow(
                      label: 'Largest',
                      value:
                          '\$${(largest / 100).toStringAsFixed(2)}',
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _SRow(
                      label: 'Average',
                      value: '\$${avg.toStringAsFixed(2)}',
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
              error: (_, __) => const Text('--',
                  style: TextStyle(color: AppColors.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SRow extends StatelessWidget {
  final String label;
  final String value;
  const _SRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
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
