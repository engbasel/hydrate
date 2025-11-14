import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';

class GoalSetting extends ConsumerWidget {
  const GoalSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);
    
    // Convert goal to display unit
    final displayGoal = userPreferences.unit == 'oz' 
        ? userPreferences.dailyGoalMl / 29.5735  // Convert ml to fl oz
        : userPreferences.dailyGoalMl;

    return ListTile(
      title: const Text('Daily Goal'),
      subtitle: const Text('Set your daily water intake goal'),
      trailing: TextButton(
        onPressed: () {
          _showGoalInputDialog(context, ref, userPreferences.dailyGoalMl, userPreferences.unit);
        },
        child: Text('${displayGoal.toStringAsFixed(userPreferences.unit == 'oz' ? 1 : 0)} ${userPreferences.unit}'),
      ),
    );
  }

  void _showGoalInputDialog(
    BuildContext context,
    WidgetRef ref,
    double currentGoalMl,
    String unit,
  ) {
    // Convert current goal to display unit for the input field
    final displayGoal = unit == 'oz' 
        ? currentGoalMl / 29.5735  // Convert ml to fl oz
        : currentGoalMl;
    
    final TextEditingController controller = TextEditingController(
      text: unit == 'oz' 
          ? displayGoal.toStringAsFixed(1)
          : displayGoal.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Goal'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Goal ($unit)',
              hintText: unit == 'oz' ? 'e.g., 67.6' : 'e.g., 2000',
            ),
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
                final inputValue = double.tryParse(controller.text);
                if (inputValue != null && inputValue > 0) {
                  // Convert input to ml if needed
                  final goalInMl = unit == 'oz' 
                      ? inputValue * 29.5735  // Convert fl oz to ml
                      : inputValue;
                  
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateGoal(goalInMl);
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
