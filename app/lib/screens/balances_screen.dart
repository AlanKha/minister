import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/accounts_provider.dart';
import '../providers/balances_provider.dart';
import '../utils/snackbar_helpers.dart';
import '../theme.dart';

final _currencyFormat = NumberFormat.currency(symbol: '\$');

class BalancesScreen extends ConsumerStatefulWidget {
  const BalancesScreen({super.key});

  @override
  ConsumerState<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends ConsumerState<BalancesScreen> {
  bool _refreshing = false;

  Future<void> _refreshBalances() async {
    setState(() => _refreshing = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.refreshBalances();
      ref.invalidate(balancesProvider);
      if (mounted) {
        showSuccessSnackbar(context, 'Balances refreshed');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Refresh failed: $e');
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balances = ref.watch(balancesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: balances.when(
        data: (data) => _buildContent(data),
        loading: () => const _BalancesLoading(),
        error: (e, _) => _ErrorState(
          error: e.toString(),
          onRetry: () => ref.invalidate(balancesProvider),
        ),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> data) {
    final hasAnyBalance = data.any((d) => d['balance'] != null);

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: () async => ref.invalidate(balancesProvider),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balances',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.isEmpty
                        ? 'Connect accounts to see balances'
                        : '${data.length} linked account${data.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total balance card
          if (hasAnyBalance)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _TotalBalanceCard(data: data),
              ),
            ),

          // Cost warning + refresh button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: _RefreshSection(
                refreshing: _refreshing,
                accountCount: data.length,
                onRefresh: _refreshBalances,
              ),
            ),
          ),

          // Account balance cards
          if (data.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BalanceCard(data: data[index]),
                  ),
                  childCount: data.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _TotalBalanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    int totalCents = 0;
    int accountsWithBalance = 0;

    for (final d in data) {
      final balance = d['balance'] as Map<String, dynamic>?;
      if (balance == null) continue;

      final current = balance['current'] as Map<String, dynamic>?;
      if (current != null) {
        final usd = current['usd'] as int?;
        if (usd != null) {
          totalCents += usd;
          accountsWithBalance++;
        }
      }
    }

    if (accountsWithBalance == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _currencyFormat.format(totalCents / 100),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Across $accountsWithBalance account${accountsWithBalance != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshSection extends StatelessWidget {
  final bool refreshing;
  final int accountCount;
  final VoidCallback onRefresh;

  const _RefreshSection({
    required this.refreshing,
    required this.accountCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cost = (accountCount * 0.10).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manual Refresh',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Each refresh costs ~\$$cost ($accountCount account${accountCount != 1 ? 's' : ''} x \$0.10)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: refreshing ? null : () {
              HapticFeedback.mediumImpact();
              onRefresh();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: refreshing
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                      ),
                color: refreshing ? AppColors.surfaceContainerHigh : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: refreshing
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: refreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BalanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final institution = data['institution'] as String? ?? 'Bank Account';
    final displayName = data['display_name'] as String?;
    final last4 = data['last4'] as String?;
    final balance = data['balance'] as Map<String, dynamic>?;
    final error = data['error'] as String?;
    final lastRefreshed = data['last_refreshed'] as String?;

    final label = [
      if (displayName != null && displayName.isNotEmpty) displayName,
      if (last4 != null && last4.isNotEmpty) '••••$last4',
    ].join(' ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.info.withValues(alpha: 0.15),
                      AppColors.info.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  size: 22,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      institution,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (label.isNotEmpty)
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Balance info
          if (error != null)
            _BalanceError(error: error)
          else if (balance == null)
            const _NoBalanceData()
          else
            _BalanceDetails(balance: balance),

          // Last refreshed
          if (lastRefreshed != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: AppColors.textTertiary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_formatTimestamp(lastRefreshed)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(String iso) {
    try {
      final date = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return iso;
    }
  }
}

class _BalanceDetails extends StatelessWidget {
  final Map<String, dynamic> balance;
  const _BalanceDetails({required this.balance});

  @override
  Widget build(BuildContext context) {
    final type = balance['type'] as String? ?? 'cash';
    final current = balance['current'] as Map<String, dynamic>?;
    final cash = balance['cash'] as Map<String, dynamic>?;
    final credit = balance['credit'] as Map<String, dynamic>?;
    final asOf = balance['as_of'] as int?;

    final currentUsd = current?['usd'] as int?;
    final availableUsd =
        (cash?['available'] as Map<String, dynamic>?)?['usd'] as int?;
    final usedUsd =
        (credit?['used'] as Map<String, dynamic>?)?['usd'] as int?;

    return Column(
      children: [
        if (currentUsd != null)
          _BalanceRow(
            label: 'Current Balance',
            amount: currentUsd,
            isPrimary: true,
          ),
        if (availableUsd != null && type == 'cash') ...[
          const SizedBox(height: 10),
          _BalanceRow(label: 'Available', amount: availableUsd),
        ],
        if (usedUsd != null && type == 'credit') ...[
          const SizedBox(height: 10),
          _BalanceRow(label: 'Used', amount: usedUsd),
        ],
        if (asOf != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'As of ${_formatAsOf(asOf)}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatAsOf(int unixTimestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    return DateFormat('MMM d, h:mm a').format(date);
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isPrimary;

  const _BalanceRow({
    required this.label,
    required this.amount,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isPrimary ? 14 : 13,
            fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
            color: isPrimary ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          _currencyFormat.format(amount / 100),
          style: TextStyle(
            fontSize: isPrimary ? 22 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: isPrimary ? -0.5 : 0,
          ),
        ),
      ],
    );
  }
}

class _BalanceError extends StatelessWidget {
  final String error;
  const _BalanceError({required this.error});

  @override
  Widget build(BuildContext context) {
    final needsRelink = error.contains('permission') ||
        error.contains('not supported') ||
        error.contains('not_supported');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              needsRelink
                  ? 'Balance access not enabled. Re-link this account to grant balance permission.'
                  : error,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBalanceData extends StatelessWidget {
  const _NoBalanceData();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textTertiary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No balance data yet. Tap Refresh to fetch balances.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 44,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No accounts linked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Link a bank account first to view balances',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalancesLoading extends StatelessWidget {
  const _BalancesLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surfaceContainer,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.negativeLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: AppColors.negative,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
