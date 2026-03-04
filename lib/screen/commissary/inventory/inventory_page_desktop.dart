// lib/screens/inventory/inventory_page_desktop.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'inventory_page.dart';

class InventoryPageDesktop extends StatelessWidget {
  final InventoryPageState state;

  const InventoryPageDesktop({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontAll,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Inventory Page - Coming Soon',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontFamily: fontAll,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
