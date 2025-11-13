import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/water_intake_provider.dart';
import 'package:hydrate/src/features/home/widgets/current_intake_display.dart';
import 'package:hydrate/src/features/home/widgets/quick_add_buttons.dart';
import 'package:hydrate/src/features/home/widgets/water_progress_indicator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterIntakeState = ref.watch(waterIntakeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hydrate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WaterProgressIndicator(
              currentIntake: waterIntakeState.currentIntake,
              dailyGoal: waterIntakeState.dailyGoal,
            ),
            const SizedBox(height: 20),
            CurrentIntakeDisplay(
              currentIntake: waterIntakeState.currentIntake,
              dailyGoal: waterIntakeState.dailyGoal,
              unit: waterIntakeState.unit,
            ),
            const SizedBox(height: 20),
            QuickAddButtons(
              onAddWater: (amount) {
                ref.read(waterIntakeNotifierProvider.notifier).addWater(amount);
              },
            ),
          ],
        ),
      ),
    );
  }
}
