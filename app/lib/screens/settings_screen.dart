import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _loadingStats = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadStats();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final client = ref.read(apiClientProvider);
      final stats = await client.getStats();
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (e) {
      setState(() => _loadingStats = false);
      if (mounted) {
        _showSnackbar('Error loading stats: $e', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.negative : AppColors.positive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with gradient
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.05),
                      AppColors.accentLight.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.accent, AppColors.accentLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.settings_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Manage your data & preferences',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStatsSection(),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBackupSection(),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildCategorySection(),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildDataSection(),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildAccountSection(),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Database Overview',
          Icons.analytics_outlined,
        ),
        const SizedBox(height: 16),
        if (_loadingStats)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_stats != null)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                    'Transactions',
                    _stats!['transactions'],
                    Icons.receipt_long_rounded,
                    [const Color(0xFFE8642C), const Color(0xFFF07A4A)],
                    isWide ? constraints.maxWidth / 2 - 6 : constraints.maxWidth,
                  ),
                  _buildStatCard(
                    'Category Rules',
                    _stats!['categoryRules'],
                    Icons.rule_rounded,
                    [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
                    isWide ? constraints.maxWidth / 2 - 6 : constraints.maxWidth,
                  ),
                  _buildStatCard(
                    'Overrides',
                    _stats!['overrides'],
                    Icons.edit_note_rounded,
                    [const Color(0xFFD97706), const Color(0xFFFBBF24)],
                    isWide ? constraints.maxWidth / 2 - 6 : constraints.maxWidth,
                  ),
                  _buildStatCard(
                    'Linked Accounts',
                    _stats!['accounts'],
                    Icons.account_balance_rounded,
                    [const Color(0xFF16A34A), const Color(0xFF4ADE80)],
                    isWide ? constraints.maxWidth / 2 - 6 : constraints.maxWidth,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    dynamic value,
    IconData icon,
    List<Color> gradientColors,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withValues(alpha: 0.08),
            gradientColors[1].withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: gradientColors[0],
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.06),
            AppColors.accentLight.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.cloud_sync_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Backup & Restore',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Export or import your financial data',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildBackupButton(
                        'Download Backup',
                        Icons.download_rounded,
                        () => _downloadBackup(),
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBackupButton(
                        'Restore Data',
                        Icons.upload_rounded,
                        () => _restoreBackup(),
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    {required bool isPrimary}
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  )
                : null,
            color: isPrimary ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return _buildActionSection(
      title: 'Category Rules',
      icon: Icons.category_rounded,
      actions: [
        _ActionItem(
          title: 'Reset to Defaults',
          subtitle: 'Replace all rules with default patterns',
          icon: Icons.refresh_rounded,
          iconColor: AppColors.accent,
          onTap: _showResetRulesDialog,
        ),
        _ActionItem(
          title: 'Clear All Rules',
          subtitle: 'Remove all categorization rules',
          icon: Icons.delete_outline_rounded,
          iconColor: AppColors.negative,
          onTap: _showClearRulesDialog,
          isDangerous: true,
        ),
        _ActionItem(
          title: 'Re-categorize',
          subtitle: 'Apply current rules to all transactions',
          icon: Icons.update_rounded,
          iconColor: const Color(0xFF2563EB),
          onTap: _recategorizeTransactions,
        ),
        _ActionItem(
          title: 'Clear Overrides',
          subtitle: 'Remove manually assigned categories',
          icon: Icons.clear_all_rounded,
          iconColor: AppColors.textSecondary,
          onTap: _showClearOverridesDialog,
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildActionSection(
      title: 'Data Management',
      icon: Icons.storage_rounded,
      actions: [
        _ActionItem(
          title: 'Clear Transactions',
          subtitle: 'Delete all transaction history permanently',
          icon: Icons.delete_sweep_rounded,
          iconColor: AppColors.negative,
          onTap: _showClearTransactionsDialog,
          isDangerous: true,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildActionSection(
      title: 'Accounts',
      icon: Icons.account_balance_rounded,
      actions: [
        _ActionItem(
          title: 'Unlink All Accounts',
          subtitle: 'Remove Plaid connections (keeps data)',
          icon: Icons.link_off_rounded,
          iconColor: AppColors.negative,
          onTap: _showUnlinkAccountsDialog,
          isDangerous: true,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection({
    required String title,
    required IconData icon,
    required List<_ActionItem> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSectionHeader(title, icon),
          ),
          ...actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 1, thickness: 1),
                _buildActionTile(action),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionTile(_ActionItem action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: action.isDangerous
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.negative.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                )
              : null,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: action.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: action.isDangerous
                      ? Border.all(
                          color: action.iconColor.withValues(alpha: 0.2),
                        )
                      : null,
                ),
                child: Icon(action.icon, size: 20, color: action.iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          action.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (action.isDangerous) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.negative.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DANGER',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.negative,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Download backup
  Future<void> _downloadBackup() async {
    try {
      final client = ref.read(apiClientProvider);
      final url = client.getBackupUrl();
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSnackbar('Backup download started');
      } else {
        _showSnackbar('Could not open download link', isError: true);
      }
    } catch (e) {
      _showSnackbar('Failed to download backup: $e', isError: true);
    }
  }

  // Restore backup
  Future<void> _restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();

        if (mounted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Restore Backup?'),
              content: const Text(
                'This will replace all current data with the backup. '
                'Your existing data will be backed up first.\n\n'
                'Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: const Text('Restore'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            final client = ref.read(apiClientProvider);
            await client.restoreBackup(bytes);
            await _loadStats();
            ref.invalidate(categoryRulesNotifierProvider);
            ref.invalidate(accountsProvider);
            if (mounted) {
              _showSnackbar('Backup restored successfully');
            }
          }
        }
      }
    } catch (e) {
      _showSnackbar('Failed to restore backup: $e', isError: true);
    }
  }

  // Dialog methods
  void _showResetRulesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        dialogContext: ctx,
        title: 'Reset Category Rules?',
        content: 'This will replace all your category rules with the default '
            'patterns. Any custom rules you created will be lost. '
            'All transactions will be re-categorized.\n\n'
            'This action cannot be undone.',
        confirmText: 'Reset',
        onConfirm: () async {
          await _performAction(
            action: () => ref.read(apiClientProvider).resetCategoryRules(),
            successMessage: 'Category rules reset to defaults',
            errorPrefix: 'Failed to reset rules',
          );
        },
      ),
    );
  }

  void _showClearRulesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        dialogContext: ctx,
        title: 'Clear All Rules?',
        content: 'This will delete all category rules. '
            'All transactions will become "Uncategorized".\n\n'
            'This action cannot be undone.',
        confirmText: 'Clear',
        isDangerous: true,
        onConfirm: () async {
          await _performAction(
            action: () => ref.read(apiClientProvider).clearCategoryRules(),
            successMessage: 'All category rules cleared',
            errorPrefix: 'Failed to clear rules',
          );
        },
      ),
    );
  }

  void _showClearOverridesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        dialogContext: ctx,
        title: 'Clear Manual Overrides?',
        content: 'This will remove all manually assigned categories. '
            'Category rules will be reapplied to affected transactions.',
        confirmText: 'Clear',
        onConfirm: () async {
          await _performAction(
            action: () => ref.read(apiClientProvider).clearCategoryOverrides(),
            successMessage: 'Manual overrides cleared',
            errorPrefix: 'Failed to clear overrides',
          );
        },
      ),
    );
  }

  void _showClearTransactionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        dialogContext: ctx,
        title: 'Clear Transaction Data?',
        content: 'This will permanently delete all transaction history. '
            'Category rules and account connections will be preserved.\n\n'
            'This action cannot be undone.',
        confirmText: 'Delete All',
        isDangerous: true,
        onConfirm: () async {
          await _performAction(
            action: () => ref.read(apiClientProvider).clearTransactions(),
            successMessage: 'Transaction data cleared',
            errorPrefix: 'Failed to clear transactions',
          );
        },
      ),
    );
  }

  void _showUnlinkAccountsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        dialogContext: ctx,
        title: 'Unlink All Accounts?',
        content: 'This will remove all Plaid account connections. '
            'Your transaction history will be preserved, but you will need to '
            're-link accounts to sync new transactions.\n\n'
            'You can re-link accounts at any time.',
        confirmText: 'Unlink',
        isDangerous: true,
        onConfirm: () async {
          await _performAction(
            action: () => ref.read(apiClientProvider).unlinkAccounts(),
            successMessage: 'All accounts unlinked',
            errorPrefix: 'Failed to unlink accounts',
          );
        },
      ),
    );
  }

  Widget _buildConfirmDialog({
    required BuildContext dialogContext,
    required String title,
    required String content,
    required String confirmText,
    required Future<void> Function() onConfirm,
    bool isDangerous = false,
  }) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDangerous ? AppColors.negative : AppColors.accent,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  Future<void> _recategorizeTransactions() async {
    await _performAction(
      action: () => ref.read(apiClientProvider).recategorizeTransactions(),
      successMessage: 'Transactions re-categorized',
      errorPrefix: 'Failed to re-categorize',
    );
  }

  Future<void> _performAction({
    required Future<Map<String, dynamic>> Function() action,
    required String successMessage,
    required String errorPrefix,
  }) async {
    try {
      await action();
      if (mounted) {
        _showSnackbar(successMessage);
      }
      await _loadStats();
      ref.invalidate(categoryRulesNotifierProvider);
      ref.invalidate(accountsProvider);
    } catch (e) {
      if (mounted) {
        _showSnackbar('$errorPrefix: $e', isError: true);
      }
    }
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDangerous;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isDangerous = false,
  });
}
