import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/features/settings/widgets/dark_mode_toggle.dart';
import 'package:hydrate/features/settings/widgets/goal_setting.dart';
import 'package:hydrate/features/settings/widgets/notification_preferences.dart';
import 'package:hydrate/features/settings/widgets/unit_selector.dart';
import 'package:hydrate/features/settings/widgets/weight_input.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(context, 'Hydration Goals', [
            const GoalSetting(),
            const UnitSelector(),
          ]),
          const SizedBox(height: 16),
          _buildSettingsSection(context, 'Personal Settings', [
            const WeightInput(),
          ]),
          const SizedBox(height: 16),
          _buildSettingsSection(context, 'Notifications', [
            const NotificationPreferences(),
          ]),
          const SizedBox(height: 16),
          _buildSettingsSection(context, 'Appearance', [
            const DarkModeToggle(),
          ]),
          const SizedBox(height: 32),
          _buildAppInfo(context),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }


  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.water_drop,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Hydrate',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('Version 0.1.0', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              'Stay healthy, stay hydrated! 💧',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
