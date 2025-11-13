import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';

class GoalSetting extends ConsumerWidget {
  const GoalSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return ListTile(
      title: const Text('Daily Goal'),
      subtitle: const Text('Set your daily water intake goal'),
      trailing: TextButton(
        onPressed: () {
          _showGoalInputDialog(context, ref, userPreferences.dailyGoalMl);
        },
        child: Text('${userPreferences.dailyGoalMl.toInt()} ml'),
      ),
    );
  }

  void _showGoalInputDialog(
    BuildContext context,
    WidgetRef ref,
    double currentGoal,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentGoal.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Goal (ml)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newGoal = double.tryParse(controller.text);
                if (newGoal != null && newGoal > 0) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateGoal(newGoal);
                  Navigator.of(context).pop();
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid number for your goal.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
