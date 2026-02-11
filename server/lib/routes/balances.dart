import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../stripe_client.dart';
import '../store/json_store.dart';

Router balanceRoutes() {
  final router = Router();

  // Return locally cached balance data
  router.get('/api/balances', (Request request) {
    final balances = loadBalances();
    final accounts = readAccountData();

    final result = <Map<String, dynamic>>[];
    for (final acct in accounts.accounts) {
      final cached = balances[acct.id] as Map<String, dynamic>?;
      result.add({
        'account_id': acct.id,
        'institution': acct.institution,
        'display_name': acct.displayName,
        'last4': acct.last4,
        'balance': cached?['balance'],
        'balance_refresh': cached?['balance_refresh'],
        'last_refreshed': cached?['last_refreshed'],
        'error': cached?['error'],
      });
    }

    return Response.ok(
      jsonEncode(result),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Trigger balance refresh via Stripe API — costs ~$0.10 per account
  router.post('/api/balances/refresh', (Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic>? json;
      if (body.isNotEmpty) {
        json = jsonDecode(body) as Map<String, dynamic>?;
      }

      final accounts = readAccountData();
      final requestedIds = json?['accountIds'] as List<dynamic>?;

      final toRefresh = requestedIds != null
          ? accounts.accounts
              .where((a) => requestedIds.contains(a.id))
              .toList()
          : accounts.accounts;

      if (toRefresh.isEmpty) {
        return Response.ok(
          jsonEncode({'error': 'No accounts to refresh'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final balances = loadBalances();
      final results = <Map<String, dynamic>>[];

      for (final acct in toRefresh) {
        try {
          // Trigger balance refresh
          await stripeClient.refreshAccount(acct.id, ['balance']);

          // Poll until refresh completes (max 30 attempts, ~60s)
          Map<String, dynamic>? accountData;
          for (var i = 0; i < 30; i++) {
            await Future.delayed(const Duration(seconds: 2));
            accountData = await stripeClient.getAccount(acct.id);

            final refreshStatus = accountData['balance_refresh']
                as Map<String, dynamic>?;
            if (refreshStatus == null) break;

            final status = refreshStatus['status'] as String?;
            if (status == 'succeeded' || status == 'failed') break;
          }

          if (accountData != null) {
            final entry = {
              'balance': accountData['balance'],
              'balance_refresh': accountData['balance_refresh'],
              'last_refreshed': DateTime.now().toUtc().toIso8601String(),
            };
            balances[acct.id] = entry;

            results.add({
              'account_id': acct.id,
              'institution': acct.institution,
              'display_name': acct.displayName,
              'last4': acct.last4,
              ...entry,
            });
          }
        } on StripeException catch (e) {
          final entry = {
            'error': e.message,
            'last_refreshed': DateTime.now().toUtc().toIso8601String(),
          };
          balances[acct.id] = entry;

          results.add({
            'account_id': acct.id,
            'institution': acct.institution,
            'display_name': acct.displayName,
            'last4': acct.last4,
            ...entry,
          });
        }
      }

      saveBalances(balances);

      return Response.ok(
        jsonEncode(results),
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
