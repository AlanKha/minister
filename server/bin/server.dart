import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;
import 'package:finance_server/config.dart';
import 'package:finance_server/store/json_store.dart';
import 'package:finance_server/routes/accounts.dart';
import 'package:finance_server/routes/transactions.dart';
import 'package:finance_server/routes/sync.dart';
import 'package:finance_server/routes/analytics.dart';
import 'package:finance_server/routes/balances.dart';
import 'package:finance_server/services/cleaning_service.dart';
import 'package:finance_server/category_rules.dart';
import 'dart:convert';

Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, PATCH, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }

      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods':
            'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    };
  };
}

void main() async {
  loadConfig();

  final serverRoot = p.dirname(p.dirname(Platform.script.toFilePath()));
  initStore(serverRoot);

  final app = Router();

  // Mount API routes
  final accounts = accountRoutes();
  final txns = transactionRoutes();
  final sync = syncRoutes();
  final analytics = analyticsRoutes();
  final balances = balanceRoutes();

  // Account routes
  app.get('/api/accounts', accounts.call);
  app.get('/config', accounts.call);
  app.post('/create-session', accounts.call);
  app.post('/save-account', accounts.call);

  // Transaction routes
  app.get('/api/transactions', txns.call);
  app.patch('/api/transactions/<id>', txns.call);

  // Sync routes
  app.post('/api/sync', sync.call);
  app.post('/api/sync/fetch', sync.call);
  app.post('/api/sync/clean', sync.call);

  // Analytics routes
  app.get('/api/analytics/categories', analytics.call);
  app.get('/api/analytics/monthly', analytics.call);
  app.get('/api/analytics/weekly', analytics.call);

  // Balance routes
  app.get('/api/balances', balances.call);
  app.post('/api/balances/refresh', balances.call);

  // Category management routes - inline handlers
  app.get('/api/categories', (Request request) {
    final userRules = loadCategoryRules();
    final deletedDefaults = loadDeletedDefaults();

    // Convert default rules to JSON format
    final rulesJson = <Map<String, dynamic>>[];

    // Add user-defined rules first
    for (final rule in userRules) {
      rulesJson.add(rule.toJson());
    }

    // Add default rules (with generated IDs), excluding deleted ones
    final seenPatterns = <String>{};
    for (var i = 0; i < defaultCategoryRules.length; i++) {
      final rule = defaultCategoryRules[i];
      final pattern = rule.key.pattern;
      final defaultId = 'default_$i';
      if (!seenPatterns.contains(pattern) &&
          !deletedDefaults.contains(defaultId)) {
        seenPatterns.add(pattern);
        rulesJson.add({
          'id': defaultId,
          'category': rule.value,
          'pattern': pattern,
          'caseSensitive': false,
          'isDefault': true,
        });
      }
    }

    return Response.ok(
      jsonEncode(rulesJson),
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.post('/api/categories', (Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final pattern = json['pattern'] as String?;
      final category = json['category'] as String?;
      final caseSensitive = json['caseSensitive'] as bool? ?? false;

      if (pattern == null || pattern.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Pattern is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (category == null || category.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Category is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      try {
        RegExp(pattern, caseSensitive: caseSensitive);
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid regex pattern: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final rules = loadCategoryRules();
      final newRule = CategoryRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        pattern: pattern,
        caseSensitive: caseSensitive,
      );
      rules.add(newRule);
      saveCategoryRules(rules);

      return Response.ok(
        jsonEncode(newRule.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.get('/api/transactions/uncategorized', (Request request) {
    final transactions = loadCleanTransactions();
    final uncategorized = transactions
        .where((tx) => tx.data['category'] == 'Uncategorized')
        .toList();
    return Response.ok(
      jsonEncode(uncategorized.map((t) => t.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.put('/api/categories/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final rules = loadCategoryRules();
      final index = rules.indexWhere((r) => r.id == id);

      final pattern = json['pattern'] as String?;
      final category = json['category'] as String?;
      final caseSensitive = json['caseSensitive'] as bool?;

      // If it's a default rule, create a new user rule instead
      if (id.startsWith('default_')) {
        final defaultIndex = int.tryParse(id.replaceFirst('default_', ''));
        if (defaultIndex != null &&
            defaultIndex < defaultCategoryRules.length) {
          final defaultRule = defaultCategoryRules[defaultIndex];
          final newRule = CategoryRule(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            category: category ?? defaultRule.value,
            pattern: pattern ?? defaultRule.key.pattern,
            caseSensitive: caseSensitive ?? false,
          );
          rules.add(newRule);
          saveCategoryRules(rules);
          cleanAllTransactions();
          return Response.ok(
            jsonEncode(newRule.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      if (index == -1) {
        return Response.notFound(
          jsonEncode({'error': 'Category rule not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updatedRule = CategoryRule(
        id: id,
        category: category ?? rules[index].category,
        pattern: pattern ?? rules[index].pattern,
        caseSensitive: caseSensitive ?? rules[index].caseSensitive,
      );

      rules[index] = updatedRule;
      saveCategoryRules(rules);
      cleanAllTransactions();

      return Response.ok(
        jsonEncode(updatedRule.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.delete('/api/categories/<id>', (Request request, String id) {
    try {
      final rules = loadCategoryRules();
      final initialLength = rules.length;
      rules.removeWhere((r) => r.id == id);

      // If it was a default rule, add to deleted defaults list
      if (id.startsWith('default_')) {
        final deletedDefaults = loadDeletedDefaults();
        deletedDefaults.add(id);
        saveDeletedDefaults(deletedDefaults);
        cleanAllTransactions();
        return Response.ok(
          jsonEncode({'success': true}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (rules.length == initialLength) {
        return Response.notFound(
          jsonEncode({'error': 'Category rule not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      saveCategoryRules(rules);
      cleanAllTransactions();

      return Response.ok(
        jsonEncode({'success': true}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/api/transactions/<id>/categorize',
      (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final category = json['category'] as String?;
      final createRule = json['createRule'] as bool? ?? false;
      final rulePattern = json['rulePattern'] as String?;

      if (category == null || category.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Category is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final overrides = loadOverrides();
      overrides[id] = category;
      saveOverrides(overrides);

      if (createRule && rulePattern != null && rulePattern.isNotEmpty) {
        try {
          RegExp(rulePattern, caseSensitive: false);
          final rules = loadCategoryRules();
          final newRule = CategoryRule(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            category: category,
            pattern: rulePattern,
            caseSensitive: false,
          );
          rules.add(newRule);
          saveCategoryRules(rules);
        } catch (e) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid regex pattern: $e'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      cleanAllTransactions();

      return Response.ok(
        jsonEncode({'success': true, 'category': category}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Static file handler for public/
  final publicDir = p.join(serverRoot, 'public');
  final staticHandler =
      createStaticHandler(publicDir, defaultDocument: 'index.html');

  // Cascade: try API routes first, then static files
  final cascade = Cascade().add(app.call).add(staticHandler);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(cascade.handler);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 3000);
  print('Stripe mode: $stripeEnv');
  print('Server running at http://localhost:${server.port}');
}
