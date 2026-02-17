import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minister_shared/models/account.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/accounts_provider.dart';
import '../theme.dart';

bool get _isDesktop {
  try {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  } catch (_) {
    return false;
  }
}

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);

    final width = MediaQuery.of(context).size.width;
    final showSidebar = _isDesktop && width > 900;

    final mainContent = _buildMain(context, ref, accounts);

    if (!showSidebar) return mainContent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(flex: 3, child: mainContent),
          SizedBox(width: 320, child: _AccountsSidebar(accounts: accounts)),
        ],
      ),
    );
  }

  Widget _buildMain(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LinkedAccount>> accounts,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: accounts.when(
        data: (accts) {
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(accountsProvider),
            child: CustomScrollView(
              slivers: [
                //  Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Accounts',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              accts.isEmpty
                                  ? 'Connect your bank to get started'
                                  : '${accts.length} linked account${accts.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        _LinkAccountButton(),
                      ],
                    ),
                  ),
                ),
                if (accts.isEmpty)
                  SliverFillRemaining(child: _EmptyState())
                else
                  ..._buildGroupedAccounts(accts),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
        loading: () => const _AccountsLoading(),
        error: (e, _) => _ErrorState(
          error: e.toString(),
          onRetry: () => ref.invalidate(accountsProvider),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedAccounts(List<LinkedAccount> accts) {
    // Group by institution
    final grouped = <String, List<LinkedAccount>>{};
    for (final acct in accts) {
      final inst = acct.institution ?? 'Other';
      grouped.putIfAbsent(inst, () => []).add(acct);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      // Section header
      widgets.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      // Accounts in this group
      widgets.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final acct = entry.value[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AccountCard(account: acct),
              );
            }, childCount: entry.value.length),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _AccountCard extends StatelessWidget {
  final LinkedAccount account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.shadowColorStrong,
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.info.withValues(alpha: 0.1),
                          AppColors.info.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      size: 24,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppColors.textTertiary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Linked ${_formatDate(account.linkedAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textTertiary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.positiveLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.positive.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.positive,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.positive,
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
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return 'today';
      if (diff.inDays == 1) return 'yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
      if (diff.inDays < 365) return '${diff.inDays ~/ 30} months ago';
      return '${diff.inDays ~/ 365} years ago';
    } catch (_) {
      return isoDate.substring(0, 10);
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surfaceContainerHigh, AppColors.surface],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                Icons.account_balance_outlined,
                size: 48,
                color: AppColors.textTertiary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No linked accounts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connect your bank accounts to start tracking\nyour spending automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _LinkAccountButton(isLarge: true),
          ],
        ),
      ),
    );
  }
}

class _LinkAccountButton extends StatelessWidget {
  final bool isLarge;

  const _LinkAccountButton({this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/connect-account');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 32 : 20,
          vertical: isLarge ? 18 : 12,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accent, AppColors.accentLight],
          ),
          borderRadius: BorderRadius.circular(isLarge ? 18 : 14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              size: isLarge ? 22 : 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Link Account',
              style: TextStyle(
                fontSize: isLarge ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountsLoading extends StatelessWidget {
  const _AccountsLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surfaceContainer,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                childCount: 3,
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

// ── Desktop sidebar ───────────────────────────────────────────
class _AccountsSidebar extends StatelessWidget {
  final AsyncValue<List<LinkedAccount>> accounts;
  const _AccountsSidebar({required this.accounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(
            color: AppColors.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Account Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          accounts.when(
            data: (accts) {
              final institutions = <String>{};
              for (final a in accts) {
                institutions.add(a.institution ?? 'Other');
              }
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.surfaceContainer, AppColors.surface],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.4),
                    width: 1,
                  ),
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
                    _SummaryRow(
                      label: 'Total Accounts',
                      value: '${accts.length}',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppColors.border),
                    ),
                    _SummaryRow(
                      label: 'Institutions',
                      value: '${institutions.length}',
                      icon: Icons.business_outlined,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppColors.border),
                    ),
                    _SummaryRow(
                      label: 'Status',
                      value: accts.isEmpty ? 'No accounts' : 'All Active',
                      icon: Icons.check_circle_outline,
                      valueColor: accts.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.positive,
                    ),
                  ],
                ),
              );
            },
            loading: () => Shimmer.fromColors(
              baseColor: AppColors.surfaceContainerHigh,
              highlightColor: AppColors.surfaceContainer,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.negativeLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.negative.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Text(
                'Failed to load summary',
                style: TextStyle(color: AppColors.negative),
              ),
            ),
          ),
        ],
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: 14),
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
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
