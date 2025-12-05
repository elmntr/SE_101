import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:chickenjoo_inventory/design_constants.dart';

import 'package:chickenjoo_inventory/database/database_provider.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:drift/drift.dart' as drift; // <- needed for Value<>

import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Chicken Joo Inventory');
    setWindowMinSize(const Size(1280, 720));
    setWindowMaxSize(const Size(1920, 1080)); 
  }
  
  

  runApp(const MyApp());
}
Future<void> seedTestEmployee(AppDatabase db) async {
  // Check if role already exists
  final existingRoles = await db.rolesDao.getAllRoles();
  Role? employeeRole = existingRoles.firstWhere(
    (r) => r.name == 'employee',
    orElse: () => Role(
      id: 0,
      name: 'employee',
      description: 'Test Employee Role',
      canViewInventory: true,
      canAddInventory: true,
      canEditInventory: true,
      canDeleteInventory: false,
      canViewReports: false,
      canExportData: false,
      canAccessSettings: false,
      isSystemRole: false,
      isActive: true,
      
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      canManageEmployees: false,
      canManageRoles: false
    ),
  );

  // Insert the role if it didn’t exist
  if (employeeRole.id == 0) {
    final roleId = await db.rolesDao.insertRole(
      RolesCompanion.insert(
        name: 'employee',
        description: drift.Value('Test Employee Role'),
        canViewInventory: drift.Value(true),
        canAddInventory: drift.Value(true),
        canEditInventory: drift.Value(true),
        canDeleteInventory: drift.Value(false),
        canViewReports: drift.Value(false),
        canExportData: drift.Value(false),
        canAccessSettings: drift.Value(false),
      ),
    );

    employeeRole = (await db.rolesDao.getAllRoles())
        .firstWhere((r) => r.id == roleId);
  }

  // Check if user exists
  final users = await db.usersDao.getAllUsers();
  final existingUser =
      users.firstWhere((u) => u.username == 'test_employee', orElse: () => User(
        id: 0,
        username: 'test_employee',
        email: 'employee@test.com',
        password: '123456',
        phone: '',
        roleId: employeeRole!.id,
        isActive: true,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ));
       // 2️⃣ Insert a test employee user
  final existingUsers = await db.usersDao.getAllUsers();
  final alreadyExists = existingUsers.any((u) => u.username == 'employee');

  if (!alreadyExists) {
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        username: 'employee',
        email: 'employee@example.com',
        password: 'password123',
        roleId: employeeRole.id, // ✅ non-null
        isActive: drift.Value(true),
      ),
    );
  }

  

  print('✅ Test employee account created: test_employee / 123456');
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
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
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

  // Use the new AppDatabase instance
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = DatabaseProvider.instance;

    // Seed default accounts using the new DAO method
    Future.microtask(() async {
      await _db.usersDao.getAllUsers();
    });
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

    // Authenticate user using the new UsersDao function
    final user = await _db.usersDao.authenticate(email, password);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          signedInUser: user,
        ),
      ),
    );
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
