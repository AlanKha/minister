import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/accounts_provider.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accounts.when(
        data: (accts) {
          if (accts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No linked accounts'),
                  const SizedBox(height: 16),
                  _LinkButton(),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(accountsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...accts.map((acct) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.account_balance),
                        title: Text(acct.label),
                        subtitle: Text('Linked ${acct.linkedAt.substring(0, 10)}'),
                      ),
                    )),
                const SizedBox(height: 24),
                Center(child: _LinkButton()),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(accountsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMacOS;
    try {
      isMacOS = Platform.isMacOS;
    } catch (_) {
      isMacOS = false;
    }

    if (isMacOS) {
      return ElevatedButton.icon(
        onPressed: () async {
          final url = Uri.parse('http://localhost:3000');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.open_in_browser),
        label: const Text('Link Account in Browser'),
      );
    }

    // iOS: would use flutter_stripe for native linking
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Native Stripe linking not yet configured'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Link Account'),
    );
  }
}
