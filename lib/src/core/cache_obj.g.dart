// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_obj.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheObjAdapter extends TypeAdapter<CacheObj> {
  @override
  final int typeId = 0;

  @override
  CacheObj read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheObj(
      fields[0] as String,
      (fields[4] as List).cast<int>(),
      subKey: fields[1] as String?,
      statusCode: fields[5] as int?,
      headers: (fields[6] as List?)?.cast<int>(),
    )
      ..maxAgeDate = fields[2] as int?
      ..maxStaleDate = fields[3] as int?;
  }

  @override
  void write(BinaryWriter writer, CacheObj obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.subKey)
      ..writeByte(2)
      ..write(obj.maxAgeDate)
      ..writeByte(3)
      ..write(obj.maxStaleDate)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.statusCode)
      ..writeByte(6)
      ..write(obj.headers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheObjAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
