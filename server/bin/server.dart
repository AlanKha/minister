import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:finance_server/config.dart';
import 'package:finance_server/store/json_store.dart';
import 'package:finance_server/routes/accounts.dart';
import 'package:finance_server/routes/transactions.dart';
import 'package:finance_server/routes/sync.dart';
import 'package:finance_server/routes/analytics.dart';
import 'package:finance_server/routes/balances.dart';
import 'package:finance_server/services/cleaning_service.dart';
import 'package:minister_shared/models/account.dart';
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
    return Response.ok(
      jsonEncode(userRules.map((r) => r.toJson()).toList()),
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

  // Settings routes
  app.post('/api/settings/reset-category-rules', (Request request) async {
    try {
      final defaultRules = loadDefaultCategoryRules();
      if (defaultRules.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No default rules available'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      saveCategoryRules(defaultRules);
      saveDeletedDefaults({}); // Clear deleted defaults
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

  app.post('/api/settings/clear-category-rules', (Request request) async {
    try {
      saveCategoryRules([]);
      saveDeletedDefaults({}); // Clear deleted defaults
      cleanAllTransactions();
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Cleared all category rules'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/api/settings/recategorize', (Request request) async {
    try {
      cleanAllTransactions();
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Re-categorization complete'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/api/settings/clear-overrides', (Request request) async {
    try {
      saveOverrides({});
      cleanAllTransactions();
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Cleared all category overrides'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/api/settings/clear-transactions', (Request request) async {
    try {
      saveTransactions([]);
      saveCleanTransactions([]);
      saveOverrides({});
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Cleared all transaction data'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/api/settings/unlink-accounts', (Request request) async {
    try {
      writeAccountData(AccountData());
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Unlinked all accounts'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.get('/api/settings/stats', (Request request) {
    try {
      final transactions = loadTransactions();
      final cleanTransactions = loadCleanTransactions();
      final rules = loadCategoryRules();
      final defaultRules = loadDefaultCategoryRules();
      final overrides = loadOverrides();
      final accounts = readAccountData();
      return Response.ok(
        jsonEncode({
          'transactions': transactions.length,
          'cleanTransactions': cleanTransactions.length,
          'categoryRules': rules.length,
          'defaultRules': defaultRules.length,
          'overrides': overrides.length,
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

  app.get('/api/settings/backup', (Request request) {
    try {
      final dataDir = Directory(p.join(serverRoot, 'data'));
      if (!dataDir.existsSync()) {
        return Response.notFound(
          jsonEncode({'error': 'Data directory not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Create zip archive
      final encoder = ZipFileEncoder();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final tempZip = File(p.join(Directory.systemTemp.path, 'minister-backup-$timestamp.zip'));
      encoder.create(tempZip.path);
      encoder.addDirectory(dataDir);
      encoder.close();

      // Read zip file
      final zipBytes = tempZip.readAsBytesSync();
      tempZip.deleteSync();

      return Response.ok(
        zipBytes,
        headers: {
          'Content-Type': 'application/zip',
          'Content-Disposition': 'attachment; filename="minister-backup-$timestamp.zip"',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  app.post('/api/settings/restore', (Request request) async {
    try {
      final bytes = await request.read().expand((chunk) => chunk).toList();
      if (bytes.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No file uploaded'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Save uploaded file temporarily
      final tempZip = File(p.join(Directory.systemTemp.path, 'minister-restore-${DateTime.now().millisecondsSinceEpoch}.zip'));
      await tempZip.writeAsBytes(bytes);

      // Extract to data directory
      final dataDir = Directory(p.join(serverRoot, 'data'));
      if (dataDir.existsSync()) {
        // Backup existing data first
        final backupDir = Directory(p.join(serverRoot, 'data-backup-${DateTime.now().millisecondsSinceEpoch}'));
        await dataDir.rename(backupDir.path);
      }
      dataDir.createSync(recursive: true);

      // Extract zip
      final archive = ZipDecoder().decodeBytes(tempZip.readAsBytesSync());
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(p.join(dataDir.path, filename));
          outFile.createSync(recursive: true);
          await outFile.writeAsBytes(data);
        }
      }

      tempZip.deleteSync();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Data restored successfully',
          'filesRestored': archive.length,
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

  app.get('/api/categories/should-import', (Request request) {
    final rules = loadCategoryRules();
    final shouldImport = rules.isEmpty;
    return Response.ok(
      jsonEncode({'shouldImport': shouldImport, 'count': rules.length}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  app.post('/api/categories/import-defaults', (Request request) async {
    try {
      final defaultRules = loadDefaultCategoryRules();
      if (defaultRules.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'No default rules available to import'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      saveCategoryRules(defaultRules);
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
