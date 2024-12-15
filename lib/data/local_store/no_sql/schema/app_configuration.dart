import 'package:hive/hive.dart';

part 'app_configuration.g.dart';

@HiveType(typeId: 0)
class AppConfiguration {
  @HiveField(0)
  late String? networkDetection;

  @HiveField(1)
  late String? persistenceMode;

  @HiveField(2)
  late String? syncMethod;

  @HiveField(3)
  late double? maxRadius;

  @HiveField(4)
  late String? syncTrigger;

  @HiveField(5)
  List<Languages> languages = [];

  @HiveField(6)
  BackendInterface? backendInterface;

  @HiveField(7)
  List<GenderOptions> genderOptions = [];

  @HiveField(8)
  String? tenantId;

  // Add other fields similarly with unique field IDs
}

@HiveType(typeId: 191)
class Languages {
  @HiveField(0)
  late String label;

  @HiveField(1)
  late String value;
}

@HiveType(typeId: 192)
class BackendInterface {
  @HiveField(0)
  List<Interfaces> interfaces = [];
}

@HiveType(typeId: 193)
class GenderOptions {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String code;
}

@HiveType(typeId: 4)
class Interfaces {
  @HiveField(0)
  late String type;

  @HiveField(1)
  late String name;


}


