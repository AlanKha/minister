import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';
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

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filters.search != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(transactionFiltersProvider.notifier).state =
                            filters.copyWith(clearSearch: true, page: 1);
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
          const SizedBox(height: 8),
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category dropdown
                _FilterDropdown(
                  label: filters.category ?? 'Category',
                  isActive: filters.category != null,
                  items: allCategories
                      .where((c) => c != 'N/A')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    ref.read(transactionFiltersProvider.notifier).state =
                        filters.copyWith(category: value, page: 1);
                  },
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
                // Sort dropdown
                _FilterDropdown(
                  label: _sortLabel(filters.sort),
                  isActive: filters.sort != 'date_desc',
                  items: const [
                    DropdownMenuItem(
                        value: 'date_desc', child: Text('Newest first')),
                    DropdownMenuItem(
                        value: 'date_asc', child: Text('Oldest first')),
                    DropdownMenuItem(
                        value: 'amount_asc', child: Text('Lowest amount')),
                    DropdownMenuItem(
                        value: 'amount_desc', child: Text('Highest amount')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(transactionFiltersProvider.notifier).state =
                          filters.copyWith(sort: value, page: 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'date_asc':
        return 'Oldest first';
      case 'amount_asc':
        return 'Lowest amount';
      case 'amount_desc':
        return 'Highest amount';
      default:
        return 'Newest first';
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final bool isActive;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onClear;

  const _FilterDropdown({
    required this.label,
    required this.isActive,
    required this.items,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      selected: isActive,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => ListView(
            shrinkWrap: true,
            children: [
              if (onClear != null)
                ListTile(
                  title: const Text('Clear filter'),
                  leading: const Icon(Icons.clear),
                  onTap: () {
                    onClear!();
                    Navigator.pop(ctx);
                  },
                ),
              ...items.map((item) => ListTile(
                    title: item.child,
                    onTap: () {
                      onChanged(item.value);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
      onDeleted: onClear,
    );
  }
}
