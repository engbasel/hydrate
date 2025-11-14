import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';

class UnitSelector extends ConsumerWidget {
  const UnitSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return ListTile(
      title: const Text('Unit'),
      subtitle: const Text('Choose your preferred unit (ml/oz)'),
      trailing: DropdownButton<String>(
        value: userPreferences.unit,
        onChanged: (String? newValue) {
          if (newValue != null) {
            ref.read(userPreferencesProvider.notifier).updateUnit(newValue);
          }
        },
        items: <String>['ml', 'oz'].map<DropdownMenuItem<String>>((
          String value,
        ) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
      ),
    );
  }
}
