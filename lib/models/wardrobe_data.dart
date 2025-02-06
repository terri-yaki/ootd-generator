import 'package:hive/hive.dart';
import 'clothing_item.dart';

class WardrobeData {
  static Box<ClothingItem> get box => Hive.box<ClothingItem>('wardrobeBox');

  static List<ClothingItem> get items => box.values.toList();

  static Future<void> addItem(ClothingItem item) async {
    await box.put(item.id, item);
  }

  static Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  static Future<void> updateItem(ClothingItem item) async {
    await item.save();
  }
}
