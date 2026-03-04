// Branches Page - Manage franchisee branches and their admins
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'branches_page_desktop.dart';
import 'branches_page_mobile.dart';

/// Branches Page - Manage franchisee branches and their admins
/// Commissary can:
/// - Create new branches (franchisees)
/// - Create branch admin users scoped to a specific branch
/// - View all branches and their status
class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => BranchesPageState();
}

class BranchesPageState extends State<BranchesPage> {
  late AppDatabase db;
  List<Organization> branches = [];
  Map<int, List<User>> branchUsers = {};
  Organization? commissary;
  bool isLoading = true;
  int selectedTab = 0; // 0 = Branches, 1 = Branch Admins

  // Search functionality
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Sort functionality
  String branchSortOrder = 'nameAsc';
  String adminSortOrder = 'nameAsc';
  bool showActiveOnly = false;

  final _uuid = const Uuid();

  void setSelectedTab(int index) {
    setState(() => selectedTab = index);
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void setBranchSortOrder(String order) {
    setState(() {
      branchSortOrder = order;
    });
  }

  void setAdminSortOrder(String order) {
    setState(() {
      adminSortOrder = order;
    });
  }

  void toggleShowActiveOnly(bool value) {
    setState(() {
      showActiveOnly = value;
    });
  }

  /// Get filtered and sorted branches based on search query and sort order
  List<Organization> get filteredBranches {
    var list = branches.toList();
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      list = SearchService.filter(
        list,
        searchQuery,
        (branch) => [branch.name, branch.address, branch.email, branch.phone],
      );
    }
    
    // Apply active filter
    if (showActiveOnly) {
      list = list.where((b) => b.isActive).toList();
    }
    
    // Apply sorting
    list.sort((a, b) {
      switch (branchSortOrder) {
        case 'nameAsc':
          return a.name.compareTo(b.name);
        case 'nameDesc':
          return b.name.compareTo(a.name);
        case 'activeFirst':
          return (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0);
        case 'inactiveFirst':
          return (a.isActive ? 1 : 0).compareTo(b.isActive ? 1 : 0);
        case 'newestFirst':
          return b.createdAt.compareTo(a.createdAt);
        case 'oldestFirst':
          return a.createdAt.compareTo(b.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });
    
    return list;
  }

  /// Get filtered users based on search query
  List<User> getFilteredUsersForBranch(int branchId) {
    final users = branchUsers[branchId] ?? [];
    if (searchQuery.isEmpty) return users;
    return SearchService.filter(
      users,
      searchQuery,
      (user) => [user.username, user.email, user.phone],
    );
  }

  @override
  void initState() {
    super.initState();
    db = database;
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // Debug: Get all organizations first
      final allOrgs = await db.organizationsDao.getAllOrganizations();
      print('🔍 DEBUG: Total organizations in local DB: ${allOrgs.length}');
      for (final org in allOrgs) {
        print('   - [${org.type}] ${org.name} (cloudId: ${org.cloudId}, parentCommissaryId: ${org.parentCommissaryId})');
      }

      // Get commissary
      commissary = await db.organizationsDao.getCommissary();
      if (commissary == null) {
        print('⚠️ No commissary found');
        setState(() => isLoading = false);
        return;
      }
      print('✅ Commissary found: ${commissary!.name} (id: ${commissary!.id})');

      // Get all franchisees under this commissary (uses local int id)
      branches = await db.organizationsDao.getFranchisees(commissary!.id);
      print('🔍 DEBUG: Franchisees found: ${branches.length}');
      for (final branch in branches) {
        print('   - ${branch.name} (parentCommissaryId: ${branch.parentCommissaryId})');
      }

      // Get users for each branch
      branchUsers = {};
      for (final branch in branches) {
        final users = await db.usersDao.getUsersByOrganization(branch.id);
        branchUsers[branch.id] = users;
        print('   - Branch ${branch.name}: ${users.length} users');
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('❌ Error loading branches: $e');
      setState(() => isLoading = false);
    }
  }

  /// Force sync and reload data - for debugging
  Future<void> forceSyncAndReload() async {
    setState(() => isLoading = true);
    print('🔄 Force syncing organizations and users...');
    
    try {
      await syncService.syncAll();
      print('✅ Sync complete, reloading data...');
      await loadData();
    } catch (e) {
      print('❌ Error during sync: $e');
      setState(() => isLoading = false);
    }
  }

  // ============================================================================
  // CREATE BRANCH
  // ============================================================================

  void showCreateBranchDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Branch',
                    style: TextStyle(
                      fontFamily: fontAll,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Branch Name *',
                      hintText: 'e.g., Chicken Joo - SM Mall',
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Branch name is required'),
                              ),
                            );
                            return;
                          }

                          await createBranch(
                            name: nameController.text.trim(),
                            address: addressController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                          );

                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createBranch({
    required String name,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      // SE_101: parentCommissaryId is int (local FK), cloudId is nullable Value
      await db.organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          name: name,
          type: 'franchisee',
          address: Value(address),
          phone: Value(phone),
          email: Value(email),
          parentCommissaryId: Value(commissary!.id),
          cloudId: Value(_uuid.v4()),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Branch "$name" created successfully')),
      );

      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create branch: $e')));
    }
  }

  // ============================================================================
  // CREATE BRANCH ADMIN
  // ============================================================================

  void showCreateBranchAdminDialog({Organization? preselectedBranch}) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    Organization? selectedBranch = preselectedBranch;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Branch Admin',
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Branch selector
                    DropdownButtonFormField<Organization>(
                      value: selectedBranch,
                      decoration: const InputDecoration(
                        labelText: 'Select Branch *',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: branches.map((branch) {
                        return DropdownMenuItem(
                          value: branch,
                          child: Text(branch.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedBranch = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password *',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This admin will only be able to access data for their assigned branch.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            if (selectedBranch == null ||
                                nameController.text.trim().isEmpty ||
                                emailController.text.trim().isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill all required fields',
                                  ),
                                ),
                              );
                              return;
                            }

                            await createBranchAdmin(
                              branch: selectedBranch!,
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                              password: passwordController.text,
                            );

                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createBranchAdmin({
    required Organization branch,
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      // Get Branch Admin role
      final branchAdminRole = await db.rolesDao.getRoleByName('Branch Admin');
      if (branchAdminRole == null) {
        throw Exception('Branch Admin role not found');
      }

      // 1. Create Supabase Auth user first (required for SE101 login)
      final SupabaseAuthService auth = authService;
      final authUserId = await auth.createBranchAdminAuthUser(
        email: email,
        password: password,
        organizationCloudId: branch.cloudId ?? '',
      );

      if (authUserId == null) {
        throw Exception('Failed to create authentication account');
      }

      // 2. Create user in local database
      // SE_101: uses 'password' field (not passwordHash), no authUserId field,
      // store Supabase auth UID in cloudId
      try {
        final userId = await db
            .into(db.users)
            .insert(
              UsersCompanion.insert(
                username: name,
                email: email,
                password: hashPassword(password),
                organizationId: branch.id,
                roleId: branchAdminRole.id,
                phone: Value(phone),
                fullName: Value(name),
                cloudId: Value(authUserId),
              ),
            );
        
        print('✅ User created locally with ID: $userId');
      } catch (e) {
        print('❌ Failed to create user locally: $e');
        rethrow;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Branch admin "$name" created for ${branch.name}'),
        ),
      );

      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create admin: $e')));
    }
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  Future<void> deleteBranch(Organization branch) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${branch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.organizationsDao.deactivateOrganization(branch.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${branch.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting branch: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> deleteAdmin(User user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete "${user.username}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.usersDao.deactivateUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.username} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting admin: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ============================================================================
  // BUILD ADMIN ROWS
  // ============================================================================

  Future<List<Map<String, dynamic>>> buildAdminRows() async {
    final rows = <Map<String, dynamic>>[];
    for (final branch in branches) {
      final users = branchUsers[branch.id] ?? [];
      for (final user in users) {
        rows.add({'user': user, 'branch': branch});
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return BranchesPageMobile(state: this);
    }
    return BranchesPageDesktop(state: this);
  }
}
