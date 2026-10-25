import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../data/repositories/expense_repository.dart';
import '../../logic/controllers/add_expense_controller.dart';
import '../../logic/labels.dart';
import '../theme/app_theme.dart';
import '../widgets/category_icon.dart';

/// Add expense: amount, what it was, category and date.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.expenses,
    required this.clock,
    required this.onDone,
  });

  final ExpenseRepository expenses;
  final DateTime Function() clock;

  /// Called after saving or closing, to leave the screen.
  final void Function(String? savedTitle) onDone;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final _controller = AddExpenseController(
    expenses: widget.expenses,
    clock: widget.clock,
  );
  final _amount = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onAmountChanged(String text) {
    _controller.amount = text;
    final formatted = _controller.amount;
    if (formatted != text) {
      _amount.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = _controller.now;
    final today = DateTime(now.year, now.month, now.day);
    final day = _controller.day;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(day.year, day.month, day.day),
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today.add(const Duration(days: 1)),
    );
    if (picked != null) _controller.day = picked;
  }

  Future<void> _save() async {
    final title = _controller.title.trim();
    if (await _controller.save()) widget.onDone(title);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('addExpense.close'),
                      tooltip: 'Close',
                      onPressed: () => widget.onDone(null),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 4),
                    Text('Add expense', style: AppTypography.h2),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _Label('Amount'),
                    TextField(
                      key: const ValueKey('addExpense.amount'),
                      controller: _amount,
                      onChanged: _onAmountChanged,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTypography.amountLarge,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: '0',
                        hintStyle: AppTypography.amountLarge.copyWith(
                          color: scheme.outline,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '₦',
                            style: AppTypography.amountLarge.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: scheme.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: scheme.primary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: scheme.primary,
                            width: 3,
                          ),
                        ),
                        // Keep the underline style when showing an error.
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: scheme.error, width: 2),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: scheme.error, width: 3),
                        ),
                        errorText: _controller.amountError,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Label('What did you buy?'),
                    TextField(
                      key: const ValueKey('addExpense.title'),
                      onChanged: (v) => _controller.title = v,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: 'e.g. Suya',
                        errorText: _controller.titleError,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Label('Category'),
                    _CategoryGrid(
                      selected: _controller.category,
                      onSelected: (c) => _controller.category = c,
                    ),
                    if (_controller.categoryError case final error?)
                      _ErrorText(
                        error,
                        key: const ValueKey('addExpense.categoryError'),
                      ),
                    const SizedBox(height: 16),
                    _DateRow(
                      label: dateRowLabel(_controller.day, _controller.now),
                      onChange: _pickDate,
                    ),
                    if (_controller.dayError case final error?)
                      _ErrorText(error),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  key: const ValueKey('addExpense.save'),
                  onPressed: _controller.isSaving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: AppTypography.smallStrong.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected, required this.onSelected});

  final Category? selected;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    const columns = 3;
    final rows = [
      for (var i = 0; i < Category.values.length; i += columns)
        Category.values.skip(i).take(columns).toList(),
    ];
    return Column(
      children: [
        for (final (r, row) in rows.indexed) ...[
          if (r > 0) const SizedBox(height: 10),
          Row(
            children: [
              for (final (i, category) in row.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _CategoryTile(
                    category: category,
                    isSelected: category == selected,
                    onTap: () => onSelected(category),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? scheme.primaryContainer
            : scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: ValueKey('category.${category.name}'),
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(
                  CategoryIcon.iconFor(category),
                  size: 22,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  style: isSelected
                      ? AppTypography.strong
                      : AppTypography.body.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.onChange});

  final String label;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: scheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              key: const ValueKey('addExpense.date'),
              style: AppTypography.body,
            ),
          ),
          TextButton(
            key: const ValueKey('addExpense.changeDate'),
            onPressed: onChange,
            child: const Text('Change date'),
          ),
        ],
      ),
    );
  }
}
