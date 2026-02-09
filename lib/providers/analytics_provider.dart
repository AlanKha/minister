import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics.dart';
import 'accounts_provider.dart';

final categoryBreakdownProvider =
    FutureProvider<List<CategoryBreakdown>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getCategoryBreakdown();
});

final monthlyBreakdownProvider =
    FutureProvider<List<MonthlyBreakdown>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getMonthlyBreakdown();
});

final weeklyBreakdownProvider =
    FutureProvider<List<WeeklyBreakdown>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getWeeklyBreakdown();
});
