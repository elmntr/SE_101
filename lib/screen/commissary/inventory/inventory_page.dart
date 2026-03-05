// lib/screens/inventory/inventory_page.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'inventory_page_controller.dart';
import 'inventory_page_desktop.dart';
import 'inventory_page_mobile.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  late AppDatabase db;
  late InventoryPageController controller;

  // Expose controller properties for UI access
  bool get isLoading => controller.isLoading;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = InventoryPageController(
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
      return InventoryPageMobile(state: this);
    } else {
      return InventoryPageDesktop(state: this);
    }
  }
}
