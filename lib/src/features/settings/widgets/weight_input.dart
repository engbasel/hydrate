import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';

class WeightInput extends ConsumerWidget {
  const WeightInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return ListTile(
      title: const Text('Weight'),
      subtitle: const Text('Enter your weight for recommended intake'),
      trailing: TextButton(
        onPressed: () {
          _showWeightInputDialog(context, ref, userPreferences.weightKg);
        },
        child: Text('${userPreferences.weightKg.toInt()} kg'),
      ),
    );
  }

  void _showWeightInputDialog(
    BuildContext context,
    WidgetRef ref,
    double currentWeight,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentWeight.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Weight'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
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
                final newWeight = double.tryParse(controller.text);
                if (newWeight != null && newWeight > 0) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateWeight(newWeight);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid number for your weight.',
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
