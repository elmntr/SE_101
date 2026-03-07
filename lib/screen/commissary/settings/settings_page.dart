// lib/screens/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'settings_page_controller.dart';
import 'settings_page_desktop.dart';
import 'settings_page_mobile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late SettingsPageController controller;

  // Expose controller properties for UI access
  bool get isSyncing => controller.isSyncing;
  String get syncStatus => controller.syncStatus;
  bool get isOnline => controller.isOnline;
  DateTime? get lastSuccessfulSync => controller.lastSuccessfulSync;

  @override
  void initState() {
    super.initState();
    controller = SettingsPageController(
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> performSync() async {
    try {
      await controller.performManualSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('âŒ Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatLastSync() {
    if (lastSuccessfulSync == null) return 'Never';
    return controller.formatDateTime(lastSuccessfulSync!);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return SettingsPageMobile(state: this);
    } else {
      return SettingsPageDesktop(state: this);
    }
  }
}
