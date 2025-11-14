import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/app/providers/user_preferences_provider.dart';
import 'package:hydrate/src/app/providers/notification_provider.dart';

class NotificationPreferences extends ConsumerWidget {
  const NotificationPreferences({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);
    
    String intervalText = _getIntervalText(userPreferences.notificationIntervalMinutes);

    return ListTile(
      title: const Text('Water Reminders'),
      subtitle: Text('Remind me $intervalText'),
      trailing: TextButton(
        onPressed: () {
          _showNotificationIntervalDialog(
            context,
            ref,
            userPreferences.notificationIntervalMinutes,
          );
        },
        child: const Text('Edit'),
      ),
    );
  }

  String _getIntervalText(int minutes) {
    if (minutes == 0) {
      return 'Never';
    } else if (minutes < 60) {
      return 'Every $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return 'Every $hours hour${hours == 1 ? '' : 's'}';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return 'Every ${hours}h ${remainingMinutes}m';
    }
  }

  void _showNotificationIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    int currentIntervalMinutes,
  ) {
    int selectedIntervalMinutes = currentIntervalMinutes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Water Reminder Interval'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How often should I remind you to drink water?'),
                  const SizedBox(height: 20),
                  // Predefined options
                  RadioListTile<int>(
                    title: const Text('Never'),
                    value: 0,
                    groupValue: selectedIntervalMinutes,
                    onChanged: (value) {
                      setState(() {
                        selectedIntervalMinutes = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Every 30 minutes'),
                    value: 30,
                    groupValue: selectedIntervalMinutes,
                    onChanged: (value) {
                      setState(() {
                        selectedIntervalMinutes = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Every 1 hour'),
                    value: 60,
                    groupValue: selectedIntervalMinutes,
                    onChanged: (value) {
                      setState(() {
                        selectedIntervalMinutes = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Every 2 hours'),
                    value: 120,
                    groupValue: selectedIntervalMinutes,
                    onChanged: (value) {
                      setState(() {
                        selectedIntervalMinutes = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Every 3 hours'),
                    value: 180,
                    groupValue: selectedIntervalMinutes,
                    onChanged: (value) {
                      setState(() {
                        selectedIntervalMinutes = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('Every 4 hours'),
                    value: 240,
                    groupValue: selectedIntervalMinutes,
                    onChanged: (value) {
                      setState(() {
                        selectedIntervalMinutes = value!;
                      });
                    },
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
                TextButton(
                  onPressed: () async {
                    // Request notification permissions if enabling notifications
                    if (selectedIntervalMinutes > 0) {
                      final notificationService = ref.read(notificationServiceProvider);
                      final hasPermission = await notificationService.requestPermissions();
                      
                      if (!hasPermission) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification permission denied. Please enable notifications in app settings.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                        return;
                      }
                    }
                    
                    ref
                        .read(userPreferencesProvider.notifier)
                        .updateNotificationInterval(selectedIntervalMinutes);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            selectedIntervalMinutes == 0 
                                ? 'Water reminders disabled' 
                                : 'Water reminders set to ${_getIntervalText(selectedIntervalMinutes).toLowerCase()}'
                          ),
                          backgroundColor: Colors.green,
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
      },
    );
  }
}
