import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/history_provider.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';

class WeeklyChart extends ConsumerWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Overview',
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
              child: BarChart(mainBarData(historyState.history, colorScheme)),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
    ColorScheme colorScheme, {
    bool isTouched = false,
    double width = 24,
    List<int> showTooltips = const [],
  }) {
    final isToday = x == DateTime.now().weekday - 1;
    final barColor = isToday ? colorScheme.primary : colorScheme.secondary;
    
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isTouched ? colorScheme.primary.withOpacity(0.8) : barColor.withOpacity(0.8),
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              (isTouched ? colorScheme.primary : barColor).withOpacity(0.6),
              (isTouched ? colorScheme.primary : barColor).withOpacity(0.9),
            ],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(List<DailySummary> history, ColorScheme colorScheme) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return List.generate(7, (i) {
      final date = startOfWeek.add(Duration(days: i));
      final summary = history.where((element) =>
          element.date.day == date.day &&
          element.date.month == date.month &&
          element.date.year == date.year).firstOrNull;
      
      final intake = (summary?.totalIntakeMl ?? 0) / 1000.0;
      return makeGroupData(i, intake, colorScheme, isTouched: false);
    });
  }

  BarChartData mainBarData(List<DailySummary> history, ColorScheme colorScheme) {
    final groups = showingGroups(history, colorScheme);
    final maxY = groups.isEmpty ? 3.0 : groups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxY * 1.2).clamp(2.0, 6.0);

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => colorScheme.surfaceContainerHighest,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            final weekDay = weekDays[group.x.toInt()];
            
            return BarTooltipItem(
              '$weekDay\n${rod.toY.toStringAsFixed(1)}L',
              TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => getTitles(value, colorScheme),
            reservedSize: 32,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: chartMaxY / 4,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              return Text(
                '${value.toStringAsFixed(1)}L',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: groups,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: chartMaxY / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      maxY: chartMaxY,
    );
  }

  Widget getTitles(double value, ColorScheme colorScheme) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final index = value.toInt();
    
    if (index < 0 || index >= dayLabels.length) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dayDate = startOfWeek.add(Duration(days: index));
    final isToday = dayDate.day == now.day &&
        dayDate.month == now.month &&
        dayDate.year == now.year;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: isToday
          ? BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: Text(
        dayLabels[index],
        style: TextStyle(
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
