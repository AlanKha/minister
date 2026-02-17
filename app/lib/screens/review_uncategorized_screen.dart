import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minister_shared/models/transaction.dart';
import '../providers/categories_provider.dart';
import '../providers/accounts_provider.dart';
import '../providers/refresh_helpers.dart';
import '../utils/snackbar_helpers.dart';
import '../theme.dart';
import '../widgets/category_chip.dart';

class ReviewUncategorizedScreen extends ConsumerWidget {
  const ReviewUncategorizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(uncategorizedTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Uncategorized'),
      ),
      body: transactionsAsync.when(
        data: (transactions) => _buildContent(context, ref, transactions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.negative),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: AppColors.negative)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(uncategorizedTransactionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<CleanTransaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.positive),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'All transactions are categorized',
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${transactions.length} uncategorized ${transactions.length == 1 ? 'transaction' : 'transactions'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionCard(context, ref, tx);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WidgetRef ref,
    CleanTransaction tx,
  ) {
    final amount = (tx.data['amount'] as int?) ?? 0;
    final description = tx.data['description'] as String? ?? 'Unknown';
    final date = tx.data['date'] as String? ?? '';
    final accountLabel = tx.data['accountLabel'] as String? ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (accountLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          accountLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '\$${(amount.abs() / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: amount >= 0 ? AppColors.positive : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQuickCategorize(context, ref, tx, description),
                    icon: const Icon(Icons.category_outlined, size: 18),
                    label: const Text('Categorize'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCreateRuleDialog(context, ref, tx, description),
                    icon: const Icon(Icons.rule_outlined, size: 18),
                    label: const Text('Create Rule'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickCategorize(
    BuildContext context,
    WidgetRef ref,
    CleanTransaction tx,
    String description,
  ) {
    final categories = [
      'Dining',
      'Grocery',
      'Shopping',
      'Superstore',
      'Transit',
      'Gas',
      'Rent',
      'Utilities',
      'Transfer',
      'Fee',
      'Loan',
      'Entertainment',
      'Travel',
      'Subscription',
      'Medical',
      'Personal Care',
      'Professional Services',
      'Education',
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...categories.map((category) => ListTile(
                leading: CategoryChip(category: category, dense: true),
                title: Text(category),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final client = ref.read(apiClientProvider);
                    await client.categorizeTransaction(
                      id: tx.id,
                      category: category,
                    );
                    invalidateTransactionsAndAnalyticsWidget(ref);
                    if (context.mounted) {
                      showSuccessSnackbar(context, 'Categorized as $category');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showErrorSnackbar(context, 'Error: $e');
                    }
                  }
                },
              )),
        ],
      ),
    );
  }

  void _showCreateRuleDialog(
    BuildContext context,
    WidgetRef ref,
    CleanTransaction tx,
    String description,
  ) {
    final patternController = TextEditingController(text: description);
    String selectedCategory = 'Dining';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Categorization Rule'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will categorize this transaction and create a rule for similar ones.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: (allCategories
                          .where((c) => c != 'Uncategorized')
                          .toList()
                        ..sort())
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val ?? 'Dining'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pattern',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: patternController,
                  decoration: const InputDecoration(
                    hintText: 'Regex pattern to match',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Simplify to match similar transactions (e.g., "STARBUCKS" instead of full description)',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (patternController.text.isEmpty) {
                  showErrorSnackbar(context, 'Please enter a pattern');
                  return;
                }

                try {
                  final client = ref.read(apiClientProvider);
                  await client.categorizeTransaction(
                    id: tx.id,
                    category: selectedCategory,
                    createRule: true,
                    rulePattern: patternController.text,
                  );
                  invalidateTransactionsAndAnalyticsWidget(ref);
                  ref.read(categoryRulesNotifierProvider.notifier).refresh();
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    showSuccessSnackbar(context, 'Categorized and rule created for $selectedCategory');
                  }
                } catch (e) {
                  if (context.mounted) {
                    showErrorSnackbar(context, 'Error: $e');
                  }
                }
              },
              child: const Text('Create & Categorize'),
            ),
          ],
        ),
      ),
    );
  }
}
