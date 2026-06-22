// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_moment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomMomentAdapter extends TypeAdapter<CustomMoment> {
  @override
  final typeId = 1;

  @override
  CustomMoment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomMoment(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomMoment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomMomentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
