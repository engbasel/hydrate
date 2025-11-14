import 'package:flutter/material.dart';

class CurrentIntakeDisplay extends StatelessWidget {
  final double currentIntake;
  final double dailyGoal;
  final String unit;

  const CurrentIntakeDisplay({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIntakeColumn(
              context,
              'Current Intake',
              '${currentIntake.toStringAsFixed(0)}',
              unit,
              Icons.local_drink,
              Theme.of(context).primaryColor,
            ),
            Container(
              width: 1,
              height: 60,
              color: Theme.of(context).dividerColor,
            ),
            _buildIntakeColumn(
              context,
              'Daily Goal',
              '${dailyGoal.toStringAsFixed(0)}',
              unit,
              Icons.flag,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntakeColumn(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon, 
          color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).colorScheme.primary
              : color, 
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Theme.of(context).colorScheme.onSurface
                : color,
          ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Theme.of(context).colorScheme.primary
                : color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
