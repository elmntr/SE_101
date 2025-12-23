// lib/app.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'screen/login/login_screen.dart';
import 'home.dart';

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
