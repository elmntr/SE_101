// lib/screens/settings/settings_page_controller.dart
import 'package:flutter/material.dart';

import 'package:chickenjoo_inventory/app_globals.dart';

class SettingsPageController {
  final VoidCallback onStateChanged;

  bool isSyncing = false;
  String syncStatus = '';

  SettingsPageController({
    required this.onStateChanged,
  });

  Future<void> performManualSync() async {
    if (isSyncing) return;

    isSyncing = true;
    syncStatus = 'Syncing...';
    onStateChanged();

    try {
      await syncService.syncAll();
      syncStatus = 'Sync completed successfully!';
      isSyncing = false;
      onStateChanged();
      return; // Success
    } catch (e) {
      syncStatus = 'Sync failed: $e';
      isSyncing = false;
      onStateChanged();
      rethrow; // Re-throw to let caller handle UI feedback
    }
  }

  // Note: These are approximations since syncService doesn't expose these directly
  bool get isOnline => true; // Default to true; actual connectivity managed elsewhere
  DateTime? get lastSuccessfulSync => null; // Not directly exposed by sync service

  String formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
