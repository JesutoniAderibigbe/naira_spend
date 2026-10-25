import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../logic/budget_status.dart';
import '../../logic/budgets.dart';
import '../../logic/controllers/budgets_controller.dart';
import '../../logic/labels.dart';
import '../../logic/money.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/message_box.dart';
import '../widgets/progress_bar.dart';

/// Budgets: this month's spending against each category's limit.
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key, required this.controller});

  final BudgetsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final lines = controller.lines;
            final over = controller.over;
            return ListView(
              key: const ValueKey('budgets.list'),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthYearLabel(controller.now),
                            style: AppTypography.body.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Budgets', style: AppTypography.h1),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      key: const ValueKey('budgets.edit'),
                      onPressed: () => _edit(context),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (controller.error != null)
                  const _Empty(
                    key: ValueKey('budgets.error'),
                    text: 'Could not load your budgets. Check your connection.',
                  )
                else if (lines.isEmpty)
                  const _Empty(
                    key: ValueKey('budgets.empty'),
                    text:
                        'No budgets yet. Tap Edit to set a monthly limit for '
                        'each category.',
                  )
                else ...[
                  if (over.isNotEmpty) ...[
                    _OverAlert(over: over),
                    const SizedBox(height: 12),
                  ],
                  for (final line in lines) ...[
                    _BudgetCard(line: line),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    // A floating snackbar would cover the sheet's Save button.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final limits = await showModalBottomSheet<Map<Category, int>>(
      context: context,
      // Above the bottom navigation bar, not inside the tab.
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditSheet(initial: controller.limits),
    );
    if (limits != null) await controller.saveLimits(limits);
  }
}

class _OverAlert extends StatelessWidget {
  const _OverAlert({required this.over});

  final List<BudgetLine> over;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final first = over.first;
    final headline = over.length == 1
        ? '${first.category.label} is '
              '${formatNaira((first.status as BudgetOver).overByKobo)} '
              'over budget'
        : '${over.length} categories are over budget';
    return MessageBox(
      key: const ValueKey('budgets.alert'),
      colors: colors.alert,
      icon: Icons.warning_amber_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: AppTypography.strong.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Raise the limit or cut back for the rest of the month.'),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.line});

  final BudgetLine line;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<BudgetStatusColors>()!;
    final colors = switch (line.status) {
      BudgetFine() => statusColors.fine,
      BudgetNearLimit() => statusColors.near,
      BudgetAtLimit() => statusColors.atLimit,
      BudgetOver() => statusColors.over,
    };
    return AppCard(
      key: ValueKey('budget.${line.category.name}'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(line.category.label, style: AppTypography.title),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: formatNaira(line.spentKobo),
                      style: AppTypography.strong,
                    ),
                    TextSpan(
                      text: ' of ${formatNaira(line.limitKobo)}',
                      style: AppTypography.small.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: line.fill,
            color: colors.indicator,
            trackColor: colors.track,
          ),
          const SizedBox(height: 10),
          Text(
            line.status.label,
            key: ValueKey('budget.${line.category.name}.status'),
            style: AppTypography.smallStrong.copyWith(color: colors.text),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.small.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Sets a monthly limit per category. Empty means no limit.
class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.initial});

  final Map<Category, int> initial;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final _fields = {
    for (final c in Category.values)
      c: TextEditingController(
        text: widget.initial[c] == null
            ? ''
            : formatNairaInput(formatNaira(widget.initial[c]!)),
      ),
  };
  final _errors = <Category, String>{};

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _format(TextEditingController field, String text) {
    final formatted = formatNairaInput(text);
    if (formatted != text) {
      field.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _save() {
    final limits = <Category, int>{};
    _errors.clear();
    for (final MapEntry(key: category, value: field) in _fields.entries) {
      final text = field.text.trim();
      final kobo = text.isEmpty ? 0 : parseNairaToKobo(text);
      if (kobo == null) {
        _errors[category] = 'Enter an amount like 15,000';
      } else {
        limits[category] = kobo;
      }
    }
    if (_errors.isNotEmpty) {
      setState(() {});
      return;
    }
    Navigator.of(context).pop(limits);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Monthly limits', style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(
              'Leave a category empty for no limit.',
              style: AppTypography.small.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final category in Category.values) ...[
              Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(category.label, style: AppTypography.title),
                  ),
                  Expanded(
                    child: TextField(
                      key: ValueKey('budgetEdit.${category.name}'),
                      controller: _fields[category],
                      onChanged: (t) => _format(_fields[category]!, t),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₦ ',
                        hintText: 'No limit',
                        isDense: true,
                        errorText: _errors[category],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('budgetEdit.save'),
              onPressed: _save,
              child: const Text('Save limits'),
            ),
          ],
        ),
      ),
    );
  }
}
