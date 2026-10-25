import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../logic/labels.dart';
import '../../logic/money.dart';
import '../../logic/spending.dart';
import '../theme/app_theme.dart';

/// Bar chart of spend per day. The highest day is highlighted.
///
/// The chart is drawn on a canvas, so screen readers get one label that
/// lists every day and amount instead.
class SpendBarChart extends StatelessWidget {
  const SpendBarChart({super.key, required this.days, this.height = 140});

  final List<DailyTotal> days;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final highest = days.fold(
      0,
      (max, d) => d.totalKobo > max ? d.totalKobo : max,
    );
    bool isHighlighted(DailyTotal d) => highest > 0 && d.totalKobo == highest;

    final description = days
        .map((d) => '${weekdayShort(d.day)} ${formatNaira(d.totalKobo)}')
        .join(', ');

    return Semantics(
      label: 'Spend per day: $description',
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: highest == 0 ? 1 : highest.toDouble(),
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final day = days[value.toInt()];
                      final style = isHighlighted(day)
                          ? AppTypography.smallStrong.copyWith(
                              color: theme.colorScheme.onSurface,
                            )
                          : AppTypography.small.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            );
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(weekdayShort(day.day), style: style),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (final (i, day) in days.indexed)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: day.totalKobo.toDouble(),
                        width: 20,
                        color: isHighlighted(day)
                            ? colors.chartBarHighlight
                            : colors.chartBar,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
