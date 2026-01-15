import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:flutter/material.dart';

import '../../connection_status_indicator.dart';
import 'home.dart';

class HomeScreenDesktop extends StatelessWidget {
  const HomeScreenDesktop({super.key, required this.state});

  final HomeScreenState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 35),
          onPressed: state.toggleSidebar,
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imageAll, height: 30),
            const SizedBox(width: 10),
            const Text(
              "Inventory System",
              style: TextStyle(
                fontFamily: fontAll,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
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
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    state.widget.signedInUser.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: fontAll,
                    ),
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
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: state.isSideBarOpen ? 200 : 70,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                if (state.isLoadingRole)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else
                  ...List.generate(state.menuItems.length, (index) {
                    return Column(
                      children: [
                        _SideBarButton(
                          state: state,
                          icon: state.menuItems[index]["icon"],
                          label: state.menuItems[index]["label"],
                          index: index,
                        ),
                        const SizedBox(height: 5),
                      ],
                    );
                  }),
              ],
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            child: state.isLoadingRole
                ? const Center(child: CircularProgressIndicator())
                : state.currentPage ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SideBarButton extends StatelessWidget {
  const _SideBarButton({
    required this.state,
    required this.icon,
    required this.label,
    required this.index,
  });

  final HomeScreenState state;
  final IconData icon;
  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool active = state.selectedIndex == index;

    return InkWell(
      onTap: () => state.switchPage(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: active
            ? BoxDecoration(color: Colors.white.withOpacity(0.25))
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: active ? Colors.red : Colors.grey.shade900,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: state.showLabels
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: fontAll,
                            fontSize: 16,
                            color: active ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}