import 'package:flutter/material.dart';
import '../theme.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool dense;

  const CategoryChip({super.key, required this.category, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.categoryColors[category] ?? AppColors.categoryColors['Uncategorized']!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: dense ? 11 : 12,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

List<String> get allCategories => AppColors.categoryColors.keys.toList();
