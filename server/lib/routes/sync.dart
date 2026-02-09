import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/sync_service.dart';
import '../services/cleaning_service.dart';

Router syncRoutes() {
  final router = Router();

  router.post('/api/sync', (Request request) async {
    try {
      Map<String, dynamic>? body;
      final bodyStr = await request.readAsString();
      if (bodyStr.isNotEmpty) {
        body = jsonDecode(bodyStr) as Map<String, dynamic>?;
      }
      final accountIds = (body?['accountIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

      final fetchResult = await syncFromStripe(accountIds);
      final cleaned = cleanAllTransactions();

      return Response.ok(
        jsonEncode({
          'fetch': fetchResult.toJson(),
          'clean': {'count': cleaned.length},
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Sync error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/api/sync/fetch', (Request request) async {
    try {
      Map<String, dynamic>? body;
      final bodyStr = await request.readAsString();
      if (bodyStr.isNotEmpty) {
        body = jsonDecode(bodyStr) as Map<String, dynamic>?;
      }
      final accountIds = (body?['accountIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

      final result = await syncFromStripe(accountIds);
      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Fetch error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/api/sync/clean', (Request request) async {
    try {
      final cleaned = cleanAllTransactions();
      return Response.ok(
        jsonEncode({'count': cleaned.length}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Clean error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
