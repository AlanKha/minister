import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:minister_shared/models/account.dart';
import '../store/json_store.dart';
import '../services/cleaning_service.dart';

Router settingsRoutes() {
  final router = Router();

  // POST /api/settings/reset-category-rules - Reset rules to defaults
  router.post('/api/settings/reset-category-rules', (Request request) async {
    try {
      final defaultRules = loadDefaultCategoryRules();

      if (defaultRules.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No default rules available'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Replace user rules with defaults
      saveCategoryRules(defaultRules);

      // Trigger re-categorization
      cleanAllTransactions();

      return Response.ok(
        jsonEncode({
          'success': true,
          'count': defaultRules.length,
          'message': 'Reset to ${defaultRules.length} default rules'
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

  // POST /api/settings/clear-category-rules - Clear all user rules
  router.post('/api/settings/clear-category-rules', (Request request) async {
    try {
      saveCategoryRules([]);

      // Trigger re-categorization
      cleanAllTransactions();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Cleared all category rules'
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

  // POST /api/settings/recategorize - Re-categorize all transactions
  router.post('/api/settings/recategorize', (Request request) async {
    try {
      cleanAllTransactions();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Re-categorization complete'
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

  // POST /api/settings/clear-overrides - Clear all category overrides
  router.post('/api/settings/clear-overrides', (Request request) async {
    try {
      saveOverrides({});

      // Trigger re-categorization
      cleanAllTransactions();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Cleared all category overrides'
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

  // POST /api/settings/clear-pins - Clear all pinned (manually tagged) transactions
  router.post('/api/settings/clear-pins', (Request request) async {
    try {
      savePinnedTransactions({});

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Cleared all manual tags'
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

  // POST /api/settings/clear-transactions - Clear all transaction data
  router.post('/api/settings/clear-transactions', (Request request) async {
    try {
      saveTransactions([]);
      saveCleanTransactions([]);
      saveOverrides({});
      savePinnedTransactions({});

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Cleared all transaction data'
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

  // POST /api/settings/unlink-accounts - Unlink all Plaid accounts
  router.post('/api/settings/unlink-accounts', (Request request) async {
    try {
      writeAccountData(AccountData());

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Unlinked all accounts'
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

  // GET /api/settings/stats - Get database statistics
  router.get('/api/settings/stats', (Request request) {
    try {
      final transactions = loadTransactions();
      final cleanTransactions = loadCleanTransactions();
      final rules = loadCategoryRules();
      final defaultRules = loadDefaultCategoryRules();
      final overrides = loadOverrides();
      final pinned = loadPinnedTransactions();
      final accounts = readAccountData();

      return Response.ok(
        jsonEncode({
          'transactions': transactions.length,
          'cleanTransactions': cleanTransactions.length,
          'categoryRules': rules.length,
          'defaultRules': defaultRules.length,
          'overrides': overrides.length,
          'pinned': pinned.length,
          'accounts': accounts.accounts.length,
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

  // POST /api/settings/refresh-default-rules - Update default_category_rules.json from example
  router.post('/api/settings/refresh-default-rules', (Request request) async {
    try {
      final exampleFile = File(p.join(serverRoot, 'example_default_category_rules.json'));
      final defaultFile = File(p.join(serverRoot, 'default_category_rules.json'));

      if (!exampleFile.existsSync()) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Example default rules file not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Copy example to default
      defaultFile.writeAsStringSync(exampleFile.readAsStringSync());

      final defaultRules = loadDefaultCategoryRules();

      return Response.ok(
        jsonEncode({
          'success': true,
          'count': defaultRules.length,
          'message': 'Refreshed default rules file'
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

  return router;
}
