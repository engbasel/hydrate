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
    return Column(
      children: [
        Text('Current Intake: ${currentIntake.toStringAsFixed(0)} $unit'),
        Text('Daily Goal: ${dailyGoal.toStringAsFixed(0)} $unit'),
      ],
    );
  }
}
