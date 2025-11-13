import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';

class NotificationPreferences extends ConsumerWidget {
  const NotificationPreferences({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return ListTile(
      title: const Text('Notification Intervals'),
      subtitle: const Text('Set times for water intake reminders'),
      trailing: TextButton(
        onPressed: () {
          _showNotificationIntervalDialog(
            context,
            ref,
            userPreferences.notificationIntervals,
          );
        },
        child: const Text('Edit'),
      ),
    );
  }

  void _showNotificationIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    List<int> currentIntervals,
  ) {
    List<int> selectedIntervals = List.from(currentIntervals);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Notification Intervals (24h format)'),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(24, (index) {
                return CheckboxListTile(
                  title: Text('$index:00'),
                  value: selectedIntervals.contains(index),
                  onChanged: (bool? value) {
                    if (value != null) {
                      if (value) {
                        selectedIntervals.add(index);
                      } else {
                        selectedIntervals.remove(index);
                      }
                      selectedIntervals.sort();
                      // No direct state update here, will be updated on save
                    }
                  },
                );
              }),
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
                ref
                    .read(userPreferencesProvider.notifier)
                    .updateNotificationIntervals(selectedIntervals);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
