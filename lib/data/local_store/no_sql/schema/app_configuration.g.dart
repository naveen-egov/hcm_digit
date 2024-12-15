// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_configuration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigurationAdapter extends TypeAdapter<AppConfiguration> {
  @override
  final int typeId = 0;

  @override
  AppConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfiguration()
      ..networkDetection = fields[0] as String?
      ..persistenceMode = fields[1] as String?
      ..syncMethod = fields[2] as String?
      ..maxRadius = fields[3] as double?
      ..syncTrigger = fields[4] as String?
      ..languages = (fields[5] as List).cast<Languages>()
      ..backendInterface = fields[6] as BackendInterface?
      ..genderOptions = (fields[7] as List).cast<GenderOptions>()
      ..tenantId = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, AppConfiguration obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.networkDetection)
      ..writeByte(1)
      ..write(obj.persistenceMode)
      ..writeByte(2)
      ..write(obj.syncMethod)
      ..writeByte(3)
      ..write(obj.maxRadius)
      ..writeByte(4)
      ..write(obj.syncTrigger)
      ..writeByte(5)
      ..write(obj.languages)
      ..writeByte(6)
      ..write(obj.backendInterface)
      ..writeByte(7)
      ..write(obj.genderOptions)
      ..writeByte(8)
      ..write(obj.tenantId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguagesAdapter extends TypeAdapter<Languages> {
  @override
  final int typeId = 191;

  @override
  Languages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Languages()
      ..label = fields[0] as String
      ..value = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Languages obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackendInterfaceAdapter extends TypeAdapter<BackendInterface> {
  @override
  final int typeId = 192;

  @override
  BackendInterface read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BackendInterface()
      ..interfaces = (fields[0] as List).cast<Interfaces>();
  }

  @override
  void write(BinaryWriter writer, BackendInterface obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.interfaces);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackendInterfaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderOptionsAdapter extends TypeAdapter<GenderOptions> {
  @override
  final int typeId = 193;

  @override
  GenderOptions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GenderOptions()
      ..name = fields[0] as String
      ..code = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, GenderOptions obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.code);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterfacesAdapter extends TypeAdapter<Interfaces> {
  @override
  final int typeId = 4;

  @override
  Interfaces read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Interfaces()
      ..type = fields[0] as String
      ..name = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Interfaces obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterfacesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
