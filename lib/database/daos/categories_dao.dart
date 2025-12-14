
// lib/database/daos/categories_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories.dart';
import '../models/category_with_count.dart';
import '../models/category_statistics.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  static const int defaultPageSize = 50;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// ✅ Get all non-deleted categories with pagination
  Future<List<Category>> getAllCategories({
    int? limit,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      final query = select(categories)
        ..where((t) => t.isDeleted.equals(false));
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where((t) => t.name.contains(searchQuery));
      }
      
      query.orderBy([(t) => OrderingTerm(expression: t.name)]);
      
      if (limit != null) {
        query.limit(limit, offset: offset);
      }
      
      return await query.get();
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return [];
    }
  }

  /// ✅ Count categories
  Future<int> getCategoryCount({String? searchQuery}) async {
    try {
      final query = selectOnly(categories)
        ..addColumns([categories.id.count()])
        ..where(categories.isDeleted.equals(false));
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where(categories.name.contains(searchQuery));
      }
      
      final result = await query.getSingle();
      return result.read(categories.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting categories: $e');
      return 0;
    }
  }

  /// ✅ Watch categories for real-time updates
  Stream<List<Category>> watchAllCategories({
    int limit = defaultPageSize,
    int offset = 0,
  }) {
    try {
      return (select(categories)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.name)])
        ..limit(limit, offset: offset))
        .watch();
    } catch (e) {
      print('❌ Error watching categories: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Insert a new category
  Future<int> insertCategory({
    required String name,
    String? description,
  }) async {
    try {
      return await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          description: Value(description),
        ),
      );
    } catch (e) {
      print('❌ Error inserting category: $e');
      rethrow;
    }
  }

  /// ✅ Batch insert categories
  Future<void> insertCategories(List<CategoriesCompanion> categoriesList) async {
    try {
      await db.batch((batch) {
        batch.insertAll(categories, categoriesList);
      });
    } catch (e) {
      print('❌ Error batch inserting categories: $e');
      rethrow;
    }
  }

  /// ✅ Update an existing category
  Future<bool> updateCategory(Category category) async {
    try {
      final updated = category.copyWith(
        lastUpdated: DateTime.now(),
      );
      return await update(categories).replace(updated);
    } catch (e) {
      print('❌ Error updating category: $e');
      return false;
    }
  }

  /// ✅ Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      return await (select(categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching category by ID: $e');
      return null;
    }
  }

  /// ✅ Get category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      return await (select(categories)
        ..where((t) => t.name.equals(name) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    } catch (e) {
      print('❌ Error fetching category by name: $e');
      return null;
    }
  }

  /// ✅ Soft delete a category (with validation)
  Future<bool> softDeleteCategory(int id) async {
    try {
      // Check if category has items
      final itemCount = await getItemCountInCategory(id);
      if (itemCount > 0) {
        print('⚠️ Cannot delete category $id: has $itemCount items');
        throw Exception('Category has $itemCount item(s). Remove items first.');
      }
      
      final result = await (update(categories)..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(
          isDeleted: Value(true),
          lastUpdated: Value(DateTime.now()),
        ));
      
      return result > 0;
    } catch (e) {
      print('❌ Error soft deleting category: $e');
      rethrow;
    }
  }

  /// ✅ Hard delete a category (dangerous!)
  Future<bool> deleteCategory(int id) async {
    try {
      // Check if category has items
      final itemCount = await getItemCountInCategory(id);
      if (itemCount > 0) {
        print('⚠️ Cannot delete category $id: has $itemCount items');
        throw Exception('Category has $itemCount item(s). Remove items first.');
      }
      
      final result = await (delete(categories)..where((t) => t.id.equals(id))).go();
      return result > 0;
    } catch (e) {
      print('❌ Error deleting category: $e');
      rethrow;
    }
  }

  /// ✅ Restore a soft-deleted category
  Future<bool> restoreCategory(int id) async {
    try {
      final result = await (update(categories)..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(
          isDeleted: Value(false),
          lastUpdated: Value(DateTime.now()),
        ));
      
      return result > 0;
    } catch (e) {
      print('❌ Error restoring category: $e');
      return false;
    }
  }

  // ============================================================================
  // ITEM RELATIONSHIP QUERIES
  // ============================================================================

  /// ✅ Count items in a category (optimized)
  Future<int> getItemCountInCategory(int categoryId) async {
    try {
      final query = selectOnly(db.items)
        ..addColumns([db.items.id.count()])
        ..where(
          db.items.categoryId.equals(categoryId) & 
          db.items.isDeleted.equals(false)
        );
      
      final result = await query.getSingle();
      return result.read(db.items.id.count()) ?? 0;
    } catch (e) {
      print('❌ Error counting items in category: $e');
      return 0;
    }
  }

  /// ✅ Get categories with item counts
  Future<List<CategoryWithCount>> getCategoriesWithItemCounts({
    int? limit,
    int offset = 0,
  }) async {
    try {
      // Custom query with LEFT JOIN and COUNT
      final query = '''
        SELECT 
          c.id,
          c.name,
          c.description,
          c.created_at,
          c.last_updated,
          COUNT(i.id) as item_count
        FROM categories c
        LEFT JOIN items i ON i.category_id = c.id AND i.is_deleted = 0
        WHERE c.is_deleted = 0
        GROUP BY c.id
        ORDER BY c.name
        ${limit != null ? 'LIMIT $limit OFFSET $offset' : ''}
      ''';
      
      final results = await customSelect(
        query,
        readsFrom: {categories, db.items},
      ).get();
      
      return results.map((row) {
        return CategoryWithCount(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          description: row.readNullable<String>('description'),
          createdAt: row.read<DateTime>('created_at'),
          lastUpdated: row.read<DateTime>('last_updated'),
          itemCount: row.read<int>('item_count'),
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching categories with counts: $e');
      return [];
    }
  }

  /// ✅ Watch categories with item counts
  Stream<List<CategoryWithCount>> watchCategoriesWithItemCounts() {
    try {
      final query = '''
        SELECT 
          c.id,
          c.name,
          c.description,
          c.created_at,
          c.last_updated,
          COUNT(i.id) as item_count
        FROM categories c
        LEFT JOIN items i ON i.category_id = c.id AND i.is_deleted = 0
        WHERE c.is_deleted = 0
        GROUP BY c.id
        ORDER BY c.name
      ''';
      
      return customSelect(
        query,
        readsFrom: {categories, db.items},
      ).watch().map((rows) {
        return rows.map((row) {
          return CategoryWithCount(
            id: row.read<int>('id'),
            name: row.read<String>('name'),
            description: row.readNullable<String>('description'),
            createdAt: row.read<DateTime>('created_at'),
            lastUpdated: row.read<DateTime>('last_updated'),
            itemCount: row.read<int>('item_count'),
          );
        }).toList();
      });
    } catch (e) {
      print('❌ Error watching categories with counts: $e');
      return Stream.value([]);
    }
  }

  /// ✅ Get empty categories (no items)
  Future<List<Category>> getEmptyCategories() async {
    try {
      final query = '''
        SELECT c.*
        FROM categories c
        LEFT JOIN items i ON i.category_id = c.id AND i.is_deleted = 0
        WHERE c.is_deleted = 0
        GROUP BY c.id
        HAVING COUNT(i.id) = 0
        ORDER BY c.name
      ''';
      
      final results = await customSelect(
        query,
        readsFrom: {categories, db.items},
      ).get();
      
      return results.map((row) {
        return Category(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          description: row.readNullable<String>('description'),
          createdAt: row.read<DateTime>('created_at'),
          lastUpdated: row.read<DateTime>('last_updated'),
          isDeleted: row.read<bool>('is_deleted'),
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching empty categories: $e');
      return [];
    }
  }

  /// ✅ Bulk assign category to items
  // Future<int> assignCategoryToItems(int categoryId, List<int> itemIds) async {
  //   try {
  //     int updatedCount = 0;
      
  //     await db.transaction(() async {
  //       for (final itemId in itemIds) {
  //         final result = await db.itemsDao.assignCategory(itemId, categoryId);
  //         if (result) updatedCount++;
  //       }
  //     });
      
  //     return updatedCount;
  //   } catch (e) {
  //     print('❌ Error bulk assigning category: $e');
  //     return 0;
  //   }
  // }

  /// ✅ Remove category from all items (set to null)
  Future<int> removeCategoryFromAllItems(int categoryId) async {
    try {
      final result = await customUpdate(
        'UPDATE items SET category_id = NULL, last_updated = ?, is_synced = 0 '
        'WHERE category_id = ?',
        updates: {db.items},
        variables: [
          Variable.withDateTime(DateTime.now()),
          Variable.withInt(categoryId),
        ],
      );
      
      return result;
    } catch (e) {
      print('❌ Error removing category from items: $e');
      return 0;
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// ✅ Get category statistics
  Future<CategoryStatistics> getCategoryStatistics(int categoryId) async {
    try {
      final query = '''
        SELECT 
          COUNT(*) as total_items,
          SUM(stock) as total_stock,
          SUM(sold) as total_sold,
          SUM(spoilage) as total_spoilage,
          AVG(stock) as avg_stock
        FROM items
        WHERE category_id = ? AND is_deleted = 0
      ''';
      
      final result = await customSelect(
        query,
        variables: [Variable.withInt(categoryId)],
        readsFrom: {db.items},
      ).getSingleOrNull();
      
      if (result == null) {
        return CategoryStatistics(
          totalItems: 0,
          totalStock: 0,
          totalSold: 0,
          totalSpoilage: 0,
          avgStock: 0.0,
        );
      }
      
      return CategoryStatistics(
        totalItems: result.read<int>('total_items'),
        totalStock: result.read<int>('total_stock'),
        totalSold: result.read<int>('total_sold'),
        totalSpoilage: result.read<int>('total_spoilage'),
        avgStock: result.read<double>('avg_stock'),
      );
    } catch (e) {
      print('❌ Error fetching category statistics: $e');
      return CategoryStatistics(
        totalItems: 0,
        totalStock: 0,
        totalSold: 0,
        totalSpoilage: 0,
        avgStock: 0.0,
      );
    }
  }
}