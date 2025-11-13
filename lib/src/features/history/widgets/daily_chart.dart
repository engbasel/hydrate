import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/history_provider.dart';
import 'package:hydrate/src/domain/models/daily_summary.dart';

class DailyChart extends ConsumerWidget {
  const DailyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(mainData(historyState.history)),
      ),
    );
  }

  LineChartData mainData(List<DailySummary> history) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
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
            getTitlesWidget: (value, meta) => bottomTitleWidgets(value),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) => leftTitleWidgets(value),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: history
              .map((e) => FlSpot(e.date.day.toDouble(), e.totalIntakeMl / 1000))
              .toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(
                begin: Colors.cyan,
                end: Colors.blue,
              ).evaluate(const AlwaysStoppedAnimation(1.0))!,
              ColorTween(
                begin: Colors.cyan,
                end: Colors.blue,
              ).evaluate(const AlwaysStoppedAnimation(1.0))!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: Colors.cyan, end: Colors.blue)
                    .evaluate(const AlwaysStoppedAnimation(1.0))!
                    .withAlpha((255 * 0.3).toInt()),
                ColorTween(begin: Colors.cyan, end: Colors.blue)
                    .evaluate(const AlwaysStoppedAnimation(1.0))!
                    .withAlpha((255 * 0.0).toInt()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return text;
  }

  Widget leftTitleWidgets(double value) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1L';
        break;
      case 3:
        text = '3L';
        break;
      case 5:
        text = '5L';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
