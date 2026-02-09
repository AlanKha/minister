import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/analytics_service.dart';

Filters _extractFilters(Map<String, String> params) {
  return Filters(
    startDate: params['startDate'],
    endDate: params['endDate'],
    account: params['account'],
    category: params['category'],
  );
}

Router analyticsRoutes() {
  final router = Router();

  router.get('/api/analytics/categories', (Request request) {
    final filters = _extractFilters(request.url.queryParameters);
    return Response.ok(
      jsonEncode(getCategoryBreakdown(filters)),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/api/analytics/monthly', (Request request) {
    final filters = _extractFilters(request.url.queryParameters);
    return Response.ok(
      jsonEncode(getMonthlyBreakdown(filters)),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/api/analytics/weekly', (Request request) {
    final filters = _extractFilters(request.url.queryParameters);
    return Response.ok(
      jsonEncode(getWeeklyBreakdown(filters)),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}
