// // lib/database/seeders/items_seeder.dart
// import '../app_database.dart';

// /// Responsible for seeding test inventory items
// class ItemsSeeder {
//   static Future<void> seed(AppDatabase db) async {
//     final existingItems = await db.itemsDao.getAllItems();

//     if (existingItems.isNotEmpty) {
//       print('📦 Items already exist in database (${existingItems.length} items)');
//       return;
//     }

//     print('🌱 Seeding test items...');

//     final testItems = [
//       {'name': 'Chicken Breast', 'stock': 50},
//       {'name': 'Chicken Thigh', 'stock': 40},
//       {'name': 'Chicken Wings', 'stock': 30},
//       {'name': 'Eggs (Dozen)', 'stock': 100},
//       {'name': 'Cooking Oil (L)', 'stock': 20},
//     ];

//     for (final item in testItems) {
//       await db.itemsDao.insertItem(
//         name: item['name'] as String,
//         stock: item['stock'] as int,
//       );
//     }

//     print('✅ Test items seeded successfully');
//   }
// }
