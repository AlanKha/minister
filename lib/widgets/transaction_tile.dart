import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'category_chip.dart';

class TransactionTile extends StatelessWidget {
  final CleanTransaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      title: Text(
        transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(transaction.date, style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          CategoryChip(category: transaction.category),
        ],
      ),
      trailing: Text(
        transaction.amountFormatted,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
