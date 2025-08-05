// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfAdapter extends TypeAdapter<Pdf> {
  @override
  final int typeId = 0;

  @override
  Pdf read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pdf(
      path: fields[0] as String,
      lastOpenDate: fields[1] as DateTime,
      isBookmark: fields[2] as bool,
      currentPage: fields[3] as int,
      isOpened: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Pdf obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.lastOpenDate)
      ..writeByte(2)
      ..write(obj.isBookmark)
      ..writeByte(3)
      ..write(obj.currentPage)
      ..writeByte(4)
      ..write(obj.isOpened);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
