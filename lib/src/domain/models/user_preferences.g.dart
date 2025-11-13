// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 1;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      dailyGoalMl: fields[0] as double,
      unit: fields[1] as String,
      notificationIntervals: (fields[2] as List).cast<int>(),
      darkModeEnabled: fields[3] as bool,
      weightKg: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dailyGoalMl)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.notificationIntervals)
      ..writeByte(3)
      ..write(obj.darkModeEnabled)
      ..writeByte(4)
      ..write(obj.weightKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
