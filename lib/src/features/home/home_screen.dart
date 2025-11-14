import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/water_intake_provider.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';
import 'package:hydrate/src/features/home/widgets/current_intake_display.dart';
import 'package:hydrate/src/features/home/widgets/quick_add_buttons.dart';
import 'package:hydrate/src/features/home/widgets/water_progress_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final waterIntakeState = ref.watch(waterIntakeNotifierProvider);
    final waterNotifier = ref.read(waterIntakeNotifierProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hydrate',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            WaterProgressIndicator(
              currentIntake: waterNotifier.getCurrentIntakeInDisplayUnit(),
              dailyGoal: waterNotifier.getDailyGoalInDisplayUnit(),
            ),
            const SizedBox(height: 32),
            CurrentIntakeDisplay(
              currentIntake: waterNotifier.getCurrentIntakeInDisplayUnit(),
              dailyGoal: waterNotifier.getDailyGoalInDisplayUnit(),
              unit: waterIntakeState.unit,
            ),
            const SizedBox(height: 32),
            QuickAddButtons(
              unit: waterIntakeState.unit,
              onAddWater: (amount) {
                waterNotifier.addWater(amount);
                _showSuccessSnackBar(context, amount, waterIntakeState.unit);
              },
            ),
            const SizedBox(height: 32),
            _buildTodayStats(context, waterNotifier),
            const SizedBox(height: 24),
            _buildResetButton(context, waterNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats(BuildContext context, WaterIntakeNotifier notifier) {
    final currentIntake = notifier.getCurrentIntakeInDisplayUnit();
    final dailyGoal = notifier.getDailyGoalInDisplayUnit();
    final progress = (currentIntake / dailyGoal * 100).clamp(0, 100);
    final remaining = (dailyGoal - currentIntake).clamp(0, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Progress',
                  '${progress.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  progress >= 100 ? _getProgressColor(1.0) : Theme.of(context).colorScheme.primary,
                ),
                _buildStatItem(
                  context,
                  'Remaining',
                  '${remaining.toStringAsFixed(0)} ${ref.watch(waterIntakeNotifierProvider).unit}',
                  Icons.local_drink,
                  Theme.of(context).brightness == Brightness.dark 
                      ? Colors.orange.shade300 
                      : Colors.orange.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, 
      IconData icon, Color color) {
    // Adjust colors for dark mode
    final adjustedColor = Theme.of(context).brightness == Brightness.dark
        ? color.withOpacity(0.9)
        : color;
        
    return Column(
      children: [
        Icon(icon, color: adjustedColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: adjustedColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context, WaterIntakeNotifier notifier) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => _showResetDialog(context, notifier),
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: const Text('Reset Today\'s Progress'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WaterIntakeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset today\'s water intake progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.resetDailyIntake();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Today\'s progress has been reset 🔄'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (progress >= 1.0) {
      return isDark ? Colors.green.shade400 : Colors.green.shade600;
    }
    if (progress >= 0.75) {
      return isDark ? Colors.lightGreen.shade400 : Colors.lightGreen.shade600;
    }
    if (progress >= 0.5) {
      return Theme.of(context).colorScheme.primary;
    }
    if (progress >= 0.25) {
      return isDark ? Colors.orange.shade400 : Colors.orange.shade600;
    }
    return isDark ? Colors.red.shade400 : Colors.red.shade600;
  }

  void _showSuccessSnackBar(BuildContext context, double amount, String unit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+${amount.toStringAsFixed(0)} $unit added! 💧'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
