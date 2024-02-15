// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedModelAdapter extends TypeAdapter<CachedModel> {
  @override
  final int typeId = 0;

  @override
  CachedModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedModel(
      image: fields[0] as Uint8List,
      ttl: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.image)
      ..writeByte(1)
      ..write(obj.ttl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
