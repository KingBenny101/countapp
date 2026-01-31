// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_counter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesCounterAdapter extends TypeAdapter<SeriesCounter> {
  @override
  final typeId = 2;

  @override
  SeriesCounter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesCounter(
      id: fields[0] as String?,
      name: fields[1] as String,
      value: fields[2] as num,
      description: fields[6] == null ? "" : fields[6] as String,
      isLocked: fields[7] == null ? false : fields[7] as bool,
      lastUpdated: fields[3] as DateTime?,
      updates: (fields[4] as List?)?.cast<DateTime>(),
      seriesValues: (fields[5] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeriesCounter obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.updates)
      ..writeByte(5)
      ..write(obj.seriesValues)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.isLocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesCounterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
