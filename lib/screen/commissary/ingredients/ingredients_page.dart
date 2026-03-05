// lib/screens/ingredients/ingredients_page.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'ingredients_page_controller.dart';
import 'ingredients_page_desktop.dart';
import 'ingredients_page_mobile.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => IngredientsPageState();
}

class IngredientsPageState extends State<IngredientsPage> {
  late AppDatabase db;
  late IngredientsPageController controller;

  // Expose controller properties for UI access
  bool get isLoading => controller.isLoading;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = IngredientsPageController(
      db: db,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return IngredientsPageMobile(state: this);
    } else {
      return IngredientsPageDesktop(state: this);
    }
  }
}
