// lib/utils/reset_admin_credentials.dart
// Emergency credential reset - use when locked out
// Uncomment the call in main.dart to run this

import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Todo: Make sure to delete this file before deployment, or at least remove the call in main.dart after use to prevent accidental resets!;
Future<void> resetAdminCredentials(AppDatabase db) async {
  print('🔧 Starting admin credential reset...');
  
  try {
    // Find all users to see the current state
    final users = await db.usersDao.getAllUsers(limit: 10);
    
    print('📋 Found ${users.length} users:');
    for (final user in users) {
      print('  ID: ${user.id} | ${user.username} | ${user.email}');
    }
    
    if (users.isEmpty) {
      print('❌ No users found');
      return;
    }
    
    // Find user with "Administrator" username (the one we need to fix)
    final admin = users.firstWhere(
      (u) => u.username == 'Administrator',
      orElse: () => users.first,
    );
    
    print('\n🔄 Resetting user: ${admin.username} (ID: ${admin.id})');
    print('   Current email in DB: ${admin.email}');
    
    // Check Supabase Auth current user
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null) {
      print('   Current email in Supabase Auth: ${supabaseUser.email}');
      
      // Try to reset Supabase Auth email first
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: 'admin@chickenjoo.com'),
        );
        print('✅ Supabase Auth email updated to: admin@chickenjoo.com');
      } catch (e) {
        print('⚠️ Supabase Auth update failed: $e');
        print('   Continuing with local DB update only...');
      }
    } else {
      print('⚠️ Not logged in to Supabase Auth - will only update local DB');
    }
    
    // Update local database
    final updatedAdmin = admin.copyWith(
      email: 'admin@chickenjoo.com',
      username: 'Administrator',
      lastUpdated: DateTime.now(),
      isSynced: false,
    );
    
    final success = await db.usersDao.updateUser(updatedAdmin);
    
    if (success) {
      // Verify the update
      final verified = await db.usersDao.getUserById(admin.id);
      if (verified?.email == 'admin@chickenjoo.com') {
        print('✅ Local database updated successfully!');
        print('   Email: admin@chickenjoo.com');
        print('   Username: ${verified?.username ?? "(unknown)"}');
        print('   Password: (unchanged - use your original password)');
        print('');
        print('🔐 You can now login with: admin@chickenjoo.com');
        print('⚠️ IMPORTANT: Comment out the reset line in main.dart after successful login!');
      } else {
        print('❌ Verification failed - email is: ${verified?.email}');
      }
    } else {
      print('❌ Update failed');
    }
    
  } catch (e) {
    print('❌ Error: $e');
    print('   Stack trace: ${StackTrace.current}');
  }
}
