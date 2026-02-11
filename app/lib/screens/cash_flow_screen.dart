import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/transactions_provider.dart';
import '../providers/analytics_provider.dart';
import '../theme.dart';
import '../widgets/sankey_chart.dart';
import '../widgets/spending_chart.dart';

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

class _CashFlowScreenState extends ConsumerState<CashFlowScreen>
    with SingleTickerProviderStateMixin {
  PeriodUnit _periodUnit = PeriodUnit.month;
  int _periodsAgo = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getPeriodLabel() {
    if (_periodUnit == PeriodUnit.allTime) return 'All Time';

    final (start, end) = _getPeriodRange();

    switch (_periodUnit) {
      case PeriodUnit.week:
        final dateFormat = '${_monthName(start.month)} ${start.day}';
        final endFormat = ' - ${_monthName(end.month)} ${end.day - 1}';
        String prefix = _periodsAgo == 0
            ? 'This Week'
            : _periodsAgo == 1
            ? 'Last Week'
            : '$_periodsAgo Weeks Ago';
        return '$prefix ($dateFormat$endFormat)';

      case PeriodUnit.month:
        return '${_monthName(start.month)} ${start.year}';

      case PeriodUnit.year:
        return '${start.year}';

      case PeriodUnit.allTime:
        return 'All Time';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  (DateTime start, DateTime end) _getPeriodRange() {
    final now = DateTime.now();

    switch (_periodUnit) {
      case PeriodUnit.week:
        final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfThisWeek = DateTime(
          thisWeekStart.year,
          thisWeekStart.month,
          thisWeekStart.day,
        );
        final periodStart = startOfThisWeek.subtract(
          Duration(days: _periodsAgo * 7),
        );
        final periodEnd = periodStart.add(const Duration(days: 7));
        return (periodStart, periodEnd);

      case PeriodUnit.month:
        final totalMonths = now.year * 12 + now.month - 1;
        final targetTotalMonths = totalMonths - _periodsAgo;
        final targetYear = targetTotalMonths ~/ 12;
        final targetMonth = (targetTotalMonths % 12) + 1;
        final periodStart = DateTime(targetYear, targetMonth, 1);
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
        return (DateTime(2000, 1, 1), DateTime(2100, 1, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cash Flow',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analyze your spending patterns',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.15),
                    ),
                  ),
                  dividerHeight: 0,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.textTertiary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Monthly'),
                    Tab(text: 'Weekly'),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildMonthlyTab(),
            _buildWeeklyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final txPage = ref.watch(allTransactionsProvider);

    return txPage.when(
      data: (page) => _buildOverviewContent(page.data),
      loading: () => const _OverviewLoading(),
      error: (err, stack) => _ErrorState(error: err.toString()),
    );
  }

  Widget _buildOverviewContent(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return const _EmptyState();
    }

    final (periodStart, periodEnd) = _getPeriodRange();
    final filteredTransactions = transactions.where((tx) {
      final dateStr = tx.data['date'] as String?;
      if (dateStr == null) return false;
      final txDate = DateTime.parse(dateStr);
      return txDate.isAfter(periodStart.subtract(const Duration(days: 1))) &&
          txDate.isBefore(periodEnd);
    }).toList();

    int totalSpending = 0;
    final categoryTotals = <String, int>{};

    for (final tx in filteredTransactions) {
      final amount = (tx.data['amount'] as int?) ?? 0;
      final category = tx.data['category'] as String? ?? 'Uncategorized';

      if (amount < 0) {
        final absAmount = amount.abs();
        totalSpending += absAmount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + absAmount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final nodes = <SankeyNode>[];
    final links = <SankeyLink>[];

    nodes.add(
      SankeyNode(
        label: 'Total Spending',
        value: totalSpending.toDouble(),
        color: AppColors.negative,
        level: 0,
      ),
    );

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

    for (final entry in sortedCategories.take(10)) {
      final color = categoryColors[entry.key] ?? AppColors.accent;

      nodes.add(
        SankeyNode(
          label: entry.key,
          value: entry.value.toDouble(),
          color: color,
          level: 1,
        ),
      );

      links.add(
        SankeyLink(
          source: 'Total Spending',
          target: entry.key,
          value: entry.value.toDouble(),
          color: color,
        ),
      );
    }

    final avgPerTransaction = filteredTransactions
        .where(
          (tx) =>
              (tx.data['amount'] as int?) != null &&
              (tx.data['amount'] as int) < 0,
        )
        .length;
    final avgSpending = avgPerTransaction > 0
        ? (totalSpending / avgPerTransaction).toDouble()
        : 0.0;
    final largestCategory = sortedCategories.isNotEmpty
        ? sortedCategories.first
        : null;
    final topCategoryPercent = largestCategory != null
        ? (largestCategory.value / totalSpending * 100)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Period selector
          _buildPeriodSelector(),
          const SizedBox(height: 24),

          // Metric cards
          _buildMetricCards(
            totalSpending,
            avgSpending,
            largestCategory,
            topCategoryPercent,
          ),
          const SizedBox(height: 24),

          // Sankey chart
          if (totalSpending > 0)
            Container(
              height: 500,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: SankeyChart(
                nodes: nodes,
                links: links,
                totalIncome: totalSpending.toDouble(),
              ),
            )
          else
            _buildNoDataState(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PERIOD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<PeriodUnit>(
                    value: _periodUnit,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
                          _periodsAgo = 0;
                        });
                      }
                    },
                  ),
                ),
              ),
              if (_periodUnit != PeriodUnit.allTime) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 24),
                        onPressed: () {
                          setState(() => _periodsAgo++);
                        },
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 140),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _getPeriodLabel(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 24),
                        onPressed: _periodsAgo > 0
                            ? () => setState(() => _periodsAgo--)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards(
    int totalSpending,
    double avgSpending,
    MapEntry<String, int>? largestCategory,
    double topCategoryPercent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final cardWidth = isNarrow
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;

        Widget buildCard(
          String label,
          String value,
          IconData icon,
          Color color,
        ) {
          return Container(
            width: cardWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          );
        }

        final cards = [
          buildCard(
            'TOTAL SPENT',
            totalSpending > 0
                ? '\$${(totalSpending / 100).toStringAsFixed(2)}'
                : '\$0.00',
            Icons.trending_down_rounded,
            AppColors.negative,
          ),
          buildCard(
            'AVG PER TX',
            totalSpending > 0
                ? '\$${(avgSpending / 100).toStringAsFixed(2)}'
                : '\$0.00',
            Icons.calculate_outlined,
            AppColors.textPrimary,
          ),
          buildCard(
            'TOP CATEGORY',
            totalSpending > 0 ? (largestCategory?.key ?? 'N/A') : 'N/A',
            Icons.category_outlined,
            AppColors.accent,
          ),
          buildCard(
            'TOP %',
            totalSpending > 0
                ? '${topCategoryPercent.toStringAsFixed(1)}%'
                : '0%',
            Icons.pie_chart_outline,
            AppColors.accent,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [cards[0], cards[1]],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [cards[2], cards[3]],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: cards,
        );
      },
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.waterfall_chart_outlined,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No spending data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _periodUnit == PeriodUnit.allTime
                ? 'No transactions found. Sync your accounts to import data.'
                : 'No transactions in ${_getPeriodLabel()}.\nTry clicking ← to view previous periods.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    final data = ref.watch(monthlyBreakdownProvider);

    return data.when(
      data: (months) => RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () async => ref.invalidate(monthlyBreakdownProvider),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MonthlyBarChart(data: months),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildBreakdownList(
              'Monthly Totals',
              months
                  .map(
                    (m) => (
                      title: m.month,
                      subtitle: '${m.count} transactions',
                      value: m.total,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      loading: () => const _ChartsLoading(),
      error: (e, _) => _ErrorState(error: e.toString()),
    );
  }

  Widget _buildWeeklyTab() {
    final data = ref.watch(weeklyBreakdownProvider);

    return data.when(
      data: (weeks) => RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () async => ref.invalidate(weeklyBreakdownProvider),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  WeeklyBarChart(data: weeks),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildBreakdownList(
              'Weekly Totals',
              weeks
                  .map(
                    (w) => (
                      title: 'Week of ${w.weekStart}',
                      subtitle: '${w.count} transactions',
                      value: w.total,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      loading: () => const _ChartsLoading(),
      error: (e, _) => _ErrorState(error: e.toString()),
    );
  }

  Widget _buildBreakdownList(
    String title,
    List<({String title, String subtitle, String value})> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              children: [
                if (entry.key > 0)
                  const Divider(
                    height: 1,
                    indent: 24,
                    endIndent: 24,
                    color: AppColors.border,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textTertiary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
}

class _ChartsLoading extends StatelessWidget {
  const _ChartsLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.waterfall_chart_outlined,
                size: 44,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No transaction data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sync your accounts to see cash flow visualization',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.negativeLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.negative,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
