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
  final int notificationIntervalMinutes; // e.g., 120 for every 2 hours, 0 for disabled

  @HiveField(3)
  final bool darkModeEnabled;

  @HiveField(4)
  final double weightKg; // For recommended intake calculation

  const UserPreferences({
    required this.dailyGoalMl,
    required this.unit,
    required this.notificationIntervalMinutes,
    required this.darkModeEnabled,
    required this.weightKg,
  });

  UserPreferences copyWith({
    double? dailyGoalMl,
    String? unit,
    int? notificationIntervalMinutes,
    bool? darkModeEnabled,
    double? weightKg,
  }) {
    return UserPreferences(
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      unit: unit ?? this.unit,
      notificationIntervalMinutes:
          notificationIntervalMinutes ?? this.notificationIntervalMinutes,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  List<Object?> get props => [
    dailyGoalMl,
    unit,
    notificationIntervalMinutes,
    darkModeEnabled,
    weightKg,
  ];
}
