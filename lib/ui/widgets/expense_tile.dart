import 'package:flutter/material.dart';

import '../../data/models/expense.dart';
import '../../logic/labels.dart';
import '../../logic/money.dart';
import '../theme/app_theme.dart';
import 'category_icon.dart';

/// One expense row: category icon, title, "Category · Day", amount, delete.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.now,
    required this.onDelete,
  });

  final Expense expense;
  final DateTime now;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Row(
        children: [
          CategoryIcon(expense.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: AppTypography.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.category.label} · '
                  '${relativeDayLabel(expense.date, now)}',
                  style: AppTypography.small.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(formatNaira(expense.amountKobo), style: AppTypography.amountRow),
          IconButton(
            key: ValueKey('expense.${expense.id}.delete'),
            tooltip: 'Delete ${expense.title}',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
