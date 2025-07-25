// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseEntryModelAdapter extends TypeAdapter<ExpenseEntryModel> {
  @override
  final int typeId = 1;

  @override
  ExpenseEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseEntryModel(
      id: fields[0] as String,
      category: fields[1] as String,
      subCategory: fields[2] as String,
      description: fields[3] as String?,
      date: fields[4] as DateTime,
      amount: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseEntryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.subCategory)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
