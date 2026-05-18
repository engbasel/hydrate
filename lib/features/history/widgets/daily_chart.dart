import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/history_provider.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';

class DailyChart extends ConsumerWidget {
  const DailyChart({super.key});

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
                Icon(Icons.timeline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Last 7 Days Trend',
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
    // Get last 7 days of data
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (index) => now.subtract(Duration(days: 6 - index)),
    );

    final chartSpots = <FlSpot>[];

    for (int i = 0; i < last7Days.length; i++) {
      final date = last7Days[i];
      final dayData = history
          .where(
            (summary) =>
                summary.date.day == date.day &&
                summary.date.month == date.month &&
                summary.date.year == date.year,
          )
          .firstOrNull;

      // Always add a spot — 0.0 for days with no data so the chart has no gaps
      final intake = dayData != null ? dayData.totalIntakeMl / 1000.0 : 0.0;
      chartSpots.add(FlSpot(i.toDouble(), intake));
    }

    final maxIntake = chartSpots.isEmpty
        ? 3.0
        : chartSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxIntake * 1.2).clamp(2.0, 6.0);
    final chartMinY = 0.0; // Ensure chart starts at 0

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: chartMaxY / 4,
        getDrawingHorizontalLine: (value) {
          // Don't show grid line at 0 to avoid clutter at bottom
          if (value == 0) return FlLine(color: Colors.transparent);
          return FlLine(
            color: colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                bottomTitleWidgets(value, last7Days, colorScheme),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: chartMaxY / 4,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(value, colorScheme),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: chartMinY,
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
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: colorScheme.primary,
                strokeWidth: 2,
                strokeColor: colorScheme.surface,
              );
            },
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

  Widget bottomTitleWidgets(
    double value,
    List<DateTime> last7Days,
    ColorScheme colorScheme,
  ) {
    if (value < 0 || value >= last7Days.length) {
      return const SizedBox.shrink();
    }

    final date = last7Days[value.toInt()];
    final isToday =
        date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[(date.weekday - 1) % 7];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: isToday
          ? BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: Text(
        dayName,
        style: TextStyle(
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, ColorScheme colorScheme) {
    if (value == 0) return const SizedBox.shrink();

    return Text(
      '${value.toStringAsFixed(1)}L',
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 11,
        color: colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.left,
    );
  }
}
