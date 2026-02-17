import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../store/json_store.dart';
import '../services/cleaning_service.dart';

Router categoryRoutes() {
  final router = Router();

  // GET /api/categories - List all user-defined category rules
  router.get('/api/categories', (Request request) {
    final rules = loadCategoryRules();
    return Response.ok(
      jsonEncode(rules.map((r) => r.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // GET /api/categories/should-import - Check if defaults should be imported
  router.get('/api/categories/should-import', (Request request) {
    final rules = loadCategoryRules();
    final shouldImport = rules.isEmpty;
    return Response.ok(
      jsonEncode({'shouldImport': shouldImport, 'count': rules.length}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // POST /api/categories/import-defaults - Import default rules to user rules
  router.post('/api/categories/import-defaults', (Request request) async {
    try {
      final defaultRules = loadDefaultCategoryRules();

      if (defaultRules.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No default rules available to import'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Save default rules as user rules
      saveCategoryRules(defaultRules);

      // Trigger re-categorization
      cleanAllTransactions();

      return Response.ok(
        jsonEncode({
          'success': true,
          'imported': defaultRules.length,
          'message': 'Imported ${defaultRules.length} default rules'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // POST /api/categories - Add new regex pattern
  router.post('/api/categories', (Request request) async {
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

      // Validate regex pattern
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

      // Trigger re-categorization
      cleanAllTransactions();

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

  // PUT /api/categories/<id> - Update regex pattern
  router.put('/api/categories/<id>', (Request request, String id) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final rules = loadCategoryRules();
      final index = rules.indexWhere((r) => r.id == id);

      if (index == -1) {
        return Response.notFound(
          jsonEncode({'error': 'Category rule not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final pattern = json['pattern'] as String?;
      final category = json['category'] as String?;
      final caseSensitive = json['caseSensitive'] as bool?;

      if (pattern != null && pattern.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Pattern cannot be empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (category != null && category.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Category cannot be empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Validate regex pattern if provided
      if (pattern != null) {
        try {
          RegExp(pattern, caseSensitive: caseSensitive ?? rules[index].caseSensitive);
        } catch (e) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid regex pattern: $e'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      final updatedRule = CategoryRule(
        id: id,
        category: category ?? rules[index].category,
        pattern: pattern ?? rules[index].pattern,
        caseSensitive: caseSensitive ?? rules[index].caseSensitive,
      );

      rules[index] = updatedRule;
      saveCategoryRules(rules);

      // Trigger re-categorization
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

  // DELETE /api/categories/<id> - Delete regex pattern
  router.delete('/api/categories/<id>', (Request request, String id) {
    try {
      final rules = loadCategoryRules();
      final initialLength = rules.length;
      rules.removeWhere((r) => r.id == id);

      if (rules.length == initialLength) {
        return Response.notFound(
          jsonEncode({'error': 'Category rule not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      saveCategoryRules(rules);

      // Trigger re-categorization
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

  // GET /api/transactions/uncategorized - Get all uncategorized transactions
  router.get('/api/transactions/uncategorized', (Request request) {
    final transactions = loadCleanTransactions();
    final uncategorized = transactions
        .where((tx) => tx.data['category'] == 'Uncategorized')
        .toList();

    return Response.ok(
      jsonEncode(uncategorized.map((t) => t.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // POST /api/transactions/<id>/categorize - Manually categorize a transaction
  router.post('/api/transactions/<id>/categorize',
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

      // Validate regex first before making any changes
      if (createRule && rulePattern != null && rulePattern.isNotEmpty) {
        try {
          RegExp(rulePattern, caseSensitive: false);
        } catch (e) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid regex pattern: $e'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      // Load overrides and add this transaction
      final overrides = loadOverrides();
      overrides[id] = category;
      saveOverrides(overrides);

      // Create the rule (already validated above)
      if (createRule && rulePattern != null && rulePattern.isNotEmpty) {
        final rules = loadCategoryRules();
        final newRule = CategoryRule(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: category,
          pattern: rulePattern,
          caseSensitive: false,
        );
        rules.add(newRule);
        saveCategoryRules(rules);
      }

      // Trigger re-categorization
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

  return router;
}
