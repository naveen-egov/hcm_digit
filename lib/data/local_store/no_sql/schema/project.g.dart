// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectModelAdapter extends TypeAdapter<ProjectModel> {
  @override
  final int typeId = 200;

  @override
  ProjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectModel(
      id: fields[0] as String,
      projectTypeId: fields[1] as String?,
      projectNumber: fields[2] as String?,
      subProjectTypeId: fields[3] as String?,
      isTaskEnabled: fields[4] as bool?,
      parent: fields[5] as String?,
      name: fields[6] as String,
      department: fields[7] as String?,
      description: fields[8] as String?,
      referenceId: fields[9] as String?,
      projectHierarchy: fields[10] as String?,
      nonRecoverableError: fields[11] as bool?,
      tenantId: fields[12] as String?,
      rowVersion: fields[13] as int?,
      startDateTime: fields[14] as DateTime?,
      endDateTime: fields[15] as DateTime?,
      additionalFields: fields[16] as ProjectAdditionalFields?,
      additionalDetails: fields[17] as ProjectAdditionalDetails?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectTypeId)
      ..writeByte(2)
      ..write(obj.projectNumber)
      ..writeByte(3)
      ..write(obj.subProjectTypeId)
      ..writeByte(4)
      ..write(obj.isTaskEnabled)
      ..writeByte(5)
      ..write(obj.parent)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.department)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.referenceId)
      ..writeByte(10)
      ..write(obj.projectHierarchy)
      ..writeByte(11)
      ..write(obj.nonRecoverableError)
      ..writeByte(12)
      ..write(obj.tenantId)
      ..writeByte(13)
      ..write(obj.rowVersion)
      ..writeByte(14)
      ..write(obj.startDateTime)
      ..writeByte(15)
      ..write(obj.endDateTime)
      ..writeByte(16)
      ..write(obj.additionalFields)
      ..writeByte(17)
      ..write(obj.additionalDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdditionalFieldsAdapter
    extends TypeAdapter<ProjectAdditionalFields> {
  @override
  final int typeId = 201;

  @override
  ProjectAdditionalFields read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectAdditionalFields(
      schema: fields[0] as String,
      version: fields[1] as String,
      fields: (fields[2] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectAdditionalFields obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.schema)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.fields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdditionalFieldsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdditionalDetailsAdapter
    extends TypeAdapter<ProjectAdditionalDetails> {
  @override
  final int typeId = 203;

  @override
  ProjectAdditionalDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectAdditionalDetails(
      projectType: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectAdditionalDetails obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.projectType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdditionalDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
