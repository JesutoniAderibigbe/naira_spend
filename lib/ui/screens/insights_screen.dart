import 'package:flutter/material.dart';

import '../../logic/controllers/insights_controller.dart';
import '../../logic/insights.dart';
import '../../logic/labels.dart';
import '../../logic/money.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/message_box.dart';
import '../widgets/progress_bar.dart';

/// Insights: total and per-category share for 7 days, 30 days or this month,
/// plus the biggest single expense.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.controller});

  final InsightsController controller;

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
            final summary = controller.summary;
            return ListView(
              key: const ValueKey('insights.list'),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                Text('Insights', style: AppTypography.h1),
                const SizedBox(height: 16),
                _PeriodPicker(
                  selected: controller.period,
                  onSelected: (p) => controller.period = p,
                ),
                const SizedBox(height: 16),
                if (controller.error != null)
                  const _Message(
                    'Could not load your expenses. Check your connection.',
                  )
                else ...[
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.period.heading,
                          style: AppTypography.body.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatNaira(summary.totalKobo),
                            key: const ValueKey('insights.total'),
                            style: AppTypography.amountLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary.expenseCount == 1
                              ? 'Across 1 expense'
                              : 'Across ${summary.expenseCount} expenses',
                          key: const ValueKey('insights.count'),
                          style: AppTypography.body.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ByCategory(summary: summary),
                  if (summary.biggest case final biggest?) ...[
                    const SizedBox(height: 12),
                    MessageBox(
                      key: const ValueKey('insights.biggest'),
                      colors: Theme.of(context).extension<AppColors>()!.tip,
                      icon: Icons.lightbulb_outline,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Your biggest single expense was ',
                            ),
                            TextSpan(
                              text:
                                  '${biggest.title}, '
                                  '${formatNaira(biggest.amountKobo)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontVariations: [FontVariation('wght', 700)],
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' ${dayPhrase(biggest.date, controller.now)}.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "7 days | 30 days | This month" segmented control.
class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.selected, required this.onSelected});

  final InsightsPeriod selected;
  final ValueChanged<InsightsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final period in InsightsPeriod.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: period == selected,
                child: Material(
                  color: period == selected
                      ? scheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: ValueKey('insights.period.${period.name}'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelected(period),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        period.label,
                        textAlign: TextAlign.center,
                        style: period == selected
                            ? AppTypography.strong
                            : AppTypography.body.copyWith(
                                fontSize: 15,
                                color: scheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ByCategory extends StatelessWidget {
  const _ByCategory({required this.summary});

  final InsightsSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final shares = summary.shares;
    final biggest = shares.isEmpty ? 0 : shares.first.totalKobo;
    return AppCard(
      key: const ValueKey('insights.byCategory'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By category', style: AppTypography.title),
          const SizedBox(height: 16),
          if (shares.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No spending in this period.',
                key: const ValueKey('insights.empty'),
                style: AppTypography.small.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final share in shares) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    share.category.label,
                    style: AppTypography.strong,
                  ),
                ),
                Text(
                  '${formatNaira(share.totalKobo)} · ${share.percent}%',
                  key: ValueKey('insights.share.${share.category.name}'),
                  style: AppTypography.small.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(
              value: share.totalKobo / biggest,
              color: colors.chartBarHighlight,
              trackColor: colors.track,
              height: 10,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

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
