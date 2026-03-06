// lib/screens/ingredients/ingredients_page_controller.dart
import 'package:flutter/foundation.dart';

import 'package:chickenjoo_inventory/database/app_database.dart';

class IngredientsPageController {
  final AppDatabase db;
  final VoidCallback onStateChanged;

  bool isLoading = false;

  IngredientsPageController({
    required this.db,
    required this.onStateChanged,
  });

  Future<void> loadData() async {
    isLoading = true;
    onStateChanged();

    // TODO: Load ingredients data

    isLoading = false;
    onStateChanged();
  }
}
