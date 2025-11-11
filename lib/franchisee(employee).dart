import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/designconstants.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key}) : super(key: key);

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<Map<String, dynamic>> employees= [];
  List<Map<String, dynamic>> roles = [];
  List<String> accessTitles = [
      "View Inventory",
      "Add Inventory",
      "Edit Inventory",
      "Delete Inventory",
      "Manage Employees",
      "Manage Roles",
      "View Reports",
      "Settings",
    ];

  int selectedTab = 0; // 0 = Items, 1 = Categories

  //Add Employee Popup
  void _createEmployee() {
    final TextEditingController employeeName = TextEditingController();
    final TextEditingController employeeEmail = TextEditingController();
    final TextEditingController employeePN = TextEditingController();
    String? selectedEmployee;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Employee", style: TextStyle( fontFamily: fontAll , fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Name"), controller: employeeName),
            TextField(decoration: const InputDecoration(labelText: "Email"), controller: employeeEmail),
            TextField(decoration: const InputDecoration(labelText: "Phone"), controller: employeePN,),
            DropdownButtonFormField<String>(
                  value: selectedEmployee,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: roles
                      .map((role) => DropdownMenuItem<String>(
                            value: role["roleName"],
                            child: Text(role["roleName"]),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedEmployee = value;
                  },
                ),
            ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (employeeName.text.isEmpty) return;
              _saveEmployee({
                "employeeName": employeeName.text,
                "employeeEmail": employeeEmail.text,
                "employeePN": int.tryParse(employeePN.text),
                "employeeRole": selectedEmployee,
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Save New Employee
  void _saveEmployee(Map<String, dynamic> newItem) {
    setState(() {
      employees.add(newItem);
    });
  }

  //Add Role Popup
  void _createRoleDialog() {
    final TextEditingController roleName = TextEditingController();
    List<bool> access = List.generate(accessTitles.length, (_) => false);

    showDialog(
      context: context,
      barrierDismissible: true, // allow tapping outside to cancel
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(25),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Role",
                      style: TextStyle(
                        fontFamily: fontAll,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 25),
                  TextField(
                    controller: roleName,
                    decoration: InputDecoration(
                      labelText: "Role Name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("Access",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: fontAll,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 50,
                    runSpacing: 10,
                    children: List.generate(access.length, (i) {
                      return SizedBox(
                        width: 160,
                        child: Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.red,
                              value: access[i],
                              onChanged: (value) {
                                setStateDialog(() {
                                  access[i] = value ?? false;
                                });
                              },
                            ),
                            Flexible(child: Text(accessTitles[i])),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel button
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (roleName.text.isEmpty) return;
              _saveRole({
                "roleName": roleName.text,
                "access": List<bool>.from(access),
              });
              Navigator.pop(context);
            },
            child: const Text(
              "SUBMIT",
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontAll,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Save New Role
  void _saveRole(Map<String, dynamic> newItem) {
    setState(() {
      roles.add(newItem);
    });
  }

  //Empty Tab Widget
  Widget _emptyTables(String message, int tab) {

    selectedTab = tab;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 15),
          if (tab == 0)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
              onPressed: _createEmployee,
            )
          else
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.red, size: 55),
              onPressed: _createRoleDialog,
            ),
        ],
      ),
    );
  }

  // Employee Table Widget
  Widget _buildEmployeeTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Employee Name", style: TextStyle(fontFamily: fontAll , color: Colors.red))),
          DataColumn(label: Text("Email", style: TextStyle(fontFamily: fontAll , color: Colors.red))),
          DataColumn(label: Text("Phone Number", style: TextStyle(fontFamily: fontAll , color: Colors.red))),
          DataColumn(label: Text("Role", style: TextStyle(fontFamily: fontAll , color: Colors.red))),
          DataColumn(label: Text('')),
        ],
        rows: List.generate(employees.length, (i) {
          final employee = employees[i];
          return DataRow(cells: [
            DataCell(Text(employee["employeeName"].toString())),
            DataCell(Text(employee["employeeEmail"].toString())),
            DataCell(Text(employee["employeePN"].toString())),
            DataCell(Text(employee["employeeRole"].toString())),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEmployee(i),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  // Delete Employee
  void _deleteEmployee(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Employee", style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this employee?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                employees.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Role Table Widget
Widget _buildRoleTable() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,   // ✅ row must fill table width
          ),
          child: DataTable(
            columnSpacing: 40,
            dataRowMaxHeight: double.infinity,
            columns: const [
              DataColumn(
                label: Text("Role Name", style: TextStyle(fontFamily: fontAll, color: Colors.red)),
              ),
              DataColumn(
                label: Text("Access", style: TextStyle(fontFamily: fontAll, color: Colors.red)),
              ),
              DataColumn(
                label: Text("Employees", style: TextStyle(fontFamily: fontAll, color: Colors.red)),
              ),
              DataColumn(label: Text("")),
            ],
            rows: List.generate(roles.length, (i) {
              final role = roles[i];

              List<Widget> accessWidgets = [];
              for (int j = 0; j < accessTitles.length; j++) {
                if (role["access"][j]) {
                  accessWidgets.add(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6, bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(accessTitles[j], style: const TextStyle(fontSize: 12)),
                    ),
                  );
                }
              }

              return DataRow(
                cells: [
                  DataCell(Text(role["roleName"])),
                  DataCell(
                    SizedBox(
                      width: 400,
                      child: Wrap(children: accessWidgets),
                    ),
                  ),
                  DataCell(Text("0")),
                  DataCell(
                    SizedBox(
                      width: double.infinity,    // ✅ forces row to stretch horizontally
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRole(i),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    },
  );
}


  
  // Delete Role
  void _deleteRole(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Role", style: TextStyle(fontFamily: fontAll, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this role?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                roles.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// Tab Builder
  Widget _buildTab(String label, int index) {
    bool active = selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //  Header
            Row(
              children: [
                const Text("Items", style: TextStyle(fontSize: 30, fontFamily: fontAll)),
                const SizedBox(width: 16),

                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tabs + Content
            Expanded(
              child: Column(
                children: [
                  // Raised Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab("Employee", 0),
                        _buildTab("Roles", 1),
                      ],
                    ),
                  ),

                  // White content box
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: selectedTab == 0 
                          ? (employees.isEmpty ?_emptyTables("You can add your employees here.", selectedTab) : _buildEmployeeTable())
                          : (roles.isEmpty ?_emptyTables("You can add categories here to organize your items.", selectedTab) : _buildRoleTable() ),
              
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:  (selectedTab == 0 && employees.isNotEmpty) || (selectedTab == 1 && roles.isNotEmpty) 
      ? Container(
          margin: const EdgeInsets.only(bottom: 20), // ✅ overlap without pushing content
          child: FloatingActionButton(
            backgroundColor: Colors.red[700],
            onPressed: selectedTab == 0 ? _createEmployee : _createRoleDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        )
      : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }

  
}