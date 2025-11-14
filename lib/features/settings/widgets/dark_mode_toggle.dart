import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';

class DarkModeToggle extends ConsumerWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return ListTile(
      title: const Text('Dark Mode'),
      subtitle: const Text('Toggle dark mode on/off'),
      trailing: Switch(
        value: userPreferences.darkModeEnabled,
        onChanged: (bool value) {
          ref.read(userPreferencesProvider.notifier).toggleDarkMode(value);
        },
      ),
    );
  }
}
