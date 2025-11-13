import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 1)
class UserPreferences extends Equatable {
  @HiveField(0)
  final double dailyGoalMl;

  @HiveField(1)
  final String unit; // "ml" or "oz"

  @HiveField(2)
  final List<int> notificationIntervals; // e.g., [9, 12, 15, 18] for 9 AM, 12 PM, etc.

  @HiveField(3)
  final bool darkModeEnabled;

  @HiveField(4)
  final double weightKg; // For recommended intake calculation

  const UserPreferences({
    required this.dailyGoalMl,
    required this.unit,
    required this.notificationIntervals,
    required this.darkModeEnabled,
    required this.weightKg,
  });

  UserPreferences copyWith({
    double? dailyGoalMl,
    String? unit,
    List<int>? notificationIntervals,
    bool? darkModeEnabled,
    double? weightKg,
  }) {
    return UserPreferences(
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      unit: unit ?? this.unit,
      notificationIntervals:
          notificationIntervals ?? this.notificationIntervals,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  List<Object?> get props => [
    dailyGoalMl,
    unit,
    notificationIntervals,
    darkModeEnabled,
    weightKg,
  ];
}
