import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minister_shared/models/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/refresh_helpers.dart';
import '../utils/snackbar_helpers.dart';
import '../widgets/category_chip.dart';
import '../theme.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  bool _saving = false;
  CleanTransaction? _cachedTransaction;
  bool _pinned = false;
  bool _pinnedLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPinnedState();
  }

  Future<void> _loadPinnedState() async {
    try {
      final client = ref.read(apiClientProvider);
      final pinned = await client.getPinnedTransactions();
      if (mounted) {
        setState(() {
          _pinned = pinned.contains(widget.transactionId);
          _pinnedLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _pinnedLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txPage = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: txPage.when(
        data: (page) {
          final tx = page.data
              .where((t) => t.id == widget.transactionId)
              .firstOrNull;
          if (tx != null) {
            _cachedTransaction = tx;
          }
          if (_cachedTransaction == null) {
            return Center(
              child: Text(
                'Transaction not found',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            );
          }
          return _buildDetail(context, _cachedTransaction!);
        },
        loading: () {
          if (_cachedTransaction != null) {
            return _buildDetail(context, _cachedTransaction!);
          }
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2,
            ),
          );
        },
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.negative),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, CleanTransaction tx) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        // Amount
        Center(
          child: Text(
            tx.amountFormatted,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: tx.amount >= 0
                  ? AppColors.positive
                  : AppColors.textPrimary,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: CategoryChip(category: tx.category)),
        const SizedBox(height: 28),

        // Details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _DetailRow(label: 'Description', value: tx.description),
              _divider(),
              _DetailRow(label: 'Date', value: tx.date),
              _divider(),
              _DetailRow(label: 'Status', value: tx.status),
              _divider(),
              _DetailRow(label: 'Account', value: tx.accountLabel),
              _divider(),
              _DetailRow(label: 'ID', value: tx.id),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Manual tag toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                _pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 20,
                color: _pinned ? AppColors.accent : AppColors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual Tag',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Keep this category during re-categorization',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_pinnedLoaded)
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                )
              else
                Switch.adaptive(
                  value: _pinned,
                  onChanged: _saving ? null : (val) => _togglePin(tx.id, val),
                  activeTrackColor: AppColors.accent,
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Change category
        const Text(
          'Change Category',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCategories.map((cat) {
            final isSelected = cat == tx.category;
            final catColor =
                AppColors.categoryColors[cat] ?? AppColors.textTertiary;
            return GestureDetector(
              onTap: _saving
                  ? null
                  : () {
                      if (!isSelected) _updateCategory(tx.id, cat);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? catColor.withValues(alpha: 0.15)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? catColor.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? catColor : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Divider(color: AppColors.border, height: 16),
    );
  }

  Future<void> _togglePin(String id, bool pinned) async {
    setState(() => _saving = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.updateTransaction(id, pinned: pinned);
      if (mounted) {
        setState(() => _pinned = pinned);
        showSuccessSnackbar(
          context,
          pinned ? 'Category pinned' : 'Category unpinned',
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateCategory(String id, String category) async {
    setState(() => _saving = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.updateTransaction(id, category: category, pinned: true);
      if (_cachedTransaction != null) {
        _cachedTransaction!.category = category;
      }
      setState(() => _pinned = true);
      invalidateTransactionsAndAnalyticsWidget(ref);
      if (mounted) {
        showSuccessSnackbar(context, 'Category updated to $category');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
