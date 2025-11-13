import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 1)
class UserPreferences {
  @HiveField(0)
  double dailyGoalMl;

  @HiveField(1)
  String unit; // "ml" or "oz"

  @HiveField(2)
  List<int> notificationIntervals; // e.g., [9, 12, 15, 18] for 9 AM, 12 PM, etc.

  @HiveField(3)
  bool darkModeEnabled;

  @HiveField(4)
  double weightKg; // For recommended intake calculation

  UserPreferences({
    required this.dailyGoalMl,
    required this.unit,
    required this.notificationIntervals,
    required this.darkModeEnabled,
    required this.weightKg,
  });
}
