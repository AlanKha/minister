import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../models/transaction.dart';
import '../widgets/category_chip.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final txPage = ref.watch(transactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: txPage.when(
        data: (page) {
          final tx = page.data
              .where((t) => t.id == widget.transactionId)
              .firstOrNull;
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }
          return _buildDetail(context, theme, tx);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetail(
      BuildContext context, ThemeData theme, CleanTransaction tx) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Amount
        Center(
          child: Text(
            tx.amountFormatted,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: CategoryChip(category: tx.category)),
        const SizedBox(height: 24),

        // Details card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(label: 'Description', value: tx.description),
                const Divider(),
                _DetailRow(label: 'Date', value: tx.date),
                const Divider(),
                _DetailRow(label: 'Status', value: tx.status),
                const Divider(),
                _DetailRow(label: 'Account', value: tx.accountLabel),
                const Divider(),
                _DetailRow(label: 'ID', value: tx.id),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Change category
        Text('Change Category', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCategories.where((c) => c != 'N/A').map((cat) {
            final isSelected = cat == tx.category;
            return FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: _saving
                  ? null
                  : (selected) {
                      if (selected && cat != tx.category) {
                        _updateCategory(tx.id, cat);
                      }
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _updateCategory(String id, String category) async {
    setState(() => _saving = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.updateTransactionCategory(id, category);
      ref.invalidate(transactionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category updated to $category'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
