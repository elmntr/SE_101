// lib/screens/home/home_screen_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/services/connectivity_service.dart';
import 'package:chickenjoo_inventory/utils/sync_status.dart';

class CommissaryHomeScreenController {
  final AppDatabase db;
  final VoidCallback onStateChanged;
  final UserData signedInUser;

  late ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  Widget? currentPage;
  int selectedIndex = 0;
  bool isSideBarOpen = false;
  bool showLabels = false;
  bool isOnline = true;
  SyncStatus syncStatus = SyncStatus.synced;

  List<Map<String, dynamic>> menuItems = [];

  CommissaryHomeScreenController({
    required this.db,
    required this.onStateChanged,
    required this.signedInUser,
  });

  void init() {
    _initConnectivity();
    loadMenuItems();
  }

  void _initConnectivity() {
    _connectivityService = ConnectivityService();
    _connectivitySubscription = _connectivityService.connectionStream.listen((online) {
      if (isOnline != online) {
        isOnline = online;
        syncStatus = online ? SyncStatus.synced : SyncStatus.idle;
        onStateChanged();
      }
    });
  }

  void loadMenuItems() {
    // Note: menuItems are loaded with pages in the main widget
    // This is called from the widget to trigger initial load
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
  }

  void toggleSidebar() {
    isSideBarOpen = !isSideBarOpen;
    showLabels = false;
    onStateChanged();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (isSideBarOpen) {
        showLabels = true;
        onStateChanged();
      }
    });
  }

  void switchPage(int index) {
    selectedIndex = index;
    currentPage = menuItems[index]['page'];
    isSideBarOpen = false;
    showLabels = false;
    onStateChanged();
  }

  Future<void> triggerManualSync() async {
    syncStatus = SyncStatus.syncing;
    onStateChanged();

    try {
      await syncService.syncAll();
      syncStatus = isOnline ? SyncStatus.synced : SyncStatus.idle;
      onStateChanged();
    } catch (e) {
      syncStatus = isOnline ? SyncStatus.synced : SyncStatus.idle;
      onStateChanged();
      rethrow;
    }
  }

  Future<bool> confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return shouldLogout ?? false;
  }

  Future<void> performLogout(BuildContext context) async {
    try {
      // Sign out from auth service (clears Supabase session and user state)
      await authService.signOut();

      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedInUserId');

      // Navigate to login screen - will be handled by caller
    } catch (e) {
      print('âŒ Error during logout: $e');
      // Still navigate to login even if logout fails - will be handled by caller
    }
  }
}
