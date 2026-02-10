import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';
import '../theme.dart';
import '../widgets/sankey_chart.dart';

enum TimePeriod {
  week('Last 7 Days', 7),
  month('Last 30 Days', 30),
  quarter('Last 90 Days', 90),
  year('Last Year', 365),
  allTime('All Time', null);

  final String label;
  final int? days;
  const TimePeriod(this.label, this.days);
}

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  @override
  Widget build(BuildContext context) {
    final txPage = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow'),
        elevation: 0,
      ),
      body: txPage.when(
        data: (page) => _buildContent(context, page.data),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.negative),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: AppColors.negative)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waterfall_chart_outlined, size: 64, color: AppColors.textTertiary),
              SizedBox(height: 16),
              Text(
                'No transaction data available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sync your accounts to see cash flow visualization',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    // Filter transactions by selected time period
    final now = DateTime.now();
    final filteredTransactions = _selectedPeriod.days == null
        ? transactions
        : transactions.where((tx) {
            final dateStr = tx.data['date'] as String?;
            if (dateStr == null) return false;
            final txDate = DateTime.parse(dateStr);
            final cutoff = now.subtract(Duration(days: _selectedPeriod.days!));
            return txDate.isAfter(cutoff);
          }).toList();

    // Calculate category spending
    int totalSpending = 0;
    final categoryTotals = <String, int>{};

    for (final tx in filteredTransactions) {
      final amount = (tx.data['amount'] as int?) ?? 0;
      final category = tx.data['category'] as String? ?? 'Uncategorized';

      // Only count negative amounts (expenses)
      if (amount < 0) {
        final absAmount = amount.abs();
        totalSpending += absAmount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + absAmount;
      }
    }

    // Sort categories by spending
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // If no spending data, show empty state
    if (totalSpending == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waterfall_chart_outlined, size: 64, color: AppColors.textTertiary),
              SizedBox(height: 16),
              Text(
                'No spending data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Transaction data needed for visualization',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    // Create Sankey data
    final nodes = <SankeyNode>[];
    final links = <SankeyLink>[];

    // Total spending node (level 0)
    nodes.add(SankeyNode(
      label: 'Total Spending',
      value: totalSpending.toDouble(),
      color: AppColors.negative,
      level: 0,
    ));

    // Category colors
    final categoryColors = {
      'Dining': const Color(0xFFE8642C),
      'Grocery': const Color(0xFF5CB88A),
      'Shopping': const Color(0xFF7B61FF),
      'Superstore': const Color(0xFF4A90E2),
      'Transit': const Color(0xFFE56B6F),
      'Gas': const Color(0xFFFFB84D),
      'Rent': const Color(0xFFFF6B9D),
      'Utilities': const Color(0xFF6495ED),
      'Transfer': const Color(0xFF9B59B6),
      'Fee': const Color(0xFFE74C3C),
      'Loan': const Color(0xFFD63384),
      'Entertainment': const Color(0xFFFFA500),
      'Travel': const Color(0xFF20B2AA),
      'Subscription': const Color(0xFF8B5CF6),
      'Medical': const Color(0xFFDC143C),
    };

    // Add top 10 categories as nodes (level 1)
    for (final entry in sortedCategories.take(10)) {
      final color = categoryColors[entry.key] ?? AppColors.accent;

      nodes.add(SankeyNode(
        label: entry.key,
        value: entry.value.toDouble(),
        color: color,
        level: 1,
      ));

      links.add(SankeyLink(
        source: 'Total Spending',
        target: entry.key,
        value: entry.value.toDouble(),
        color: color,
      ));
    }

    // Calculate additional metrics
    final avgPerTransaction = filteredTransactions.where((tx) => (tx.data['amount'] as int?) != null && (tx.data['amount'] as int) < 0).length;
    final avgSpending = avgPerTransaction > 0 ? totalSpending / avgPerTransaction : 0;
    final largestCategory = sortedCategories.isNotEmpty ? sortedCategories.first : null;
    final topCategoryPercent = largestCategory != null ? (largestCategory.value / totalSpending * 100) : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Metric cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'TOTAL SPENDING',
                    '\$${(totalSpending / 100).toStringAsFixed(2)}',
                    AppColors.negative,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'AVG PER TRANSACTION',
                    '\$${(avgSpending / 100).toStringAsFixed(2)}',
                    AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'TOP CATEGORY',
                    largestCategory?.key ?? 'N/A',
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'TOP CATEGORY %',
                    '${topCategoryPercent.toStringAsFixed(1)}%',
                    AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Sankey diagram header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SPENDING BREAKDOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top ${sortedCategories.take(10).length} Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Time period dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<TimePeriod>(
                    value: _selectedPeriod,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    items: TimePeriod.values.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Sankey diagram
          if (nodes.isNotEmpty && links.isNotEmpty)
            Container(
              height: 500,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(32),
              child: SankeyChart(
                nodes: nodes,
                links: links,
                totalIncome: totalSpending.toDouble(),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No cash flow data available',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color valueColor) {
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
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
