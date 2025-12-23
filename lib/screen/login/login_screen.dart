// lib/screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
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

  // Branch selection
  List<Map<String, dynamic>> _branches = [];
  Map<String, dynamic>? _selectedBranch;
  bool _isLoadingBranches = true;
  String? _branchLoadError;

  late final SupabaseAuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = authService;

    // Load available branches
    _loadBranches();

    // Check for existing Supabase session
    _checkExistingSession();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoadingBranches = true;
      _branchLoadError = null;
    });

    try {
      final branches = await _authService.fetchAvailableBranches();
      if (mounted) {
        setState(() {
          _branches = branches;
          _isLoadingBranches = false;
          if (branches.isEmpty) {
            _branchLoadError = 'No branches available';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBranches = false;
          _branchLoadError = 'Failed to load branches';
        });
      }
    }
  }

  Future<void> _checkExistingSession() async {
    final result = await _authService.restoreSession();
    if (result.success && result.localUser != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home', arguments: result.localUser);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    // Clear any existing snackbars before showing a new one
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleLogin() async {
    // Prevent multiple simultaneous login attempts
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_selectedBranch == null) {
      _showSnackBar('Please select a branch first.');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Sign in to the selected branch
      final branchCloudId = _selectedBranch!['cloud_id'] as String;
      final result = await _authService.signInToBranch(
        email: email,
        password: password,
        branchCloudId: branchCloudId,
      );

      if (!mounted) return;

      if (!result.success || result.localUser == null) {
        _showSnackBar(result.message ?? 'Invalid email or password.');
        setState(() => _isSubmitting = false);
        return;
      }

      // Navigate to home with authenticated user data
      Navigator.pushReplacementNamed(context, '/home', arguments: result.localUser);
    } catch (e, stackTrace) {
      if (!mounted) return;
      print('❌ Login error: $e');
      print('   Stack trace: $stackTrace');
      _showSnackBar('An error occurred. Please try again.');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldPadding = AppLayout.fieldPadding(context);
    final loginButtonWidth = AppLayout.loginButtonWidth(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  // Branch Selector
                  _buildBranchSelector(loginButtonWidth),
                  const SizedBox(height: 20),
                  Focus(
                    onKey: (node, event) {
                      if (event.logicalKey.keyLabel == 'Enter') {
                        _handleLogin();
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: LoginForm(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchSelector(double width) {
    if (_isLoadingBranches) {
      return SizedBox(
        width: width,
        child: const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading branches...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_branchLoadError != null) {
      return SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _branchLoadError!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadBranches,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: _selectedBranch?['cloud_id'] as String?,
            decoration: const InputDecoration(
              labelText: 'Select Branch',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.store),
            ),
            hint: const Text('Choose your branch'),
            isExpanded: true,
            items: _branches.map((branch) {
              return DropdownMenuItem<String>(
                value: branch['cloud_id'] as String,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      branch['name'] as String? ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (branch['address'] != null)
                      Text(
                        branch['address'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBranch = _branches.firstWhere(
                  (b) => b['cloud_id'] == value,
                  orElse: () => {},
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
