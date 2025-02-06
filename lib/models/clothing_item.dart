import 'package:hive/hive.dart';

part 'clothing_item.g.dart';

@HiveType(typeId: 0)
enum ClothingCategory {
  @HiveField(0)
  top,
  @HiveField(1)
  bottom,
  @HiveField(2)
  footwear,
  @HiveField(3)
  accessory,
}

@HiveType(typeId: 1)
class ClothingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final List<String> tags;

  @HiveField(4)
  final ClothingCategory category;

  ClothingItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.tags,
    required this.category,
  });
}
