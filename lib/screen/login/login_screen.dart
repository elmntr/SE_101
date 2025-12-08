// lib/screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chickenjoo_inventory/screen/login/widgets/login_form.dart';
import 'package:chickenjoo_inventory/screen/login/widgets/login_header.dart';

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
    _db = database;

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
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    isSubmitting: _isSubmitting,
                    onPasswordVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onLogin: _handleLogin,
                    loginButtonWidth: loginButtonWidth,
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