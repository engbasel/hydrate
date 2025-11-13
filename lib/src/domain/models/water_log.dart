import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 0)
class WaterLog {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final double amountMl;

  WaterLog({required this.timestamp, required this.amountMl});
}
