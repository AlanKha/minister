class CategoryBreakdown {
  final String category;
  final int count;
  final int totalCents;
  final String total;

  CategoryBreakdown({
    required this.category,
    required this.count,
    required this.totalCents,
    required this.total,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String,
      count: json['count'] as int,
      totalCents: json['total_cents'] as int,
      total: json['total'] as String,
    );
  }
}

class MonthlyBreakdown {
  final String month;
  final int count;
  final int totalCents;
  final String total;

  MonthlyBreakdown({
    required this.month,
    required this.count,
    required this.totalCents,
    required this.total,
  });

  factory MonthlyBreakdown.fromJson(Map<String, dynamic> json) {
    return MonthlyBreakdown(
      month: json['month'] as String,
      count: json['count'] as int,
      totalCents: json['total_cents'] as int,
      total: json['total'] as String,
    );
  }
}

class WeeklyBreakdown {
  final String weekStart;
  final int count;
  final int totalCents;
  final String total;

  WeeklyBreakdown({
    required this.weekStart,
    required this.count,
    required this.totalCents,
    required this.total,
  });

  factory WeeklyBreakdown.fromJson(Map<String, dynamic> json) {
    return WeeklyBreakdown(
      weekStart: json['week_start'] as String,
      count: json['count'] as int,
      totalCents: json['total_cents'] as int,
      total: json['total'] as String,
    );
  }
}
