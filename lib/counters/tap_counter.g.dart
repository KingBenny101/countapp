// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tap_counter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TapCounterAdapter extends TypeAdapter<TapCounter> {
  @override
  final typeId = 1;

  @override
  TapCounter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TapCounter(
      id: fields[3] as String?,
      name: fields[4] as String,
      value: (fields[5] as num).toInt(),
      stepSize: (fields[0] as num).toInt(),
      direction: fields[1] as TapDirection,
      requireConfirmation: fields[2] == null ? true : fields[2] as bool,
      lastUpdated: fields[6] as DateTime?,
      updates: (fields[7] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, TapCounter obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.stepSize)
      ..writeByte(1)
      ..write(obj.direction)
      ..writeByte(2)
      ..write(obj.requireConfirmation)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.value)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.updates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TapCounterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TapDirectionAdapter extends TypeAdapter<TapDirection> {
  @override
  final typeId = 2;

  @override
  TapDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TapDirection.increment;
      case 1:
        return TapDirection.decrement;
      default:
        return TapDirection.increment;
    }
  }

  @override
  void write(BinaryWriter writer, TapDirection obj) {
    switch (obj) {
      case TapDirection.increment:
        writer.writeByte(0);
      case TapDirection.decrement:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TapDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
