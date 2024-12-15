import 'package:hive/hive.dart';

part 'row_versions.g.dart';

@HiveType(typeId: 103) // Unique typeId for the class
class RowVersionList {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String module;

  @HiveField(2)
  late String version;
}
