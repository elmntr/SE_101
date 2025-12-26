// lib/database/models/item_with_category.dart
import '../app_database.dart';

/// Helper class for JOIN queries combining Item and Category data
class ItemWithCategory {
  final Item item;
  final Category? category;

  ItemWithCategory({required this.item, required this.category});

  String get categoryName => category?.name ?? 'Uncategorized';
}
