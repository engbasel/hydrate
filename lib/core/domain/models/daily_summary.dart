import 'package:hive/hive.dart';

part 'daily_summary.g.dart';

@HiveType(typeId: 2)
class DailySummary {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  double totalIntakeMl;

  DailySummary({required this.date, required this.totalIntakeMl});
}
