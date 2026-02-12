import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minister_shared/models/account.dart';
import 'package:minister_shared/models/transaction.dart';
import 'package:minister_shared/models/analytics.dart';
import 'package:minister_shared/models/category_rule.dart';
import '../config.dart';

class ApiClient {
  final _client = http.Client();

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    return Uri.parse('$apiBaseUrl$path').replace(
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
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
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CleanTransaction> updateTransactionCategory(
    String id,
    String category,
  ) async {
    final response = await _client.patch(
      _uri('/api/transactions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': category}),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CleanTransaction.fromJson(
      json['transaction'] as Map<String, dynamic>,
    );
  }

  // Sync
  Future<Map<String, dynamic>> sync([List<String>? accountIds]) async {
    final response = await _client.post(
      _uri('/api/sync'),
      headers: {'Content-Type': 'application/json'},
      body: accountIds != null ? jsonEncode({'accountIds': accountIds}) : null,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> syncFetch([List<String>? accountIds]) async {
    final response = await _client.post(
      _uri('/api/sync/fetch'),
      headers: {'Content-Type': 'application/json'},
      body: accountIds != null ? jsonEncode({'accountIds': accountIds}) : null,
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

    final response = await _client.get(
      _uri('/api/analytics/categories', params),
    );
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

    final response = await _client.get(_uri('/api/analytics/monthly', params));
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

    final response = await _client.get(_uri('/api/analytics/weekly', params));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => WeeklyBreakdown.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Category Management
  Future<List<CategoryRule>> getCategoryRules() async {
    final response = await _client.get(_uri('/api/categories'));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => CategoryRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryRule> createCategoryRule({
    required String category,
    required String pattern,
    bool caseSensitive = false,
  }) async {
    final response = await _client.post(
      _uri('/api/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'pattern': pattern,
        'caseSensitive': caseSensitive,
      }),
    );

    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to create rule');
    }

    return CategoryRule.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CategoryRule> updateCategoryRule({
    required String id,
    String? category,
    String? pattern,
    bool? caseSensitive,
  }) async {
    final body = <String, dynamic>{};
    if (category != null) body['category'] = category;
    if (pattern != null) body['pattern'] = pattern;
    if (caseSensitive != null) body['caseSensitive'] = caseSensitive;

    final response = await _client.put(
      _uri('/api/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to update rule');
    }

    return CategoryRule.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteCategoryRule(String id) async {
    final response = await _client.delete(_uri('/api/categories/$id'));

    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to delete rule');
    }
  }

  Future<Map<String, dynamic>> shouldImportDefaults() async {
    final response = await _client.get(_uri('/api/categories/should-import'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> importDefaultRules() async {
    final response = await _client.post(_uri('/api/categories/import-defaults'));

    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to import defaults');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<CleanTransaction>> getUncategorizedTransactions() async {
    final response = await _client.get(_uri('/api/transactions/uncategorized'));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => CleanTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Balances
  Future<List<Map<String, dynamic>>> getBalances() async {
    final response = await _client.get(_uri('/api/balances'));
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> refreshBalances([
    List<String>? accountIds,
  ]) async {
    final response = await _client.post(
      _uri('/api/balances/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: accountIds != null ? jsonEncode({'accountIds': accountIds}) : '{}',
    );
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<void> categorizeTransaction({
    required String id,
    required String category,
    bool createRule = false,
    String? rulePattern,
  }) async {
    await _client.post(
      _uri('/api/transactions/$id/categorize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'createRule': createRule,
        'rulePattern': rulePattern,
      }),
    );
  }

  // Settings
  Future<Map<String, dynamic>> resetCategoryRules() async {
    final response = await _client.post(_uri('/api/settings/reset-category-rules'));
    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to reset rules');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> clearCategoryRules() async {
    final response = await _client.post(_uri('/api/settings/clear-category-rules'));
    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to clear rules');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recategorizeTransactions() async {
    final response = await _client.post(_uri('/api/settings/recategorize'));
    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to recategorize');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> clearCategoryOverrides() async {
    final response = await _client.post(_uri('/api/settings/clear-overrides'));
    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to clear overrides');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> clearTransactions() async {
    final response = await _client.post(_uri('/api/settings/clear-transactions'));
    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to clear transactions');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> unlinkAccounts() async {
    final response = await _client.post(_uri('/api/settings/unlink-accounts'));
    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to unlink accounts');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.get(_uri('/api/settings/stats'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String getBackupUrl() {
    return '$apiBaseUrl/api/settings/backup';
  }

  Future<Map<String, dynamic>> restoreBackup(List<int> zipBytes) async {
    final response = await _client.post(
      _uri('/api/settings/restore'),
      headers: {'Content-Type': 'application/zip'},
      body: zipBytes,
    );

    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to restore backup');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
