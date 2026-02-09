import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../store/json_store.dart';

Router transactionRoutes() {
  final router = Router();

  router.get('/api/transactions', (Request request) {
    var transactions = loadCleanTransactions();

    final params = request.url.queryParameters;
    final account = params['account'];
    final category = params['category'];
    final startDate = params['startDate'];
    final endDate = params['endDate'];
    final search = params['search'];
    final sort = params['sort'] ?? 'date_desc';
    final page = int.tryParse(params['page'] ?? '') ?? 1;
    final limit = int.tryParse(params['limit'] ?? '') ?? 50;

    if (account != null) {
      final acct = account.toLowerCase();
      transactions = transactions
          .where((tx) => tx.accountLabel.toLowerCase().contains(acct))
          .toList();
    }
    if (category != null) {
      final cat = category.toLowerCase();
      transactions =
          transactions.where((tx) => tx.category.toLowerCase() == cat).toList();
    }
    if (startDate != null) {
      transactions =
          transactions.where((tx) => tx.date.compareTo(startDate) >= 0).toList();
    }
    if (endDate != null) {
      transactions =
          transactions.where((tx) => tx.date.compareTo(endDate) <= 0).toList();
    }
    if (search != null) {
      final q = search.toLowerCase();
      transactions = transactions
          .where((tx) => tx.description.toLowerCase().contains(q))
          .toList();
    }

    switch (sort) {
      case 'date_asc':
        transactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_asc':
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'amount_desc':
        transactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      default:
        transactions.sort((a, b) => b.date.compareTo(a.date));
    }

    final total = transactions.length;
    final start = (page - 1) * limit;
    final paginated = transactions.sublist(
      min(start, total),
      min(start + limit, total),
    );

    return Response.ok(
      jsonEncode({
        'data': paginated.map((t) => t.toJson()).toList(),
        'pagination': {
          'page': page,
          'limit': limit,
          'total': total,
          'totalPages': (total / limit).ceil(),
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.patch('/api/transactions/<id>', (Request request, String id) async {
    final body =
        jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final category = body['category'];

    if (category == null || category is! String || category.isEmpty) {
      return Response(400,
          body: jsonEncode({'error': 'category is required'}),
          headers: {'Content-Type': 'application/json'});
    }

    final overrides = loadOverrides();
    overrides[id] = category;
    saveOverrides(overrides);

    final transactions = loadCleanTransactions();
    final txIndex = transactions.indexWhere((t) => t.id == id);
    if (txIndex == -1) {
      return Response.notFound(
        jsonEncode({'error': 'Transaction not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    transactions[txIndex].category = category;
    saveCleanTransactions(transactions);

    return Response.ok(
      jsonEncode(
          {'success': true, 'transaction': transactions[txIndex].toJson()}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}
