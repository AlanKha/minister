import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/transaction_detail_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/accounts_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

bool get _isDesktop {
  try {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  } catch (_) {
    return false;
  }
}

class AdaptiveShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final destinations = [
      const _Destination(icon: Icons.dashboard, label: 'Dashboard'),
      const _Destination(icon: Icons.receipt_long, label: 'Transactions'),
      const _Destination(icon: Icons.analytics, label: 'Analytics'),
      const _Destination(icon: Icons.account_balance, label: 'Accounts'),
    ];

    if (_isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) =>
                  navigationShell.goBranch(index),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: destinations
            .map((d) => BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _Destination {
  final IconData icon;
  final String label;
  const _Destination({required this.icon, required this.label});
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdaptiveShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return TransactionDetailScreen(transactionId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accounts',
              builder: (context, state) => const AccountsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
