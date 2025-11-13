import 'package:flutter/material.dart';

class WaterProgressIndicator extends StatelessWidget {
  final double currentIntake;
  final double dailyGoal;

  const WaterProgressIndicator({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Progress: ${currentIntake / dailyGoal * 100}%'));
  }
}
