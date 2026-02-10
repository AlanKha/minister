class StoredTransaction {
  final Map<String, dynamic> data;

  StoredTransaction(this.data);

  String get id => data['id'] as String;
  int get transactedAt => data['transacted_at'] as int;
  int get amount => data['amount'] as int;
  String get status => data['status'] as String;
  String get description => data['description'] as String? ?? '';
  String get accountId => data['account_id'] as String;
  String get accountLabel => data['account_label'] as String;

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;

  Map<String, dynamic> toJson() => data;

  factory StoredTransaction.fromJson(Map<String, dynamic> json) {
    return StoredTransaction(Map<String, dynamic>.from(json));
  }
}

class CleanTransaction {
  final Map<String, dynamic> data;

  CleanTransaction(this.data);

  String get id => data['id'] as String;
  int get amount => data['amount'] as int;
  String get description => data['description'] as String? ?? '';
  String get status => data['status'] as String? ?? '';
  String get category => data['category'] as String? ?? 'N/A';
  set category(String value) => data['category'] = value;
  String get date => data['date'] as String? ?? '';
  int get year => data['year'] as int? ?? 0;
  int get month => data['month'] as int? ?? 0;
  String get accountLabel => data['account_label'] as String? ?? '';

  /// Format amount as currency (e.g., "-$42.50" or "$100.00")
  String get amountFormatted {
    final cents = amount;
    final dollars = cents / 100.0;
    final sign = dollars < 0 ? '' : '';
    return '$sign\$${dollars.abs().toStringAsFixed(2)}';
  }

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;

  Map<String, dynamic> toJson() => data;

  factory CleanTransaction.fromJson(Map<String, dynamic> json) {
    return CleanTransaction(Map<String, dynamic>.from(json));
  }
}

class TransactionPage {
  final List<CleanTransaction> data;
  final int page;
  final int totalPages;
  final int total;

  TransactionPage({
    required this.data,
    required this.page,
    required this.totalPages,
    int? total,
  }) : total = total ?? 0;

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    return TransactionPage(
      data: (json['transactions'] as List<dynamic>?)
              ?.map((t) => CleanTransaction.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}
