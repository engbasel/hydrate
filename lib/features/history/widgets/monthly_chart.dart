import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/history_provider.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';

class MonthlyChart extends ConsumerWidget {
  const MonthlyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Monthly Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(mainData(historyState.history, colorScheme)),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData(List<DailySummary> history, ColorScheme colorScheme) {
    final now = DateTime.now();
    final daysInMonth = now.day; // Only up to today

    // Filter to current month and index by day
    final thisMonthData = <int, double>{};
    for (final entry in history) {
      if (entry.date.year == now.year && entry.date.month == now.month) {
        thisMonthData[entry.date.day] = entry.totalIntakeMl / 1000.0;
      }
    }

    // Build one spot per day from day 1 to today (0 for missing days)
    final chartSpots = <FlSpot>[
      for (int day = 1; day <= daysInMonth; day++)
        FlSpot(day.toDouble(), thisMonthData[day] ?? 0.0),
    ];

    final maxIntake = chartSpots.isEmpty
        ? 3.0
        : chartSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxIntake * 1.2).clamp(2.0, 6.0);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: chartMaxY / 4,
        getDrawingHorizontalLine: (value) {
          if (value == 0) return FlLine(color: Colors.transparent);
          return FlLine(
            color: colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: daysInMonth <= 15 ? 2 : 5,
            getTitlesWidget: (value, meta) =>
                _bottomTitle(value, colorScheme),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: chartMaxY / 4,
            getTitlesWidget: (value, meta) =>
                _leftTitle(value, colorScheme),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: daysInMonth.toDouble(),
      minY: 0,
      maxY: chartMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: chartSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: daysInMonth <= 10,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: colorScheme.primary,
                  strokeWidth: 1.5,
                  strokeColor: colorScheme.surface,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withValues(alpha: 0.3),
                colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitle(double value, ColorScheme colorScheme) {
    final day = value.toInt();
    final now = DateTime.now();
    final isToday = day == now.day;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 11,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _leftTitle(double value, ColorScheme colorScheme) {
    if (value == 0) return const SizedBox.shrink();
    return Text(
      '${value.toStringAsFixed(1)}L',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.left,
    );
  }
}
