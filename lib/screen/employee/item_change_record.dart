import 'package:chickenjoo_inventory/database/app_database.dart';

class ChangeRecord {
  final String employeeName;
  final String role;
  final List<Item> items;
  String status; // "In Review", "Updated", "Reverted"

  ChangeRecord({
    required this.employeeName,
    required this.role,
    required this.items,
    this.status = "In Review",
  });

  int get totalChanges =>
      items.fold(0, (sum, item) => sum + item.sold + item.spoilage);
}
