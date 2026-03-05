// lib/screens/settings/settings_page_desktop.dart
import 'package:flutter/material.dart';
import 'settings_page.dart';

class SettingsPageDesktop extends StatelessWidget {
  final SettingsPageState state;

  const SettingsPageDesktop({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Sync Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data Synchronization',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manually sync all data (users, branches, items) with the cloud.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Sync Status
                    if (state.syncStatus.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: state.syncStatus.contains('failed')
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.syncStatus.contains('failed')
                                  ? Icons.error_outline
                                  : state.syncStatus.contains('completed')
                                      ? Icons.check_circle_outline
                                      : Icons.sync,
                              size: 16,
                              color: state.syncStatus.contains('failed')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.syncStatus,
                                style: TextStyle(
                                  color: state.syncStatus.contains('failed')
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Sync Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            state.isSyncing ? null : () => state.performSync(),
                        icon: state.isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.sync),
                        label:
                            Text(state.isSyncing ? 'Syncing...' : 'Sync Now'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Connection Status
            Card(
              child: ListTile(
                leading: Icon(
                  state.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: state.isOnline ? Colors.green : Colors.red,
                ),
                title: Text(state.isOnline ? 'Online' : 'Offline'),
                subtitle: Text(
                  state.lastSuccessfulSync != null
                      ? 'Last synced: ${state.formatLastSync()}'
                      : 'Never synced',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
