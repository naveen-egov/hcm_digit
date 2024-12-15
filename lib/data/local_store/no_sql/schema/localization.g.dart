// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalizationWrapperAdapter extends TypeAdapter<LocalizationWrapper> {
  @override
  final int typeId = 101;

  @override
  LocalizationWrapper read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalizationWrapper()
      ..id = fields[0] as int
      ..locale = fields[1] as String
      ..localizations = (fields[2] as List).cast<Localization>();
  }

  @override
  void write(BinaryWriter writer, LocalizationWrapper obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.locale)
      ..writeByte(2)
      ..write(obj.localizations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationWrapperAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalizationAdapter extends TypeAdapter<Localization> {
  @override
  final int typeId = 1;

  @override
  Localization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Localization()
      ..code = fields[0] as String
      ..message = fields[1] as String
      ..module = fields[2] as String
      ..locale = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, Localization obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.module)
      ..writeByte(3)
      ..write(obj.locale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
