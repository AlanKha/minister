import 'package:flutter/material.dart';

const _categoryColors = <String, Color>{
  'Dining': Color(0xFFE57373),
  'Grocery': Color(0xFF81C784),
  'Superstore': Color(0xFF64B5F6),
  'Transit': Color(0xFFFFB74D),
  'Shopping': Color(0xFFBA68C8),
  'Subscription': Color(0xFF4FC3F7),
  'Gas': Color(0xFFA1887F),
  'Utilities': Color(0xFF90A4AE),
  'Health': Color(0xFFFF8A65),
  'Travel': Color(0xFF4DD0E1),
  'Transfer': Color(0xFFAED581),
  'Entertainment': Color(0xFFF06292),
  'Rent': Color(0xFF7986CB),
  'Fee': Color(0xFFE0E0E0),
  'N/A': Color(0xFFBDBDBD),
};

class CategoryChip extends StatelessWidget {
  final String category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[category] ?? _categoryColors['N/A']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

List<String> get allCategories => _categoryColors.keys.toList();
