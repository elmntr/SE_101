// lib/screen/commissary/login/hq_access_gate.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

/// A subtle floating button that opens an access-code dialog.
/// When the correct code is entered, navigates to the commissary login screen.
class HqAccessGate extends StatefulWidget {
  const HqAccessGate({super.key});

  @override
  State<HqAccessGate> createState() => _HqAccessGateState();
}

class _HqAccessGateState extends State<HqAccessGate> {
  Future<void> _showAccessCodeDialog() async {
    final codeController = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Enter Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Access code',
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onFieldSubmitted: (_) async {
                  await _verify(codeController.text, ctx, setDialogState, (e) => errorText = e);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _verify(codeController.text, ctx, setDialogState, (e) => errorText = e);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verify(
    String enteredCode,
    BuildContext dialogContext,
    void Function(void Function()) setDialogState,
    void Function(String?) setError,
  ) async {
    if (enteredCode.isEmpty) {
      setDialogState(() => setError('Please enter a code.'));
      return;
    }

    try {
      // Try local DB first
      final commissaryOrg = await database.organizationsDao.getMainCommissary();
      String? storedHash = commissaryOrg?.hqAccessCodeHash;

      // If no local record or hash, try online fetch
      if (storedHash == null || storedHash.isEmpty) {
        try {
          final result = await Supabase.instance.client
              .from('organizations')
              .select('hq_access_code_hash')
              .eq('type', 'commissary')
              .limit(1)
              .maybeSingle();
          storedHash = result?['hq_access_code_hash'] as String?;
        } catch (_) {
          // Offline and no local data
        }
      }

      if (storedHash == null || storedHash.isEmpty) {
        setDialogState(() => setError('Service unavailable.'));
        return;
      }

      if (verifyPassword(enteredCode, storedHash)) {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        if (mounted) {
          Navigator.pushNamed(context, '/commissary-login');
        }
      } else {
        setDialogState(() => setError('Incorrect code.'));
      }
    } catch (_) {
      setDialogState(() => setError('An error occurred.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(
          Icons.lock_outline,
          color: Colors.white.withOpacity(0.3),
        ),
        onPressed: _showAccessCodeDialog,
      ),
    );
  }
}
