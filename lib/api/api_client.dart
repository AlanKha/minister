import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/analytics.dart';

class ApiClient {
  final _client = http.Client();

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    return Uri.parse('$apiBaseUrl$path')
        .replace(queryParameters: queryParams?.isNotEmpty == true ? queryParams : null);
  }

  // Accounts
  Future<List<LinkedAccount>> getAccounts() async {
    final response = await _client.get(_uri('/api/accounts'));
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => LinkedAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Transactions
  Future<TransactionPage> getTransactions({
    String? account,
    String? category,
    String? startDate,
    String? endDate,
    String? search,
    String? sort,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (account != null) params['account'] = account;
    if (category != null) params['category'] = category;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (search != null) params['search'] = search;
    if (sort != null) params['sort'] = sort;

    final response = await _client.get(_uri('/api/transactions', params));
    return TransactionPage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CleanTransaction> updateTransactionCategory(
      String id, String category) async {
    final response = await _client.patch(
      _uri('/api/transactions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': category}),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CleanTransaction.fromJson(
        json['transaction'] as Map<String, dynamic>);
  }

  // Sync
  Future<Map<String, dynamic>> sync([List<String>? accountIds]) async {
    final response = await _client.post(
      _uri('/api/sync'),
      headers: {'Content-Type': 'application/json'},
      body: accountIds != null
          ? jsonEncode({'accountIds': accountIds})
          : null,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> syncFetch([List<String>? accountIds]) async {
    final response = await _client.post(
      _uri('/api/sync/fetch'),
      headers: {'Content-Type': 'application/json'},
      body: accountIds != null
          ? jsonEncode({'accountIds': accountIds})
          : null,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> syncClean() async {
    final response = await _client.post(_uri('/api/sync/clean'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Analytics
  Future<List<CategoryBreakdown>> getCategoryBreakdown({
    String? startDate,
    String? endDate,
    String? account,
    String? category,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (account != null) params['account'] = account;
    if (category != null) params['category'] = category;

    final response =
        await _client.get(_uri('/api/analytics/categories', params));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MonthlyBreakdown>> getMonthlyBreakdown({
    String? startDate,
    String? endDate,
    String? account,
    String? category,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (account != null) params['account'] = account;
    if (category != null) params['category'] = category;

    final response =
        await _client.get(_uri('/api/analytics/monthly', params));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => MonthlyBreakdown.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<WeeklyBreakdown>> getWeeklyBreakdown({
    String? startDate,
    String? endDate,
    String? account,
    String? category,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (account != null) params['account'] = account;
    if (category != null) params['category'] = category;

    final response =
        await _client.get(_uri('/api/analytics/weekly', params));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => WeeklyBreakdown.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
