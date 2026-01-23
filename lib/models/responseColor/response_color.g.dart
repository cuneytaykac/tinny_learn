// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_color.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResponseColorAdapter extends TypeAdapter<ResponseColor> {
  @override
  final int typeId = 2;

  @override
  ResponseColor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResponseColor(
      imagePath: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ResponseColor obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
