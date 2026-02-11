import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minister_shared/models/account.dart';
import 'package:minister_shared/models/analytics.dart';
import 'package:minister_shared/models/transaction.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/sync_button.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
import '../theme.dart';

bool get _isDesktop {
  try {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  } catch (_) {
    return false;
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoryBreakdownProvider);

    final width = MediaQuery.of(context).size.width;
    final showSidebar = _isDesktop && width > 900;

    final mainContent = _buildMainContent(
      context,
      ref,
      accounts,
      transactions,
      categories,
      width,
    );

    if (!showSidebar) return mainContent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(flex: 3, child: mainContent),
          SizedBox(
            width: 320,
            child: _DesktopSidebar(
              accounts: accounts,
              transactions: transactions,
              categories: categories,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LinkedAccount>> accounts,
    AsyncValue<TransactionPage> transactions,
    AsyncValue<List<CategoryBreakdown>> categories,
    double width,
  ) {
    final isNarrow = width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(categoryBreakdownProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Premium Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your financial snapshot',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SyncButton(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Metric Cards - Fixed responsive sizing
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _MetricCardsGrid(
                  accounts: accounts,
                  transactions: transactions,
                  categories: categories,
                  narrow: isNarrow,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Spending Chart Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _PremiumCard(
                  title: 'Spending by Category',
                  subtitle: 'Tap sections to see details',
                  child: SizedBox(
                    height: 220,
                    child: categories.when(
                      data: (data) => CategoryPieChart(data: data),
                      loading: () => const _ChartLoading(),
                      error: (e, _) => _ChartError(error: e.toString()),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Recent Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/transactions'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Recent Transactions List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _PremiumCard(
                  child: transactions.when(
                    data: (page) {
                      if (page.data.isEmpty) {
                        return const _EmptyTransactionsState();
                      }
                      final items = page.data.take(8).toList();
                      return Column(
                        children: items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tx = entry.value;
                          return Column(
                            children: [
                              if (index > 0)
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: AppColors.border,
                                ),
                              TransactionTile(
                                transaction: tx,
                                onTap: () =>
                                    context.go('/transactions/${tx.id}'),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const _TransactionsLoading(),
                    error: (e, _) => _TransactionsError(error: e.toString()),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;

  const _PremiumCard({this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (title != null) const SizedBox(height: 20),
          child,
          if (title != null) const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Metric Cards Grid with Fixed Sizing ──────────────────────────
class _MetricCardsGrid extends StatelessWidget {
  final AsyncValue<List<LinkedAccount>> accounts;
  final AsyncValue<TransactionPage> transactions;
  final AsyncValue<List<CategoryBreakdown>> categories;
  final bool narrow;

  const _MetricCardsGrid({
    required this.accounts,
    required this.transactions,
    required this.categories,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for consistent sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = narrow
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;

        Widget buildCard(Widget child) {
          return SizedBox(width: cardWidth, child: child);
        }

        final cards = [
          buildCard(
            accounts.when(
              data: (accts) => _MetricCard(
                label: 'ACCOUNTS',
                value: '${accts.length}',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.info,
              ),
              loading: () => const _MetricCardLoading(),
              error: (e, _) => _MetricCardError(error: e.toString()),
            ),
          ),
          buildCard(
            transactions.when(
              data: (page) => _MetricCard(
                label: 'TRANSACTIONS',
                value: '${page.total}',
                icon: Icons.receipt_long_outlined,
                color: AppColors.accent,
              ),
              loading: () => const _MetricCardLoading(),
              error: (e, _) => _MetricCardError(error: e.toString()),
            ),
          ),
          buildCard(
            categories.when(
              data: (cats) {
                int totalCents = 0;
                for (final c in cats) {
                  totalCents += c.totalCents.abs();
                }
                return _MetricCard(
                  label: 'TOTAL SPENT',
                  value: '\$${(totalCents / 100).toStringAsFixed(0)}',
                  icon: Icons.trending_down_rounded,
                  color: AppColors.negative,
                );
              },
              loading: () => const _MetricCardLoading(),
              error: (e, _) => _MetricCardError(error: e.toString()),
            ),
          ),
          buildCard(_buildAvgCard()),
        ];

        if (narrow) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [cards[0], cards[1]],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [cards[2], cards[3]],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: cards,
        );
      },
    );
  }

  Widget _buildAvgCard() {
    return categories.when(
      data: (cats) {
        return transactions.when(
          data: (page) {
            int totalCents = 0;
            for (final c in cats) {
              totalCents += c.totalCents.abs();
            }
            final count = page.total;
            final avg = count > 0 ? totalCents / count / 100 : 0.0;
            return _MetricCard(
              label: 'AVG TRANSACTION',
              value: '\$${avg.toStringAsFixed(0)}',
              icon: Icons.calculate_outlined,
              color: AppColors.positive,
            );
          },
          loading: () => const _MetricCardLoading(),
          error: (e, _) => _MetricCardError(error: e.toString()),
        );
      },
      loading: () => const _MetricCardLoading(),
      error: (e, _) => _MetricCardError(error: e.toString()),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary.withValues(alpha: 0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardLoading extends StatelessWidget {
  const _MetricCardLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _MetricCardError extends StatelessWidget {
  final String error;
  const _MetricCardError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.negativeLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.negative.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.negative, size: 22),
          const SizedBox(height: 12),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: AppColors.negative),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                6,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartError extends StatelessWidget {
  final String error;
  const _ChartError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load chart',
            style: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sync your accounts to import data',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsLoading extends StatelessWidget {
  const _TransactionsLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surface,
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsError extends StatelessWidget {
  final String error;
  const _TransactionsError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.negative,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load transactions',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Desktop Summary Sidebar ───────────────────────────────────
class _DesktopSidebar extends StatelessWidget {
  final AsyncValue<List<LinkedAccount>> accounts;
  final AsyncValue<TransactionPage> transactions;
  final AsyncValue<List<CategoryBreakdown>> categories;

  const _DesktopSidebar({
    required this.accounts,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceContainerHigh, AppColors.surface],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                accounts.when(
                  data: (accts) => _SummaryRow(
                    label: 'Total Accounts',
                    value: '${accts.length}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  loading: () => const _SummaryRowLoading(),
                  error: (_, __) => const _SummaryRow(
                    label: 'Total Accounts',
                    value: '--',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border),
                ),
                transactions.when(
                  data: (page) => _SummaryRow(
                    label: 'Total Transactions',
                    value: '${page.total}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  loading: () => const _SummaryRowLoading(),
                  error: (_, __) => const _SummaryRow(
                    label: 'Total Transactions',
                    value: '--',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border),
                ),
                categories.when(
                  data: (cats) {
                    int totalCents = 0;
                    for (final c in cats) {
                      totalCents += c.totalCents.abs();
                    }
                    return _SummaryRow(
                      label: 'Total Spending',
                      value: '\$${(totalCents / 100).toStringAsFixed(2)}',
                      icon: Icons.trending_down_rounded,
                      valueColor: AppColors.negative,
                    );
                  },
                  loading: () => const _SummaryRowLoading(),
                  error: (_, __) => const _SummaryRow(
                    label: 'Total Spending',
                    value: '--',
                    icon: Icons.trending_down_rounded,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border),
                ),
                _buildAvgRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvgRow() {
    return categories.when(
      data: (cats) {
        return transactions.when(
          data: (page) {
            int totalCents = 0;
            for (final c in cats) {
              totalCents += c.totalCents.abs();
            }
            final count = page.total;
            final avg = count > 0 ? totalCents / count / 100 : 0.0;
            return _SummaryRow(
              label: 'Avg Transaction',
              value: '\$${avg.toStringAsFixed(2)}',
              icon: Icons.calculate_outlined,
            );
          },
          loading: () => const _SummaryRowLoading(),
          error: (_, __) => const _SummaryRow(
            label: 'Avg Transaction',
            value: '--',
            icon: Icons.calculate_outlined,
          ),
        );
      },
      loading: () => const _SummaryRowLoading(),
      error: (_, __) => const _SummaryRow(
        label: 'Avg Transaction',
        value: '--',
        icon: Icons.calculate_outlined,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: AppColors.accent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _SummaryRowLoading extends StatelessWidget {
  const _SummaryRowLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
