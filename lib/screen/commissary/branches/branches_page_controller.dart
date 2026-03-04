// lib/screens/branches/branches_page_controller.dart
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/services/supabase_auth_service.dart';
import 'package:chickenjoo_inventory/database/app_database.dart' show hashPassword;

class BranchesPageController {
  final AppDatabase db;
  final VoidCallback onStateChanged;

  List<Organization> branches = [];
  Map<int, List<User>> branchUsers = {};
  Organization? commissary;
  bool isLoading = true;
  int selectedTab = 0; // 0 = Branches, 1 = Branch Admins

  // Search functionality
  String searchQuery = '';

  // Sort functionality
  String branchSortOrder = 'nameAsc';
  String adminSortOrder = 'nameAsc';
  bool showActiveOnly = false;

  // Branch filter for admins tab
  int? selectedBranchFilter; // null means "All Branches"

  final _uuid = const Uuid();

  BranchesPageController({
    required this.db,
    required this.onStateChanged,
  });

  void setSelectedTab(int index) {
    selectedTab = index;
    onStateChanged();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    onStateChanged();
  }

  void setBranchSortOrder(String order) {
    branchSortOrder = order;
    onStateChanged();
  }

  void setAdminSortOrder(String order) {
    adminSortOrder = order;
    onStateChanged();
  }

  void toggleShowActiveOnly(bool value) {
    showActiveOnly = value;
    onStateChanged();
  }

  void setBranchFilter(int branchId) {
    // -1 means "All Branches"
    selectedBranchFilter = branchId == -1 ? null : branchId;
    onStateChanged();
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

  Future<void> loadData() async {
    isLoading = true;
    onStateChanged();

    try {
      // Debug: Get all organizations first
      final allOrgs = await db.organizationsDao.getAllOrganizations();
      print('ðŸ” DEBUG: Total organizations in local DB: ${allOrgs.length}');
      for (final org in allOrgs) {
        print(
          '   - [${org.type}] ${org.name} (cloudId: ${org.cloudId}, parentCommissaryId: ${org.parentCommissaryId})',
        );
      }

      // Get commissary
      commissary = await db.organizationsDao.getCommissary();
      if (commissary == null) {
        print('âš ï¸ No commissary found');
        isLoading = false;
        onStateChanged();
        return;
      }
      print(
        'âœ… Commissary found: ${commissary!.name} (cloudId: ${commissary!.cloudId})',
      );

      // Get all franchisees under this commissary
      branches = await db.organizationsDao.getFranchisees(commissary!.id);
      print('ðŸ” DEBUG: Franchisees found: ${branches.length}');
      for (final branch in branches) {
        print(
          '   - ${branch.name} (parentCommissaryId: ${branch.parentCommissaryId})',
        );
      }

      // Get users for each branch
      branchUsers = {};
      for (final branch in branches) {
        final users = await db.usersDao.getUsersByOrganization(branch.id);
        branchUsers[branch.id] = users;
        print('   - Branch ${branch.name}: ${users.length} users');
      }

      isLoading = false;
      onStateChanged();
    } catch (e) {
      print('âŒ Error loading branches: $e');
      isLoading = false;
      onStateChanged();
    }
  }

  /// Force sync and reload data - for debugging
  Future<void> forceSyncAndReload() async {
    isLoading = true;
    onStateChanged();
    print('ðŸ”„ Force syncing organizations and users...');

    try {
      await syncService.syncAll();
      print('âœ… Sync complete, reloading data...');
      await loadData();
    } catch (e) {
      print('âŒ Error during sync: $e');
      isLoading = false;
      onStateChanged();
    }
  }

  Future<void> createBranch({
    required String name,
    required BuildContext context,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      await db.organizationsDao.insertOrganization(
        OrganizationsCompanion.insert(
          cloudId: Value(_uuid.v4()),
          name: name,
          type: 'franchisee',
          address: Value(address),
          phone: Value(phone),
          email: Value(email),
          parentCommissaryId: Value(commissary!.id),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Branch "$name" created successfully')),
        );
      }

      await loadData();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create branch: $e')),
        );
      }
    }
  }

  Future<void> createBranchAdmin({
    required Organization branch,
    required String name,
    required String email,
    required String password,
    required BuildContext context,
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

      // 2. Create user in local database with cloud_id = auth_user_id
      try {
        final userId = await db.into(db.users).insert(
              UsersCompanion.insert(
                username: name,
                email: email,
                password: hashPassword(password),
                phone: Value(phone),
                organizationId: branch.id,
                roleId: branchAdminRole.id,
                cloudId: Value(authUserId),
              ),
            );

        print('âœ… User created locally with ID: $userId');
      } catch (e) {
        print('âŒ Failed to create user locally: $e');
        rethrow;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Branch admin "$name" created for ${branch.name}'),
          ),
        );
      }

      await loadData();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create admin: $e')),
        );
      }
    }
  }

  Future<bool> confirmDeleteBranch(
    Organization branch,
    BuildContext context,
  ) async {
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

    return shouldDelete ?? false;
  }

  Future<void> deleteBranch(Organization branch, BuildContext context) async {
    try {
      // Soft delete the branch (deactivate)
      await db.organizationsDao.deactivateOrganization(branch.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${branch.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await loadData();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting branch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> confirmDeleteAdmin(User user, BuildContext context) async {
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

    return shouldDelete ?? false;
  }

  Future<void> deleteAdmin(User user, BuildContext context) async {
    try {
      // Soft delete the admin user (deactivate)
      await db.usersDao.deactivateUser(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.username} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await loadData();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting admin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> buildAdminRows() async {
    final rows = <Map<String, dynamic>>[];
    for (final branch in branches) {
      // Apply branch filter
      if (selectedBranchFilter != null && branch.id != selectedBranchFilter) {
        continue;
      }
      final users = branchUsers[branch.id] ?? [];
      for (final user in users) {
        // Apply search filter
        if (searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          final matchesSearch =
              user.username.toLowerCase().contains(searchLower) ||
                  user.email.toLowerCase().contains(searchLower) ||
                  (user.phone?.toLowerCase().contains(searchLower) ?? false) ||
                  branch.name.toLowerCase().contains(searchLower);
          if (!matchesSearch) continue;
        }
        rows.add({'user': user, 'branch': branch});
      }
    }
    return rows;
  }
}
