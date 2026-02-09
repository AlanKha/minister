import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../widgets/spending_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Categories'),
              Tab(text: 'Monthly'),
              Tab(text: 'Weekly'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoriesTab(),
            _MonthlyTab(),
            _WeeklyTab(),
          ],
        ),
      ),
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(categoryBreakdownProvider);

    return data.when(
      data: (categories) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(categoryBreakdownProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 240,
              child: CategoryPieChart(data: categories),
            ),
            const SizedBox(height: 24),
            Text('Breakdown',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...categories.map((cat) => ListTile(
                  title: Text(cat.category),
                  subtitle: Text('${cat.count} transactions'),
                  trailing: Text(
                    cat.total,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                )),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _MonthlyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(monthlyBreakdownProvider);

    return data.when(
      data: (months) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(monthlyBreakdownProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: MonthlyBarChart(data: months),
            ),
            const SizedBox(height: 24),
            Text('Monthly Totals',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...months.map((m) => ListTile(
                  title: Text(m.month),
                  subtitle: Text('${m.count} transactions'),
                  trailing: Text(
                    m.total,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                )),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _WeeklyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(weeklyBreakdownProvider);

    return data.when(
      data: (weeks) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(weeklyBreakdownProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: WeeklyBarChart(data: weeks),
            ),
            const SizedBox(height: 24),
            Text('Weekly Totals',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...weeks.map((w) => ListTile(
                  title: Text('Week of ${w.weekStart}'),
                  subtitle: Text('${w.count} transactions'),
                  trailing: Text(
                    w.total,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                )),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
