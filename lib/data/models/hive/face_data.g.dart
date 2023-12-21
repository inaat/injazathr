// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'face_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaceDataAdapter extends TypeAdapter<FaceData> {
  @override
  final int typeId = 1; // Update the type ID to match the FaceData class

  @override
  FaceData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaceData(
      facePhotoBytes: fields[0] as Uint8List?,
      faceArray: (fields[1] as List?)?.cast<dynamic>(),
      id: fields[2] as String?,
      name: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FaceData obj) {
    writer
      ..writeByte(4) // Update the number of fields to match the FaceData class
      ..writeByte(0)
      ..write(obj.facePhotoBytes)
      ..writeByte(1)
      ..write(obj.faceArray)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaceDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
