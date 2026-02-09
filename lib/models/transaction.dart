class CleanTransaction {
  final String id;
  final int amount;
  final String description;
  final String status;
  final String category;
  final String date;
  final int year;
  final int month;
  final String accountLabel;
  final Map<String, dynamic> raw;

  CleanTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.status,
    required this.category,
    required this.date,
    required this.year,
    required this.month,
    required this.accountLabel,
    required this.raw,
  });

  factory CleanTransaction.fromJson(Map<String, dynamic> json) {
    return CleanTransaction(
      id: json['id'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? '',
      category: json['category'] as String? ?? 'N/A',
      date: json['date'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      accountLabel: json['account_label'] as String? ?? '',
      raw: json,
    );
  }

  String get amountFormatted {
    final dollars = amount.abs() / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}

class TransactionPage {
  final List<CleanTransaction> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TransactionPage({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return TransactionPage(
      data: (json['data'] as List<dynamic>)
          .map((e) => CleanTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }
}
