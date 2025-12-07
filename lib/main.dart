import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/database/seeders/admin_seeder.dart';
import 'package:chickenjoo_inventory/database/database_provider.dart';
import 'package:chickenjoo_inventory/database/database_connection.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Inventory');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1920, 1080));
  }
  
  //await DatabaseConnection.deleteOldDatabase();
  //await DatabaseConnection.deleteDatabase();
  await AdminSeeder.seed(AppDatabase()); // Important for Testing admin@commissary.com ; admin123

  runApp(const MyApp());
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  late final AppDatabase _db;

  @override
void initState() {
  super.initState();
  _db = DatabaseProvider.database;

  // Check for stored user ID
  _checkPersistentLogin();

  Future.microtask(() async {
    await _db.usersDao.getAllUsers();
  });
}
Future<void> _checkPersistentLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final storedUserId = prefs.getInt('loggedInUserId');
  if (storedUserId != null) {
    // Fetch user from DB
    final user = await _db.usersDao.getUserById(storedUserId);
    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    }
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter both email and password.')),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  final user = await _db.usersDao.authenticate(email, password);

  if (!mounted) return;

  setState(() => _isSubmitting = false);

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid email or password.')),
    );
    return;
  }

  // Save user ID persistently
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('loggedInUserId', user.id);

  // Navigate to home
  Navigator.pushReplacementNamed(
    context,
    '/home',
    arguments: user,
  );
}
// Add a logout function wherever needed:
Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('loggedInUserId'); // Clear saved user

  // Navigate to login and remove all previous routes
  if (mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false, // Remove all previous routes
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final fieldPadding = AppLayout.fieldPadding(context);
    final loginButtonWidth = AppLayout.loginButtonWidth(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFEF4848)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: fieldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: Image.asset(
                      imageAll,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Inventory System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontFamily: fontAll,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Email Address',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(
                        fontFamily: fontAll,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: loginButtonWidth,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 10,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontFamily: fontAll,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}