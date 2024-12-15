// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_registry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceRegistryAdapter extends TypeAdapter<ServiceRegistry> {
  @override
  final int typeId = 104;

  @override
  ServiceRegistry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceRegistry()
      ..service = fields[1] as String
      ..actions = (fields[2] as List).cast<Actions>();
  }

  @override
  void write(BinaryWriter writer, ServiceRegistry obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.service)
      ..writeByte(2)
      ..write(obj.actions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceRegistryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActionsAdapter extends TypeAdapter<Actions> {
  @override
  final int typeId = 108;

  @override
  Actions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Actions()
      ..path = fields[0] as String
      ..entityName = fields[1] as String
      ..action = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, Actions obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.entityName)
      ..writeByte(2)
      ..write(obj.action);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
