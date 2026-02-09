import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

const _baseUrl = 'https://api.stripe.com/v1';

Map<String, String> get _headers => {
      'Authorization': 'Bearer $stripeSecretKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

/// Flatten nested params: {'account_holder': {'type': 'customer'}}
/// becomes {'account_holder[type]': 'customer'}
Map<String, String> _flattenParams(Map<String, dynamic> params,
    [String prefix = '']) {
  final result = <String, String>{};
  for (final entry in params.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix[${entry.key}]';
    if (entry.value is Map) {
      result.addAll(
          _flattenParams(entry.value as Map<String, dynamic>, key));
    } else if (entry.value is List) {
      for (var i = 0; i < (entry.value as List).length; i++) {
        final item = (entry.value as List)[i];
        if (item is Map) {
          result.addAll(_flattenParams(item as Map<String, dynamic>, '$key[$i]'));
        } else {
          result['$key[$i]'] = item.toString();
        }
      }
    } else if (entry.value != null) {
      result[key] = entry.value.toString();
    }
  }
  return result;
}

Future<Map<String, dynamic>> _post(String path,
    [Map<String, dynamic>? params]) async {
  final url = Uri.parse('$_baseUrl$path');
  final body = params != null ? _flattenParams(params) : null;
  final response = await http.post(url, headers: _headers, body: body);
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode >= 400) {
    final error = json['error'] as Map<String, dynamic>?;
    throw StripeException(
      error?['message'] as String? ?? 'Stripe API error',
      error?['type'] as String? ?? 'api_error',
      response.statusCode,
    );
  }
  return json;
}

Future<Map<String, dynamic>> _get(String path,
    [Map<String, String>? queryParams]) async {
  final url = Uri.parse('$_baseUrl$path')
      .replace(queryParameters: queryParams);
  final response = await http.get(url, headers: _headers);
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode >= 400) {
    final error = json['error'] as Map<String, dynamic>?;
    throw StripeException(
      error?['message'] as String? ?? 'Stripe API error',
      error?['type'] as String? ?? 'api_error',
      response.statusCode,
    );
  }
  return json;
}

class StripeException implements Exception {
  final String message;
  final String type;
  final int statusCode;

  StripeException(this.message, this.type, this.statusCode);

  @override
  String toString() => 'StripeException($type): $message';
}

class StripeClient {
  /// POST /v1/customers
  Future<Map<String, dynamic>> createCustomer() async {
    return _post('/customers');
  }

  /// POST /v1/financial_connections/sessions
  Future<Map<String, dynamic>> createFinancialConnectionsSession({
    required String customerType,
    required String customerId,
    required List<String> permissions,
    List<String>? prefetch,
  }) async {
    final params = <String, dynamic>{
      'account_holder': {
        'type': customerType,
        'customer': customerId,
      },
      'permissions': permissions,
    };
    if (prefetch != null) {
      params['prefetch'] = prefetch;
    }
    return _post('/financial_connections/sessions', params);
  }

  /// POST /v1/financial_connections/accounts/{id}/subscribe
  Future<Map<String, dynamic>> subscribeAccount(
      String accountId, List<String> features) async {
    return _post(
      '/financial_connections/accounts/$accountId/subscribe',
      {'features': features},
    );
  }

  /// POST /v1/financial_connections/accounts/{id}/refresh
  Future<Map<String, dynamic>> refreshAccount(
      String accountId, List<String> features) async {
    return _post(
      '/financial_connections/accounts/$accountId/refresh',
      {'features': features},
    );
  }

  /// GET /v1/financial_connections/accounts/{id}
  Future<Map<String, dynamic>> getAccount(String accountId) async {
    return _get('/financial_connections/accounts/$accountId');
  }

  /// GET /v1/financial_connections/transactions (paginated)
  Future<Map<String, dynamic>> listTransactions({
    required String accountId,
    int limit = 100,
    String? startingAfter,
  }) async {
    final params = <String, String>{
      'account': accountId,
      'limit': limit.toString(),
    };
    if (startingAfter != null) {
      params['starting_after'] = startingAfter;
    }
    return _get('/financial_connections/transactions', params);
  }
}

final stripeClient = StripeClient();
