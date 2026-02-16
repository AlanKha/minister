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

    // Separate categories into main (>=1%) and small (<1%)
    final mainCategories = <CategoryBreakdown>[];
    final smallCategories = <CategoryBreakdown>[];

    for (final item in widget.data) {
      final pct = grandTotal > 0
          ? (item.totalCents.abs() / grandTotal * 100)
          : 0.0;
      if (pct >= 1.0) {
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

    return MouseRegion(
      onHover: (event) {
        setState(() {
          mousePosition = event.localPosition;
        });
      },
      onExit: (_) {
        setState(() {
          mousePosition = null;
          touchedIndex = null;
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 24, 48, 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Interactive Chart
                Expanded(
                  flex: 5,
                  child: AspectRatio(
                    aspectRatio: 1,
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
                                  final radius = isTouched ? 76.0 : 68.0;

                                  return PieChartSectionData(
                                    value: item.totalCents.abs().toDouble(),
                                    color: color,
                                    title: '',
                                    radius:
                                        radius +
                                        (1 - _animationController.value) * 20,
                                  );
                                }).toList(),
                                sectionsSpace: 3,
                                centerSpaceRadius: 100,
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
                const SizedBox(width: 40),
                // Legend - Multi-column grid
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildLegendGrid(displayData, grandTotal, colors),
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
      ),
    );
  }

  Widget _buildLegendGrid(
    List<CategoryBreakdown> displayData,
    int grandTotal,
    Map<String, Color> colors,
  ) {
    // Split into columns
    final itemsPerColumn = (displayData.length / 3).ceil();
    final columns = <List<CategoryBreakdown>>[];

    for (var i = 0; i < displayData.length; i += itemsPerColumn) {
      final end = (i + itemsPerColumn < displayData.length)
          ? i + itemsPerColumn
          : displayData.length;
      columns.add(displayData.sublist(i, end));
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((columnData) {
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnData.map((item) {
                final index = displayData.indexOf(item);
                final color = colors[item.category] ?? AppColors.textTertiary;
                final pct = grandTotal > 0
                    ? (item.totalCents.abs() / grandTotal * 100)
                        .toStringAsFixed(1)
                    : '0.0';
                final isHovered = touchedIndex == index;

                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      touchedIndex = index;
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        touchedIndex = index;
                        HapticFeedback.lightImpact();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 12, right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? AppColors.accent.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: isHovered ? 9 : 7,
                                height: isHovered ? 9 : 7,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isHovered
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Padding(
                            padding: const EdgeInsets.only(left: 13),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.total,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isHovered
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '($pct%)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                    fontWeight: isHovered
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
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
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
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
        elevation: 12,
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surfaceContainerHighest,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(maxWidth: 200),
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
                    decoration: const BoxDecoration(
                      color: AppColors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Other',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${item.total} ($pct%)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const Divider(height: 16, color: Colors.white24),
              ...smallCategories.map((cat) {
                final catPct = grandTotal > 0
                    ? (cat.totalCents.abs() / grandTotal * 100).toStringAsFixed(
                        1,
                      )
                    : '0.0';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
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
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${cat.category} ($catPct%)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
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
      elevation: 12,
      borderRadius: BorderRadius.circular(8),
      color: AppColors.surfaceContainerHighest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
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
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        AppColors.categoryColors[item.category] ??
                        AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.total} ($pct%)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
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
              getTooltipColor: (group) => AppColors.surfaceContainerHighest,
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
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: item.total,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
              getTooltipColor: (group) => AppColors.surfaceContainerHighest,
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
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: item.total,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
