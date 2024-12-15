import 'package:hive/hive.dart';

part 'localization.g.dart';

@HiveType(typeId: 101) // Assign a unique typeId for each class
class LocalizationWrapper {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String locale;

  @HiveField(2)
  List<Localization> localizations = [];
}

@HiveType(typeId: 1)
class Localization {
  @HiveField(0)
  late String code;

  @HiveField(1)
  late String message;

  @HiveField(2)
  late String module;

  @HiveField(3)
  late String locale;
}
