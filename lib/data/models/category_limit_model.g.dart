// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_limit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryLimitModelAdapter extends TypeAdapter<CategoryLimitModel> {
  @override
  final int typeId = 2;

  @override
  CategoryLimitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryLimitModel(
      category: fields[0] as String,
      limitAmount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryLimitModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.limitAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryLimitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
