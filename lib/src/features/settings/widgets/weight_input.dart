import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';
import 'package:hydrate/src/domain/use_cases/calculate_recommended_intake.dart';

class WeightInput extends ConsumerWidget {
  const WeightInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final recommendedIntake = CalculateRecommendedIntake()(userPreferences.weightKg);
    final isUsingRecommended = ref.watch(userPreferencesProvider.notifier).isUsingRecommendedGoal();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${userPreferences.weightKg.toInt()} kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showWeightInputDialog(context, ref, userPreferences.weightKg);
                },
                child: Text(
                  'Edit',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUsingRecommended 
                  ? colorScheme.primaryContainer.withOpacity(0.3)
                  : colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isUsingRecommended ? Icons.check_circle : Icons.info_outline,
                  color: isUsingRecommended ? colorScheme.primary : colorScheme.secondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUsingRecommended 
                        ? 'Using recommended intake: ${(recommendedIntake / 1000).toStringAsFixed(1)}L'
                        : 'Recommended for your weight: ${(recommendedIntake / 1000).toStringAsFixed(1)}L',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUsingRecommended ? colorScheme.primary : colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final enteredWeight = double.tryParse(controller.text) ?? currentWeight;
            final recommendedIntake = CalculateRecommendedIntake()(enteredWeight);
            
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.monitor_weight, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Update Weight'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.monitor_weight),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recommended Daily Intake',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(recommendedIntake / 1000).toStringAsFixed(1)}L (${recommendedIntake.toInt()}ml)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Based on 35ml per kg body weight',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final newWeight = double.tryParse(controller.text);
                    if (newWeight != null && newWeight > 0 && newWeight <= 300) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateWeight(newWeight);
                      Navigator.of(context).pop();
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Weight updated! Daily goal set to ${(recommendedIntake / 1000).toStringAsFixed(1)}L',
                          ),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid weight between 1-300 kg.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save & Apply Goal'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
