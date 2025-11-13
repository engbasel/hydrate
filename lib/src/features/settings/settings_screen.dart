import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/src/features/settings/widgets/dark_mode_toggle.dart';
import 'package:hydrate/src/features/settings/widgets/goal_setting.dart';
import 'package:hydrate/src/features/settings/widgets/notification_preferences.dart';
import 'package:hydrate/src/features/settings/widgets/unit_selector.dart';
import 'package:hydrate/src/features/settings/widgets/weight_input.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          GoalSetting(),
          Divider(),
          UnitSelector(),
          Divider(),
          NotificationPreferences(),
          Divider(),
          WeightInput(),
          Divider(),
          DarkModeToggle(),
        ],
      ),
    );
  }
}
