import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:minister_shared/config/config.dart';
import 'package:minister_shared/models/account.dart';
import '../stripe_client.dart';
import '../store/json_store.dart';

Router accountRoutes() {
  final router = Router();

  router.get('/api/accounts', (Request request) {
    final data = readAccountData();
    return Response.ok(
      jsonEncode(data.accounts.map((a) => a.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/config', (Request request) {
    return Response.ok(
      jsonEncode({'publishableKey': stripePublishableKey}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/create-session', (Request request) async {
    try {
      final data = readAccountData();

      if (data.customerId == null) {
        final customer = await stripeClient.createCustomer();
        data.customerId = customer['id'] as String;
        writeAccountData(data);
      }

      final session = await stripeClient.createFinancialConnectionsSession(
        customerType: 'customer',
        customerId: data.customerId!,
        permissions: ['transactions', 'balances'],
        prefetch: ['transactions'],
      );

      return Response.ok(
        jsonEncode({'clientSecret': session['client_secret']}),
        headers: {'Content-Type': 'application/json'},
      );
    } on StripeException catch (e) {
      final message = e.type == 'authentication_error'
          ? 'Invalid Stripe API key'
          : e.message;
      return Response.internalServerError(
        body: jsonEncode({'error': message}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/save-account', (Request request) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final accountId = body['accountId'] as String?;

      if (accountId == null || accountId.isEmpty) {
        return Response(400,
            body: jsonEncode({'error': 'accountId is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      try {
        await stripeClient.subscribeAccount(accountId, ['transactions']);
      } catch (e) {
        print('Subscribe skipped (account may be inactive): $e');
      }

      final data = readAccountData();
      if (!data.accounts.any((a) => a.id == accountId)) {
        data.accounts.add(LinkedAccount(
          id: accountId,
          institution: body['institution'] as String?,
          displayName: body['displayName'] as String?,
          last4: body['last4'] as String?,
          linkedAt: DateTime.now().toUtc().toIso8601String(),
        ));
        writeAccountData(data);
      }

      return Response.ok(
        jsonEncode({'success': true, 'accountId': accountId}),
        headers: {'Content-Type': 'application/json'},
      );
    } on StripeException catch (e) {
      final message = e.type == 'invalid_request_error'
          ? 'Stripe error: ${e.message}'
          : e.message;
      return Response.internalServerError(
        body: jsonEncode({'error': message}),
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
