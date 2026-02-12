import 'package:flutter/material.dart';
import 'package:minister_shared/models/transaction.dart';
import '../theme.dart';
import 'category_chip.dart';

class TransactionTile extends StatelessWidget {
  final CleanTransaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor =
        AppColors.categoryColors[transaction.category] ??
        AppColors.textTertiary;
    final amountColor = transaction.amount >= 0
        ? AppColors.positive
        : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Category indicator dot
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: catColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _categoryIcon(transaction.category),
                  size: 20,
                  color: catColor,
                ),
              ),
              const SizedBox(width: 14),
              // Description & meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          transaction.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CategoryChip(
                          category: transaction.category,
                          dense: true,
                        ),
                      ],
                    ),
                    if (transaction.accountLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.accountLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Text(
                transaction.amountFormatted,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Dining' => Icons.restaurant_outlined,
      'Grocery' => Icons.local_grocery_store_outlined,
      'Superstore' => Icons.storefront_outlined,
      'Transit' => Icons.directions_bus_outlined,
      'Shopping' => Icons.shopping_bag_outlined,
      'Subscription' => Icons.autorenew_outlined,
      'Gas' => Icons.local_gas_station_outlined,
      'Utilities' => Icons.bolt_outlined,
      'Health' => Icons.favorite_border_outlined,
      'Travel' => Icons.flight_outlined,
      'Transfer' => Icons.swap_horiz_outlined,
      'Entertainment' => Icons.movie_outlined,
      'Rent' => Icons.home_outlined,
      'Fee' => Icons.attach_money_outlined,
      _ => Icons.receipt_outlined,
    };
  }
}
