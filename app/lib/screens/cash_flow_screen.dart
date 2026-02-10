import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';
import '../theme.dart';
import '../widgets/sankey_chart.dart';

enum PeriodUnit {
  week('Week'),
  month('Month'),
  year('Year'),
  allTime('All Time');

  final String label;
  const PeriodUnit(this.label);
}

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  PeriodUnit _periodUnit = PeriodUnit.month;
  int _periodsAgo = 0; // 0 = this week/month/year, 1 = last week/month/year, etc.

  String _getPeriodLabel() {
    if (_periodUnit == PeriodUnit.allTime) return 'All Time';

    final (start, end) = _getPeriodRange();

    switch (_periodUnit) {
      case PeriodUnit.week:
        // Show week with date range
        final dateFormat = '${_monthName(start.month)} ${start.day}';
        final endFormat = ' - ${_monthName(end.month)} ${end.day - 1}';
        String prefix = _periodsAgo == 0 ? 'This Week' : _periodsAgo == 1 ? 'Last Week' : '$_periodsAgo Weeks Ago';
        return '$prefix ($dateFormat$endFormat)';

      case PeriodUnit.month:
        // Show just month name and year
        if (_periodsAgo == 0) {
          return '${_monthName(start.month)} ${start.year}';
        } else {
          return '${_monthName(start.month)} ${start.year}';
        }

      case PeriodUnit.year:
        // Show just year
        return '${start.year}';

      case PeriodUnit.allTime:
        return 'All Time';
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  (DateTime start, DateTime end) _getPeriodRange() {
    final now = DateTime.now();

    switch (_periodUnit) {
      case PeriodUnit.week:
        // Start of this week (Monday)
        final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfThisWeek = DateTime(thisWeekStart.year, thisWeekStart.month, thisWeekStart.day);

        // Go back by _periodsAgo weeks
        final periodStart = startOfThisWeek.subtract(Duration(days: _periodsAgo * 7));
        final periodEnd = periodStart.add(const Duration(days: 7));

        return (periodStart, periodEnd);

      case PeriodUnit.month:
        // Calculate total months from year 0, then subtract periodsAgo
        final totalMonths = now.year * 12 + now.month - 1; // -1 because months are 1-indexed
        final targetTotalMonths = totalMonths - _periodsAgo;

        final targetYear = targetTotalMonths ~/ 12;
        final targetMonth = (targetTotalMonths % 12) + 1; // +1 to get back to 1-indexed

        final periodStart = DateTime(targetYear, targetMonth, 1);

        // End is start of next month
        final periodEnd = DateTime(
          targetMonth == 12 ? targetYear + 1 : targetYear,
          targetMonth == 12 ? 1 : targetMonth + 1,
          1,
        );

        return (periodStart, periodEnd);

      case PeriodUnit.year:
        final targetYear = now.year - _periodsAgo;
        final periodStart = DateTime(targetYear, 1, 1);
        final periodEnd = DateTime(targetYear + 1, 1, 1);

        return (periodStart, periodEnd);

      case PeriodUnit.allTime:
        // Return a very wide range
        return (DateTime(2000, 1, 1), DateTime(2100, 1, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final txPage = ref.watch(allTransactionsProvider);

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
    final (periodStart, periodEnd) = _getPeriodRange();
    final filteredTransactions = transactions.where((tx) {
      final dateStr = tx.data['date'] as String?;
      if (dateStr == null) return false;
      final txDate = DateTime.parse(dateStr);
      return txDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
             txDate.isBefore(periodEnd);
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
          // Period selector header - ALWAYS VISIBLE
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
                // Period unit selector
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<PeriodUnit>(
                    value: _periodUnit,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    items: PeriodUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _periodUnit = value;
                          _periodsAgo = 0; // Reset to "This" when changing unit
                        });
                      }
                    },
                  ),
                ),
                if (_periodUnit != PeriodUnit.allTime) ...[
                  const SizedBox(width: 12),
                  // Navigation arrows
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _periodsAgo++;
                            });
                          },
                          tooltip: 'Previous ${_periodUnit.label.toLowerCase()}',
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          constraints: const BoxConstraints(minWidth: 120),
                          child: Text(
                            _getPeriodLabel(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 20),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: _periodsAgo > 0
                              ? () {
                                  setState(() {
                                    _periodsAgo--;
                                  });
                                }
                              : null,
                          tooltip: 'Next ${_periodUnit.label.toLowerCase()}',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Metric cards - ALWAYS SHOW
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
                    totalSpending > 0 ? '\$${(totalSpending / 100).toStringAsFixed(2)}' : '...',
                    AppColors.negative,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'AVG PER TRANSACTION',
                    totalSpending > 0 ? '\$${(avgSpending / 100).toStringAsFixed(2)}' : '...',
                    AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'TOP CATEGORY',
                    totalSpending > 0 ? (largestCategory?.key ?? 'N/A') : '...',
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'TOP CATEGORY %',
                    totalSpending > 0 ? '${topCategoryPercent.toStringAsFixed(1)}%' : '...',
                    AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Conditional chart content
          if (totalSpending > 0)
            // Sankey diagram
            Container(
              height: 500,
              margin: const EdgeInsets.all(20),
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
            // Empty state
            Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  const Icon(Icons.waterfall_chart_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No spending data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _periodUnit == PeriodUnit.allTime
                        ? 'No transactions found. Sync your accounts to import data.'
                        : 'No transactions in ${_getPeriodLabel()}.\nTry clicking ← to view previous periods.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  ),
                ],
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
