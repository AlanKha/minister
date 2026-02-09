import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics.dart';
import '../theme.dart';

class CategoryPieChart extends StatelessWidget {
  final List<CategoryBreakdown> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
      );
    }

    final colors = AppColors.categoryColors;

    return Row(
      children: [
        // Chart
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: data.map((item) {
                  final color =
                      colors[item.category] ?? AppColors.textTertiary;
                  return PieChartSectionData(
                    value: item.totalCents.abs().toDouble(),
                    color: color,
                    title: '',
                    radius: 40,
                    borderSide: BorderSide(
                      color: AppColors.surface,
                      width: 2,
                    ),
                  );
                }).toList(),
                sectionsSpace: 0,
                centerSpaceRadius: 36,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Legend
        Expanded(
          flex: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.take(8).map((item) {
              final color = colors[item.category] ?? AppColors.textTertiary;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.total,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
                    colors: [
                      AppColors.accent,
                      Color(0xFFEDC06C),
                    ],
                  ),
                  width: 18,
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
                reservedSize: 52,
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
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
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
                  color: AppColors.info,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
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
                reservedSize: 52,
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
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
