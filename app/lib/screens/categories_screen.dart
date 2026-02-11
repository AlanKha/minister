import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minister_shared/models/category_rule.dart';
import '../providers/categories_provider.dart';
import '../theme.dart';
import '../widgets/category_chip.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(categoryRulesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorization Rules'), elevation: 0),
      body: rulesAsync.when(
        data: (rules) => _buildContent(context, ref, rules),
        loading: () => const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.negative,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $err',
                style: const TextStyle(color: AppColors.negative),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(categoryRulesNotifierProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRuleDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('New Rule'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<CategoryRule> rules,
  ) {
    if (rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 40,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No rules yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create custom rules to auto-categorize transactions',
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    // Group all rules by category
    final rulesByCategory = <String, List<CategoryRule>>{};
    for (final rule in rules) {
      rulesByCategory.putIfAbsent(rule.category, () => []).add(rule);
    }

    // Sort categories alphabetically for consistent ordering
    final sortedCategories = rulesByCategory.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorization Rules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sortedCategories.length} categories • ${rules.length} rules',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...sortedCategories.map((category) {
          final categoryRules = rulesByCategory[category]!;
          return _buildCollapsibleCategory(
            context,
            ref,
            category,
            categoryRules,
          );
        }),
      ],
    );
  }

  Widget _buildCollapsibleCategory(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<CategoryRule> rules,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _CollapsibleCategoryWidget(
        category: category,
        rules: rules,
        onAddRule: () => _showAddRuleDialog(context, ref, category),
        onEditRule: (rule) => _showEditRuleDialog(context, ref, rule),
        onDeleteRule: (rule) => _showDeleteConfirmation(context, ref, rule),
      ),
    );
  }

  void _showAddRuleDialog(
    BuildContext context,
    WidgetRef ref,
    String? category,
  ) {
    final patternController = TextEditingController();
    final categoryController = TextEditingController(text: category ?? '');
    bool caseSensitive = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Rule'),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: categoryController.text.isEmpty
                      ? null
                      : categoryController.text,
                  items: allCategories
                      .where((c) => c != 'Uncategorized')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => categoryController.text = val ?? '',
                  decoration: InputDecoration(
                    hintText: 'Select category',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Regex Pattern',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: patternController,
                  decoration: InputDecoration(
                    hintText: r'e.g., STARBUCKS|COFFEE',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  autofocus: category != null,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: caseSensitive,
                  onChanged: (val) =>
                      setState(() => caseSensitive = val ?? false),
                  title: const Text(
                    'Case sensitive',
                    style: TextStyle(fontSize: 13),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.accent,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Use regex: STARBUCKS or ^SQ \\* for Square transactions',
                          style: TextStyle(fontSize: 11, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isEmpty ||
                    patternController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  await ref
                      .read(categoryRulesNotifierProvider.notifier)
                      .createRule(
                        category: categoryController.text,
                        pattern: patternController.text,
                        caseSensitive: caseSensitive,
                      );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Rule created')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Create Rule'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRuleDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryRule rule,
  ) {
    final patternController = TextEditingController(text: rule.pattern);
    final categoryController = TextEditingController(text: rule.category);
    bool caseSensitive = rule.caseSensitive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Rule'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: categoryController.text,
                  items: allCategories
                      .where((c) => c != 'Uncategorized')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => categoryController.text = val ?? '',
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pattern',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: patternController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: caseSensitive,
                  onChanged: (val) =>
                      setState(() => caseSensitive = val ?? false),
                  title: const Text(
                    'Case sensitive',
                    style: TextStyle(fontSize: 13),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.accent,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isEmpty ||
                    patternController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  await ref
                      .read(categoryRulesNotifierProvider.notifier)
                      .updateRule(
                        id: rule.id,
                        category: categoryController.text,
                        pattern: patternController.text,
                        caseSensitive: caseSensitive,
                      );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Rule updated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    CategoryRule rule,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text(
          'Remove this rule?\n\n"${rule.pattern}"',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(categoryRulesNotifierProvider.notifier)
                    .deleteRule(rule.id);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Rule deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.negative,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleCategoryWidget extends StatefulWidget {
  final String category;
  final List<CategoryRule> rules;
  final VoidCallback onAddRule;
  final Function(CategoryRule) onEditRule;
  final Function(CategoryRule) onDeleteRule;

  const _CollapsibleCategoryWidget({
    required this.category,
    required this.rules,
    required this.onAddRule,
    required this.onEditRule,
    required this.onDeleteRule,
  });

  @override
  State<_CollapsibleCategoryWidget> createState() =>
      _CollapsibleCategoryWidgetState();
}

class _CollapsibleCategoryWidgetState extends State<_CollapsibleCategoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CategoryChip(category: widget.category),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.rules.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add button
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Material(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              widget.onAddRule();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Expand/collapse icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.expand_more,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Expandable content
          ClipRect(
            child: SizeTransition(
              sizeFactor: _heightFactor,
              axisAlignment: -1.0,
              child: Container(
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    const Divider(height: 1, color: AppColors.border),
                    ...widget.rules.map((rule) => _buildRuleItem(rule)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(CategoryRule rule) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.pattern,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rule.caseSensitive) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Case sensitive',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => widget.onEditRule(rule),
                tooltip: 'Edit',
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => widget.onDeleteRule(rule),
                tooltip: 'Delete',
                color: AppColors.negative,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
