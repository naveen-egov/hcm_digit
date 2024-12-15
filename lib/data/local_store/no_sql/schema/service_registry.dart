import 'package:hive/hive.dart';

part 'service_registry.g.dart';

@HiveType(typeId: 104) // Unique typeId for the `ServiceRegistry` class
class ServiceRegistry {


  @HiveField(1)
  late String service;

  @HiveField(2)
  List<Actions> actions = [];
}

@HiveType(typeId: 108) // Unique typeId for the `Actions` class
class Actions {
  @HiveField(0)
  late String path;

  @HiveField(1)
  late String entityName;

  @HiveField(2)
  late String action;
}
