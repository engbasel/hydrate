import 'package:hive/hive.dart';
import 'dart:io';

Future<void> initHive() async {
  final temp = await Directory.systemTemp.createTemp();
  Hive.init(temp.path);
}
