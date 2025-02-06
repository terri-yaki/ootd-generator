// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothingItemAdapter extends TypeAdapter<ClothingItem> {
  @override
  final int typeId = 1;

  @override
  ClothingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClothingItem(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      name: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      category: fields[4] as ClothingCategory,
    );
  }

  @override
  void write(BinaryWriter writer, ClothingItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClothingCategoryAdapter extends TypeAdapter<ClothingCategory> {
  @override
  final int typeId = 0;

  @override
  ClothingCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClothingCategory.top;
      case 1:
        return ClothingCategory.bottom;
      case 2:
        return ClothingCategory.footwear;
      case 3:
        return ClothingCategory.accessory;
      default:
        return ClothingCategory.top;
    }
  }

  @override
  void write(BinaryWriter writer, ClothingCategory obj) {
    switch (obj) {
      case ClothingCategory.top:
        writer.writeByte(0);
        break;
      case ClothingCategory.bottom:
        writer.writeByte(1);
        break;
      case ClothingCategory.footwear:
        writer.writeByte(2);
        break;
      case ClothingCategory.accessory:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
