// lib/screens/inventory/inventory_page_mobile.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'inventory_page.dart';

class InventoryPageMobile extends StatelessWidget {
  final InventoryPageState state;

  const InventoryPageMobile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Inventory',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontAll,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Inventory Page - Coming Soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: fontAll,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
