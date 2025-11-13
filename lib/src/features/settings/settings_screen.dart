import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Goal Setting
          ListTile(
            title: const Text('Daily Goal'),
            subtitle: const Text('Set your daily water intake goal'),
            trailing: TextButton(
              onPressed: () {
                // TODO: Implement goal setting dialog
              },
              child: const Text('2000 ml'), // Placeholder
            ),
          ),
          const Divider(),
          // Unit Selector
          ListTile(
            title: const Text('Unit'),
            subtitle: const Text('Choose your preferred unit (ml/oz)'),
            trailing: DropdownButton<String>(
              value: 'ml', // Placeholder
              onChanged: (String? newValue) {
                // TODO: Implement unit selection
              },
              items: <String>['ml', 'oz'].map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          // Notification Preferences
          ListTile(
            title: const Text('Notification Intervals'),
            subtitle: const Text('Set times for water intake reminders'),
            trailing: TextButton(
              onPressed: () {
                // TODO: Implement notification interval setting dialog
              },
              child: const Text('Edit'),
            ),
          ),
          const Divider(),
          // Weight Input
          ListTile(
            title: const Text('Weight'),
            subtitle: const Text('Enter your weight for recommended intake'),
            trailing: TextButton(
              onPressed: () {
                // TODO: Implement weight input dialog
              },
              child: const Text('70 kg'), // Placeholder
            ),
          ),
          const Divider(),
          // Dark Mode Toggle
          ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark mode on/off'),
            trailing: Switch(
              value: false, // Placeholder
              onChanged: (bool value) {
                // TODO: Implement dark mode toggle
              },
            ),
          ),
        ],
      ),
    );
  }
}
