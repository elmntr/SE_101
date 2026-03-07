// lib/screens/branches/branches_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/utils/phone_formatter.dart';
import 'branches_page_desktop.dart';
import 'branches_page_mobile.dart';
import 'branches_page_controller.dart';

/// Branches Page - Manage franchisee branches and their admins
/// Commissary can:
/// - Create new branches (franchisees)
/// - Create branch admin users scoped to a specific branch
/// - View all branches and their status
class BranchesPage extends StatefulWidget {
  final int initialTab;

  const BranchesPage({super.key, this.initialTab = 0});

  @override
  State<BranchesPage> createState() => BranchesPageState();
}

class BranchesPageState extends State<BranchesPage> {
  late AppDatabase db;
  late BranchesPageController controller;
  final TextEditingController searchController = TextEditingController();

  // Expose controller properties for UI access
  List<Organization> get branches => controller.branches;
  Map<int, List<User>> get branchUsers => controller.branchUsers;
  Organization? get commissary => controller.commissary;
  bool get isLoading => controller.isLoading;
  int get selectedTab => controller.selectedTab;
  String get searchQuery => controller.searchQuery;
  String get branchSortOrder => controller.branchSortOrder;
  String get adminSortOrder => controller.adminSortOrder;
  bool get showActiveOnly => controller.showActiveOnly;
  int? get selectedBranchFilter => controller.selectedBranchFilter;
  List<Organization> get filteredBranches => controller.filteredBranches;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = BranchesPageController(
      db: db,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    controller.selectedTab = widget.initialTab;
    controller.loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void setSelectedTab(int index) => controller.setSelectedTab(index);
  void onSearchChanged(String query) => controller.onSearchChanged(query);
  void setBranchSortOrder(String order) => controller.setBranchSortOrder(order);
  void setAdminSortOrder(String order) => controller.setAdminSortOrder(order);
  void toggleShowActiveOnly(bool value) => controller.toggleShowActiveOnly(value);
  void setBranchFilter(int branchId) => controller.setBranchFilter(branchId);
  List<User> getFilteredUsersForBranch(int branchId) =>
      controller.getFilteredUsersForBranch(branchId);
  Future<void> loadData() => controller.loadData();
  Future<void> forceSyncAndReload() => controller.forceSyncAndReload();
  Future<List<Map<String, dynamic>>> buildAdminRows() =>
      controller.buildAdminRows();

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
                      hintText: '09XX XXX XXXX',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                      PhilippinePhoneFormatter(),
                    ],
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

                          await controller.createBranch(
                            name: nameController.text.trim(),
                            context: context,
                            address: addressController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                          );

                          if (mounted) {
                            Navigator.pop(context);
                          }
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
                        hintText: '09XX XXX XXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                        PhilippinePhoneFormatter(),
                      ],
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

                            await controller.createBranchAdmin(
                              branch: selectedBranch!,
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                              password: passwordController.text,
                              context: context,
                            );

                            if (mounted) {
                              Navigator.pop(context);
                            }
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

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  Future<void> deleteBranch(Organization branch) async {
    final shouldDelete = await controller.confirmDeleteBranch(branch, context);

    if (shouldDelete) {
      await controller.deleteBranch(branch, context);
    }
  }

  Future<void> deleteAdmin(User user) async {
    final shouldDelete = await controller.confirmDeleteAdmin(user, context);

    if (shouldDelete) {
      await controller.deleteAdmin(user, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return BranchesPageMobile(state: this);
    }
    return BranchesPageDesktop(state: this);
  }
}
