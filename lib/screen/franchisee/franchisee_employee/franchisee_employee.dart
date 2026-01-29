import 'package:chickenjoo_inventory/tables/tables.dart';
import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/app_globals.dart';
import 'franchisee_employee_mobile.dart';
import 'franchisee_employee_desktop.dart';
import 'franchisee_employee_controller.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => EmployeePageState();
}

class EmployeePageState extends State<EmployeePage> {
  late AppDatabase db;
  late FranchiseeEmployeeController controller;

  // Expose controller properties for UI access
  List<User> get users => controller.users;
  List<Role> get roles => controller.roles;
  int? get currentOrganizationId => controller.currentOrganizationId;

  EmployeeSort get currentEmployeeSort => controller.currentEmployeeSort;
  RoleSort get currentRoleSort => controller.currentRoleSort;

  int? get selectedRoleFilter => controller.selectedRoleFilter;
  set selectedRoleFilter(int? value) => controller.selectedRoleFilter = value;

  static const int allRolesKey = FranchiseeEmployeeController.allRolesKey;

  List<String> get accessTitles => controller.accessTitles;
  List<User> get filteredUsers => controller.filteredUsers;

  int get selectedTab => controller.selectedTab;
  set selectedTab(int value) => controller.selectedTab = value;

  bool get isLoading => controller.isLoading;

  @override
  void initState() {
    super.initState();
    db = database;
    controller = FranchiseeEmployeeController(
      db: db,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      showSnackBar: (message) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
    controller.initializeData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void createEmployee() {
    controller.createEmployee(context);
  }

  void applyEmployeeSort(EmployeeSort sort) {
    controller.applyEmployeeSort(sort);
  }

  void applyRoleSort(RoleSort sort) {
    controller.applyRoleSort(sort);
  }

  void createRoleDialog() {
    controller.createRoleDialog(context);
  }

  RolesCompanion buildRoleCompanion(
    String name,
    String description,
    List<bool> access,
  ) {
    return controller.buildRoleCompanion(name, description, access);
  }

  List<bool> flagsFromRole(Role role) {
    return controller.flagsFromRole(role);
  }

  void deleteEmployee(User user) {
    controller.deleteEmployee(context, user);
  }

  void deleteRole(Role role, int assignedUsers) {
    controller.deleteRole(context, role, assignedUsers);
  }

  Future<void> assignRole(User user, int roleId) async {
    await controller.assignRole(user, roleId);
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context) == false) {
      return EmployeePageMobile(state: this);
    }
    return EmployeePageDesktop(state: this);
  }
}
