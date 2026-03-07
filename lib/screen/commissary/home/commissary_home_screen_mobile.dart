import 'package:flutter/material.dart';

import 'package:chickenjoo_inventory/connection_status_indicator.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'commissary_home_screen.dart';

class CommissaryHomeScreenMobile extends StatelessWidget {
  const CommissaryHomeScreenMobile({super.key, required this.state});

  final CommissaryHomeScreenState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 3,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imageAll, height: 25),
          ],
        ),
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
                } else if (value == 'settings') {
                  // Navigate to settings page (index 5)
                  state.switchPage(5);
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
                        state.currentUserData.username,
                        style: const TextStyle(fontFamily: fontAll),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    state.currentUserData.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: fontAll,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: TextStyle(fontFamily: fontAll),
                      ),
                    ],
                  ),
                ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.selectedIndex < 5 ? state.selectedIndex : 0,
        onTap: state.switchPage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red.shade400,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: state.menuItems
            .where((item) => item["label"] != "Settings")
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item["icon"] as IconData),
                label: item["label"] as String,
              ),
            )
            .toList(),
      ),
    );
  }
}
