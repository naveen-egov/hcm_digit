// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'row_versions.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RowVersionListAdapter extends TypeAdapter<RowVersionList> {
  @override
  final int typeId = 103;

  @override
  RowVersionList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RowVersionList()
      ..id = fields[0] as int
      ..module = fields[1] as String
      ..version = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, RowVersionList obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.module)
      ..writeByte(2)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowVersionListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
