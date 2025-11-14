import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/history_provider.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';
import 'package:hydrate/features/history/widgets/daily_chart.dart';
import 'package:hydrate/features/history/widgets/monthly_chart.dart';
import 'package:hydrate/features/history/widgets/weekly_chart.dart';
import 'package:hydrate/core/domain/models/daily_summary.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      ref
          .read(historyProvider.notifier)
          .setDateRange(DateRange.values[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final userPrefs = ref.watch(userPreferencesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards Section
            Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatisticsCards(
              historyState.history,
              userPrefs.dailyGoalMl,
              colorScheme,
            ),
            const SizedBox(height: 24),

            // Insights Section
            _buildInsightsSection(
              historyState.history,
              userPrefs.dailyGoalMl,
              colorScheme,
            ),

            // Charts Section
            const SizedBox(height: 8),
            Text(
              'Detailed Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildModernTabBar(colorScheme),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: const [DailyChart(), WeeklyChart(), MonthlyChart()],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    List<DailySummary> history,
    double goalMl,
    ColorScheme colorScheme,
  ) {
    final today = DateTime.now();
    final todayIntake = history
        .where(
          (summary) =>
              summary.date.day == today.day &&
              summary.date.month == today.month &&
              summary.date.year == today.year,
        )
        .fold(0.0, (sum, summary) => sum + summary.totalIntakeMl);

    final weekIntake = history
        .where((summary) {
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          return summary.date.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          );
        })
        .fold(0.0, (sum, summary) => sum + summary.totalIntakeMl);

    final avgDailyIntake = history.isEmpty
        ? 0.0
        : history.fold(0.0, (sum, summary) => sum + summary.totalIntakeMl) /
              history.length;

    final streak = _calculateStreak(history, goalMl);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.water_drop,
                title: 'Today',
                value: '${(todayIntake / 1000).toStringAsFixed(1)}L',
                subtitle: '${((todayIntake / goalMl) * 100).round()}% of goal',
                color: colorScheme.primary,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Average',
                value: '${(avgDailyIntake / 1000).toStringAsFixed(1)}L',
                subtitle: 'Daily intake',
                color: colorScheme.secondary,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_view_week,
                title: 'This Week',
                value: '${(weekIntake / 1000).toStringAsFixed(1)}L',
                subtitle: 'Total intake',
                color: colorScheme.tertiary,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'Streak',
                value: '${streak}',
                subtitle: streak == 1 ? 'day' : 'days',
                color: Colors.orange,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    List<DailySummary> history,
    double goalMl,
    ColorScheme colorScheme,
  ) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final insights = _generateInsights(history, goalMl);
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withOpacity(0.3),
                colorScheme.secondaryContainer.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: insights
                .map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildModernTabBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: Colors.transparent,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '7 Days',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Tab(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '4 Weeks',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Tab(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '3 Months',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<DailySummary> history, double goalMl) {
    if (history.isEmpty) return 0;

    final sortedHistory = List<DailySummary>.from(history)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < sortedHistory.length; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final summary = sortedHistory
          .where(
            (s) =>
                s.date.day == checkDate.day &&
                s.date.month == checkDate.month &&
                s.date.year == checkDate.year,
          )
          .firstOrNull;

      if (summary != null && summary.totalIntakeMl >= goalMl) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  List<String> _generateInsights(List<DailySummary> history, double goalMl) {
    final insights = <String>[];

    if (history.length < 3) return insights;

    // Calculate average
    final avgIntake =
        history.fold(0.0, (sum, s) => sum + s.totalIntakeMl) / history.length;
    final goalPercentage = (avgIntake / goalMl * 100).round();

    if (goalPercentage >= 100) {
      insights.add(
        'Great job! You\'ve been consistently meeting your hydration goals.',
      );
    } else if (goalPercentage >= 80) {
      insights.add(
        'You\'re doing well! You\'re at $goalPercentage% of your daily goal on average.',
      );
    } else {
      insights.add(
        'Try to increase your water intake. You\'re at $goalPercentage% of your goal.',
      );
    }

    // Weekly pattern analysis
    final weekdayIntake = <int, List<double>>{};
    for (final summary in history) {
      final weekday = summary.date.weekday;
      weekdayIntake[weekday] ??= [];
      weekdayIntake[weekday]!.add(summary.totalIntakeMl);
    }

    if (weekdayIntake.isNotEmpty) {
      final weekdayAvgs = weekdayIntake.map(
        (day, intakes) =>
            MapEntry(day, intakes.fold(0.0, (a, b) => a + b) / intakes.length),
      );

      final bestDay = weekdayAvgs.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final dayNames = [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      insights.add(
        'Your best hydration day is usually ${dayNames[bestDay.key]}.',
      );
    }

    return insights.take(3).toList();
  }
}
