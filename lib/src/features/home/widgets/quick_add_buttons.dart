import 'package:flutter/material.dart';

class QuickAddButtons extends StatelessWidget {
  final Function(double) onAddWater;

  const QuickAddButtons({super.key, required this.onAddWater});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => onAddWater(250),
          child: const Text('250ml'),
        ),
        ElevatedButton(
          onPressed: () => onAddWater(500),
          child: const Text('500ml'),
        ),
        ElevatedButton(
          onPressed: () => onAddWater(1000),
          child: const Text('1000ml'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement custom add water dialog
            onAddWater(0); // Placeholder
          },
          child: const Text('Custom'),
        ),
      ],
    );
  }
}
