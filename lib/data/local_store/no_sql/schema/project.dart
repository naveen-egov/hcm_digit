import 'package:hive/hive.dart';

part 'project.g.dart'; // Required for Hive code generation

@HiveType(typeId: 200)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? projectTypeId;

  @HiveField(2)
  final String? projectNumber;

  @HiveField(3)
  final String? subProjectTypeId;

  @HiveField(4)
  final bool? isTaskEnabled;

  @HiveField(5)
  final String? parent;

  @HiveField(6)
  final String name;

  @HiveField(7)
  final String? department;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? referenceId;

  @HiveField(10)
  final String? projectHierarchy;

  @HiveField(11)
  final bool? nonRecoverableError;

  @HiveField(12)
  final String? tenantId;

  @HiveField(13)
  final int? rowVersion;

  @HiveField(14)
  final DateTime? startDateTime;

  @HiveField(15)
  final DateTime? endDateTime;

  @HiveField(16)
  final ProjectAdditionalFields? additionalFields;

  @HiveField(17)
  final ProjectAdditionalDetails? additionalDetails;

  ProjectModel({
    required this.id,
    this.projectTypeId,
    this.projectNumber,
    this.subProjectTypeId,
    this.isTaskEnabled,
    this.parent,
    required this.name,
    this.department,
    this.description,
    this.referenceId,
    this.projectHierarchy,
    this.nonRecoverableError,
    this.tenantId,
    this.rowVersion,
    this.startDateTime,
    this.endDateTime,
    this.additionalFields,
    this.additionalDetails,
  });
}

@HiveType(typeId: 201) // ProjectAdditionalFields with a unique typeId
class ProjectAdditionalFields extends HiveObject {
  @HiveField(0)
  final String schema;

  @HiveField(1)
  final String version;

  @HiveField(2)
  final Map<String, dynamic>? fields;

  ProjectAdditionalFields({
    required this.schema,
    required this.version,
    this.fields,
  });
}

@HiveType(typeId: 203) // ProjectAdditionalDetails with a unique typeId
class ProjectAdditionalDetails extends HiveObject {
  @HiveField(0)
  final String? projectType;

  ProjectAdditionalDetails({
    this.projectType,
  });
}