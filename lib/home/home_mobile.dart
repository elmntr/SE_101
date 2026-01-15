import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';

import '../../connection_status_indicator.dart';
import 'home.dart';

class HomeScreenMobile extends StatelessWidget {
  const HomeScreenMobile({super.key, required this.state});

  final HomeScreenState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 3,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Connection Status Indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(
              isOnline: state.isOnline,
              syncStatus: state.syncStatus,
              onSyncPressed: state.triggerManualSync,
            ),
          ),
          
          // Profile Menu with Logout
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 28,
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  state.handleLogout();
                } else if (value == 'profile') {
                  // Navigate to profile page
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        state.widget.signedInUser.username,
                        style: const TextStyle(fontFamily: fontAll),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: fontAll,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: state.currentPage ?? const SizedBox.shrink(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red.shade400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imageAll, height: 60),
                  const SizedBox(height: 10),
                  const Text(
                    "Inventory System",
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            ...List.generate(state.menuItems.length, (index) {
              final bool isActive = state.selectedIndex == index;

              return ListTile(
                leading: Icon(
                  state.menuItems[index]["icon"],
                  color: isActive ? Colors.red : Colors.black,
                ),
                title: Text(
                  state.menuItems[index]["label"],
                  style: TextStyle(
                    color: isActive ? Colors.red : Colors.black,
                    fontFamily: fontAll,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                tileColor: isActive ? Colors.red.withValues(alpha: 0.08) : null,
                selected: isActive,
                onTap: () {
                  Navigator.pop(context);
                  state.switchPage(index);
                },
              );
            }),
            // Logout button in drawer
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontFamily: fontAll),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                state.handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}