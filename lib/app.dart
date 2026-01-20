// lib/app.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/utils/app_logger.dart';
import 'screen/login/login_screen.dart';
import 'home/home.dart';

/// Reinitialize sync service with user's organization context after login
void _reinitializeSyncWithUserContext(UserData userData) {
  try {
    // Get parent commissary info for franchisees
    String? parentCommissaryCloudId;
    int? parentCommissaryId;
    
    if (userData.isFranchisee) {
      // For franchisees, we need to look up parent commissary
      // This will be loaded from the organization record
      AppGlobals.instance.database.organizationsDao
          .getOrganizationById(userData.organizationId)
          .then((org) {
        if (org?.parentCommissaryId != null) {
          // Get parent commissary cloud ID
          AppGlobals.instance.database.organizationsDao
              .getOrganizationById(org!.parentCommissaryId!)
              .then((parentOrg) {
            // Reinitialize with parent commissary context
            AppGlobals.instance.syncService.initialize(
              organizationId: userData.organizationId,
              organizationCloudId: userData.organizationCloudId,
              organizationType: userData.organizationType,
              parentCommissaryId: org.parentCommissaryId,
              parentCommissaryCloudId: parentOrg?.cloudId,
            );
          });
        }
      });
    }

    // Initial sync with known context (cloud ID from UserData)
    AppGlobals.instance.syncService.initialize(
      organizationId: userData.organizationId,
      organizationCloudId: userData.organizationCloudId,  // ✅ Pass cloud ID directly
      organizationType: userData.organizationType,
      parentCommissaryId: parentCommissaryId,
      parentCommissaryCloudId: parentCommissaryCloudId,
    );
    
    AppLogger.sync('Sync service reinitialized for org: ${userData.organizationName} (${userData.organizationType})');
    AppLogger.debug('   📍 Org cloud ID: ${userData.organizationCloudId}');
  } catch (e) {
    AppLogger.warning('Failed to reinitialize sync service: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Joo Inventory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // ✅ SET INITIAL ROUTE
      initialRoute: '/login',

      // ✅ DEFINE ROUTES
      routes: {'/login': (context) => const LoginScreen()},

      // ✅ HANDLE ROUTES WITH ARGUMENTS (for HomeScreen with UserData)
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final userData = settings.arguments as UserData?;

          // If no user provided, redirect to login
          if (userData == null) {
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          }

          // ✅ Reinitialize sync service with user's organization context
          _reinitializeSyncWithUserContext(userData);

          return MaterialPageRoute(
            builder: (context) => HomeScreen(signedInUser: userData),
          );
        }

        // Default fallback
        return null;
      },
    );
  }
}
