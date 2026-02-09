import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;
import '../lib/config.dart';
import '../lib/store/json_store.dart';
import '../lib/routes/accounts.dart';
import '../lib/routes/transactions.dart';
import '../lib/routes/sync.dart';
import '../lib/routes/analytics.dart';

Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }

      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
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

  // Static file handler for public/
  final publicDir = p.join(serverRoot, 'public');
  final staticHandler = createStaticHandler(publicDir, defaultDocument: 'index.html');

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
