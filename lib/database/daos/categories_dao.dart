// lib/database/daos/categories_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  /// Get all non-deleted categories
  Future<List<Category>> getAllCategories() async {
    return await (select(categories)..where((t) => t.isDeleted.equals(false))).get();
  }

  /// Watch categories for real-time updates
  Stream<List<Category>> watchAllCategories() {
    return (select(categories)..where((t) => t.isDeleted.equals(false))).watch();
  }

  /// Insert a new category
  Future<int> insertCategory({required String name, String? description}) {
    return into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        description: Value(description),
      ),
    );
  }

  /// Update an existing category
  Future<bool> updateCategory(Category category) => update(categories).replace(category);

  /// Soft delete a category
  Future<int> softDeleteCategory(int id) =>
      (update(categories)..where((t) => t.id.equals(id)))
          .write(CategoriesCompanion(isDeleted: Value(true)));

  /// Hard delete a category
  Future<int> deleteCategory(int id) => 
      (delete(categories)..where((t) => t.id.equals(id))).go();

  /// Get category by ID
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Count items in a category
  Future<int> getItemCountInCategory(int categoryId) async {
    final query = selectOnly(db.items)
      ..addColumns([db.items.id.count()])
      ..where(db.items.categoryId.equals(categoryId) & db.items.isDeleted.equals(false));
    
    final result = await query.getSingle();
    return result.read(db.items.id.count()) ?? 0;
  }
}