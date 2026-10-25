import 'package:flutter/material.dart';

import '../../data/models/expense.dart';
import '../../logic/controllers/home_controller.dart';
import '../../logic/labels.dart';
import '../../logic/money.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/expense_tile.dart';
import '../widgets/spend_bar_chart.dart';

/// Home: spent this week, daily average, spend per day for the last 7 days,
/// recent expenses with delete, and the "Add expense" button.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onAddExpense,
    required this.onAccount,
    this.displayName,
  });

  final HomeController controller;
  final VoidCallback onAddExpense;

  /// Opens the account sheet (sign in with Google, sign out).
  final VoidCallback onAccount;

  /// Shown as initials in the avatar. Null for guests.
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('home.addExpense'),
        onPressed: onAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error != null) {
              return const _Message(
                key: ValueKey('home.error'),
                text: 'Could not load your expenses. Check your connection.',
              );
            }
            return ListView(
              key: const ValueKey('home.list'),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
              children: [
                _Header(
                  now: controller.now,
                  displayName: displayName,
                  onAccount: onAccount,
                ),
                const SizedBox(height: 20),
                _WeekCard(controller: controller),
                const SizedBox(height: 12),
                _ChartCard(controller: controller),
                const SizedBox(height: 20),
                Text('Recent', style: AppTypography.title),
                const SizedBox(height: 10),
                _RecentCard(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.now,
    required this.displayName,
    required this.onAccount,
  });

  final DateTime now;
  final String? displayName;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = initialsFor(displayName);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingFor(now),
                style: AppTypography.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text('Your money', style: AppTypography.h1),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Account',
          excludeSemantics: true,
          child: InkWell(
            key: const ValueKey('home.account'),
            onTap: onAccount,
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: initials.isEmpty
                  ? const Icon(Icons.person_outline)
                  : Text(initials, style: AppTypography.monogram),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final week = controller.week;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Spent this week', style: AppTypography.title),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '7 days',
                  style: AppTypography.captionStrong.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatNaira(week.totalKobo),
              key: const ValueKey('home.weekTotal'),
              style: AppTypography.amountHero,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily average ${formatNaira(week.dailyAverageKobo)}',
            key: const ValueKey('home.dailyAverage'),
            style: AppTypography.small.copyWith(color: colors.bodyText),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spend per day', style: AppTypography.title),
          const SizedBox(height: 16),
          SpendBarChart(
            key: const ValueKey('home.chart'),
            days: controller.week.days,
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final recent = controller.recent;
    if (recent.isEmpty) {
      return const AppCard(
        child: _Message(
          key: ValueKey('home.empty'),
          text: 'No expenses yet. Tap "Add expense" to log your first one.',
        ),
      );
    }
    return AppCard(
      child: Column(
        key: const ValueKey('home.recent'),
        children: [
          for (final (i, expense) in recent.indexed) ...[
            if (i > 0) const Divider(height: 1),
            ExpenseTile(
              key: ValueKey('expense.${expense.id}'),
              expense: expense,
              now: controller.now,
              onDelete: () => _delete(context, expense),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, Expense expense) async {
    final messenger = ScaffoldMessenger.of(context);
    await controller.delete(expense);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted ${expense.title}'),
          action: SnackBarAction(
            key: const ValueKey('home.undoDelete'),
            label: 'Undo',
            onPressed: () => controller.restore(expense),
          ),
        ),
      );
  }
}

class _Message extends StatelessWidget {
  const _Message({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
