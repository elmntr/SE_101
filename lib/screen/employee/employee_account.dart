import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import '../../../database/app_database.dart'; // your Drift DB
import 'package:chickenjoo_inventory/app_globals.dart';

class EmployeeAccountPage extends StatefulWidget {
  final User user; // pass the signed-in user
  final Role role; // pass the user's role

  const EmployeeAccountPage({
    super.key,
    required this.user,
    required this.role,
  });

  @override
  State<EmployeeAccountPage> createState() => _EmployeeAccountPageState();
}

class _EmployeeAccountPageState extends State<EmployeeAccountPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController roleController;

  List<String> roleAccessToShow = [];

  late AppDatabase db;

  @override
  void initState() {
    super.initState();
    db = database;

    // Initialize controllers with DB values
    nameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone ?? "");
    roleController = TextEditingController(text: widget.role.name);

    // Map role access flags to human-readable strings
    roleAccessToShow = _getRoleAccessList(widget.role);
  }

  List<String> _getRoleAccessList(Role role) {
    final List<String> access = [];
    if (role.canViewInventory) access.add("View Inventory");
    if (role.canAddInventory) access.add("Add Inventory");
    if (role.canEditInventory) access.add("Edit Inventory");
    if (role.canDeleteInventory) access.add("Delete Inventory");
    if (role.canManageEmployees) access.add("Manage Employees");
    if (role.canManageRoles) access.add("Manage Roles");
    if (role.canViewReports) access.add("View Reports");
    if (role.canAccessSettings) access.add("Settings");
    return access;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PHONE UI
    if (AppLayout.isDesktop(context) == false) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Account",
                  style: TextStyle(fontSize: 26, fontFamily: fontAll),
                ),
                const SizedBox(height: 18),
                _infoField("Name", nameController),
                const SizedBox(height: 14),
                _infoField("Email", emailController),
                const SizedBox(height: 14),
                _infoField("Phone", phoneController),
                const SizedBox(height: 14),
                _infoField("Role", roleController),
                const SizedBox(height: 22),
                const Text(
                  "Role Access",
                  style: TextStyle(fontSize: 18, fontFamily: fontAll),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: roleAccessToShow
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [const SizedBox(width: 8), Text(e)],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ DESKTOP UI
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _infoField("Name:", nameController),
                    const SizedBox(height: 20),
                    _infoField("Email:", emailController),
                    const SizedBox(height: 20),
                    _infoField("Phone:", phoneController),
                    const SizedBox(height: 20),
                    _infoField("Role:", roleController),
                    const SizedBox(height: 30),
                    const Text(
                      "Role Access:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontAll,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 120,
                        maxHeight: 250,
                      ),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: roleAccessToShow.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(roleAccessToShow[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              color: Colors.red,
              margin: const EdgeInsets.symmetric(horizontal: 25),
            ),
            const Expanded(flex: 5, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontFamily: fontAll)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true, // make it read-only for viewing
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
