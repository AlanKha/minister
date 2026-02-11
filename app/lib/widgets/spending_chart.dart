import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:minister_shared/models/analytics.dart';
import '../theme.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryBreakdown> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart>
    with SingleTickerProviderStateMixin {
  int? touchedIndex;
  Offset? mousePosition;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
      );
    }

    final colors = AppColors.categoryColors;
    final grandTotal = widget.data.fold<int>(
      0,
      (sum, e) => sum + e.totalCents.abs(),
    );

    // Separate categories into main (>=3%) and small (<3%)
    final mainCategories = <CategoryBreakdown>[];
    final smallCategories = <CategoryBreakdown>[];

    for (final item in widget.data) {
      final pct = grandTotal > 0
          ? (item.totalCents.abs() / grandTotal * 100)
          : 0.0;
      if (pct >= 3.0) {
        mainCategories.add(item);
      } else {
        smallCategories.add(item);
      }
    }

    // Create "Other" category if there are small categories
    final displayData = List<CategoryBreakdown>.from(mainCategories);
    if (smallCategories.isNotEmpty) {
      final otherTotal = smallCategories.fold<int>(
        0,
        (sum, e) => sum + e.totalCents.abs(),
      );
      final otherCount = smallCategories.fold<int>(
        0,
        (sum, e) => sum + e.count,
      );
      displayData.add(
        CategoryBreakdown(
          category: 'Other',
          count: otherCount,
          totalCents: otherTotal,
          total: '\$${(otherTotal / 100).toStringAsFixed(2)}',
        ),
      );
    }

    // Check if any category is touched
    final isTouched =
        touchedIndex != null &&
        touchedIndex! >= 0 &&
        touchedIndex! < displayData.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // Interactive Chart
              Expanded(
                flex: 7,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: MouseRegion(
                    onHover: (event) {
                      setState(() {
                        mousePosition = event.localPosition;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        mousePosition = null;
                      });
                    },
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sections: displayData.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final color =
                                      colors[item.category] ??
                                      AppColors.textTertiary;
                                  final isTouched = touchedIndex == index;
                                  final radius = isTouched ? 70.0 : 62.0;

                                  return PieChartSectionData(
                                    value: item.totalCents.abs().toDouble(),
                                    color: color,
                                    title: '',
                                    radius:
                                        radius +
                                        (1 - _animationController.value) * 20,
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 65,
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = null;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                          if (event is FlTapUpEvent) {
                                            HapticFeedback.lightImpact();
                                          }
                                        });
                                      },
                                ),
                              ),
                            ),
                            // Total in the center
                            _buildTotalInfo(grandTotal),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayData.take(8).toList().asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final item = entry.value;
                      final color =
                          colors[item.category] ?? AppColors.textTertiary;
                      final pct = grandTotal > 0
                          ? (item.totalCents.abs() / grandTotal * 100)
                                .toStringAsFixed(1)
                          : '0.0';
                      final isHovered = touchedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            touchedIndex = index;
                            HapticFeedback.lightImpact();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? AppColors.accent.withValues(alpha: 0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isHovered ? 12 : 8,
                                height: isHovered ? 12 : 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(
                                    isHovered ? 6 : 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isHovered
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isHovered
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isHovered
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isHovered
                                      ? AppColors.accent
                                      : AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.total,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isHovered
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isHovered
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          // Floating tooltip at the top level to render above everything
          if (isTouched && mousePosition != null)
            Positioned(
              left: mousePosition!.dx + 12,
              top: mousePosition!.dy - 40,
              child: _buildTooltip(
                displayData[touchedIndex!],
                grandTotal,
                smallCategories,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalInfo(int grandTotal) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${(grandTotal / 100).toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'Total',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildTooltip(
    CategoryBreakdown item,
    int grandTotal,
    List<CategoryBreakdown> smallCategories,
  ) {
    final pct = grandTotal > 0
        ? (item.totalCents.abs() / grandTotal * 100).toStringAsFixed(1)
        : '0.0';

    // If this is the "Other" category, show expanded list
    if (item.category == 'Other' && smallCategories.isNotEmpty) {
      return Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(maxWidth: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.total,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($pct%)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 8),
              ...smallCategories.map((cat) {
                final catPct = grandTotal > 0
                    ? (cat.totalCents.abs() / grandTotal * 100).toStringAsFixed(
                        1,
                      )
                    : '0.0';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              AppColors.categoryColors[cat.category] ??
                              AppColors.textTertiary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${cat.category} ($catPct%)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    // Regular category tooltip
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        AppColors.categoryColors[item.category] ??
                        AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item.total} ($pct%)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyBreakdown> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
      );
    }

    final maxVal = data
        .map((d) => d.totalCents.abs().toDouble())
        .reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.8,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.15,
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalCents.abs().toDouble(),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  final label = data[i].month;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label.length > 5 ? label.substring(5) : label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 100).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.textPrimary,
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = data[groupIndex];
                return BarTooltipItem(
                  '${item.month}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: item.total,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WeeklyBarChart extends StatelessWidget {
  final List<WeeklyBreakdown> data;

  const WeeklyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
      );
    }

    final maxVal = data
        .map((d) => d.totalCents.abs().toDouble())
        .reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.8,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.15,
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalCents.abs().toDouble(),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  final label = data[i].weekStart;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label.substring(5),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 100).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.textPrimary,
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = data[groupIndex];
                return BarTooltipItem(
                  'Week of ${item.weekStart}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: item.total,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
