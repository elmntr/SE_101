// lib/app.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
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
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      
      // ✅ HANDLE ROUTES WITH ARGUMENTS (for HomeScreen with User)
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments as User?;
          
          // If no user provided, redirect to login
          if (user == null) {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
          
          return MaterialPageRoute(
            builder: (context) => HomeScreen(signedInUser: user),
          );
        }
        
        // Default fallback
        return null;
      },
    );
  }
}