import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here
  }

  Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }

  Future<void> close() async {
    await Hive.close();
  }
}
