import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';
import '../theme.dart';
import 'category_chip.dart';

class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({super.key});

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(transactionFiltersProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.textTertiary),
              suffixIcon: filters.search != null
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textTertiary),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(transactionFiltersProvider.notifier).state =
                            filters.copyWith(clearSearch: true, page: 1);
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) {
              if (value.isEmpty) {
                ref.read(transactionFiltersProvider.notifier).state =
                    filters.copyWith(clearSearch: true, page: 1);
              } else {
                ref.read(transactionFiltersProvider.notifier).state =
                    filters.copyWith(search: value, page: 1);
              }
            },
          ),
          const SizedBox(height: 10),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                  label: filters.category ?? 'Category',
                  isActive: filters.category != null,
                  onTap: () => _showCategorySheet(context, filters),
                  onClear: filters.category != null
                      ? () {
                          ref
                              .read(transactionFiltersProvider.notifier)
                              .state =
                              filters.copyWith(clearCategory: true, page: 1);
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: _sortLabel(filters.sort),
                  isActive: filters.sort != 'date_desc',
                  onTap: () => _showSortSheet(context, filters),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context, TransactionFilters filters) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (filters.category != null)
            ListTile(
              title: const Text('Clear filter'),
              leading: const Icon(Icons.close_rounded, size: 20),
              onTap: () {
                ref.read(transactionFiltersProvider.notifier).state =
                    filters.copyWith(clearCategory: true, page: 1);
                Navigator.pop(ctx);
              },
            ),
          ...allCategories.where((c) => c != 'N/A').map((c) => ListTile(
                title: Text(c),
                onTap: () {
                  ref.read(transactionFiltersProvider.notifier).state =
                      filters.copyWith(category: c, page: 1);
                  Navigator.pop(ctx);
                },
              )),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context, TransactionFilters filters) {
    final options = {
      'date_desc': 'Newest first',
      'date_asc': 'Oldest first',
      'amount_asc': 'Lowest amount',
      'amount_desc': 'Highest amount',
    };

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: options.entries
            .map((e) => ListTile(
                  title: Text(e.value),
                  trailing: e.key == filters.sort
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.accent, size: 20)
                      : null,
                  onTap: () {
                    ref.read(transactionFiltersProvider.notifier).state =
                        filters.copyWith(sort: e.key, page: 1);
                    Navigator.pop(ctx);
                  },
                ))
            .toList(),
      ),
    );
  }

  String _sortLabel(String sort) {
    return switch (sort) {
      'date_asc' => 'Oldest first',
      'amount_asc' => 'Lowest amount',
      'amount_desc' => 'Highest amount',
      _ => 'Newest first',
    };
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentSurface
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    isActive ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isActive ? AppColors.accent : AppColors.textTertiary,
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isActive ? AppColors.accent : AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
