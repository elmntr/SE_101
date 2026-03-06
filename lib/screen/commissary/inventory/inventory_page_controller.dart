// lib/screens/inventory/inventory_page_controller.dart
import 'package:flutter/foundation.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';

class InventoryPageController {
  final AppDatabase db;
  final VoidCallback onStateChanged;

  bool isLoading = false;

  InventoryPageController({
    required this.db,
    required this.onStateChanged,
  });

  Future<void> loadData() async {
    isLoading = true;
    onStateChanged();

    // TODO: Load inventory data

    isLoading = false;
    onStateChanged();
  }
}
