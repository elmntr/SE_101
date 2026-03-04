// lib/screens/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/app_globals.dart';

class CommissarySettingsPage extends StatefulWidget {
  const CommissarySettingsPage({super.key});

  @override
  State<CommissarySettingsPage> createState() => _CommissarySettingsPageState();
}

class _CommissarySettingsPageState extends State<CommissarySettingsPage> {
  bool _isSyncing = false;
  String _syncStatus = '';
  bool _isOnline = true;
  DateTime? _lastSuccessfulSync;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    try {
      final status = await syncService.getSyncStatus();
      if (mounted) {
        setState(() {
          _isOnline = status['is_online'] as bool? ?? false;
          _lastSuccessfulSync = status['last_sync'] as DateTime?;
        });
      }
    } catch (_) {}
  }

  Future<void> _performManualSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing...';
    });

    try {
      await syncService.syncAll();
      setState(() {
        _syncStatus = 'Sync completed successfully!';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('? Sync completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('? Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  if (_syncStatus.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _syncStatus.contains('failed') 
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _syncStatus.contains('failed') 
                                ? Icons.error_outline 
                                : _syncStatus.contains('completed')
                                    ? Icons.check_circle_outline
                                    : Icons.sync,
                            size: 16,
                            color: _syncStatus.contains('failed') 
                                ? Colors.red 
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _syncStatus,
                              style: TextStyle(
                                color: _syncStatus.contains('failed') 
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
                      onPressed: _isSyncing ? null : _performManualSync,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
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
                _isOnline ? Icons.wifi : Icons.wifi_off,
                color: _isOnline ? Colors.green : Colors.red,
              ),
              title: Text(_isOnline ? 'Online' : 'Offline'),
              subtitle: Text(
                _lastSuccessfulSync != null
                    ? 'Last synced: ${_formatDateTime(_lastSuccessfulSync!)}'
                    : 'Never synced',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
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
