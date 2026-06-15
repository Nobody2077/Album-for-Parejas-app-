// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExperienceProgressAdapter extends TypeAdapter<ExperienceProgress> {
  @override
  final typeId = 0;

  @override
  ExperienceProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExperienceProgress(
      experienceId: fields[0] as String,
      completed: fields[1] as bool,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      completedDate: fields[2] as DateTime?,
      rating: (fields[3] as num?)?.toInt(),
      note: fields[4] as String?,
      photoFileNames: fields[5] == null
          ? const []
          : (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExperienceProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.experienceId)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.completedDate)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.photoFileNames)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
