import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';
import 'package:chickenjoo_inventory/tables/tables.dart';
import 'franchisee_employee.dart';

class EmployeePageMobile extends StatelessWidget {
  final EmployeePageState state;

  const EmployeePageMobile({super.key, required this.state});

  Widget buildTab(String label, int index) {
    bool active = state.selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setState(() => state.selectedTab = index),
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
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Employees",
                        style: TextStyle(fontSize: 26, fontFamily: fontAll),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Search...",
                              icon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: PopupMenuButton<int>(
                              tooltip: "Filter by role",
                              onSelected: (value) {
                                state.setState(() {
                                  state.selectedRoleFilter = value == EmployeePageState.allRolesKey
                                      ? null
                                      : value;
                                });
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<int>(
                                  value: EmployeePageState.allRolesKey,
                                  child: Text("All Roles"),
                                ),
                                const PopupMenuDivider(),
                                ...state.roles.map(
                                  (role) => PopupMenuItem<int>(
                                    value: role.id,
                                    child: Text(role.name),
                                  ),
                                ),
                              ],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.selectedRoleFilter == null
                                        ? "All Roles"
                                        : state.roles
                                              .firstWhere(
                                                (r) =>
                                                    r.id ==
                                                    state.selectedRoleFilter,
                                              )
                                              .name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.filter_list, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<EmployeeSort>(
                            icon: const Icon(
                              Icons.sort,
                              size: 32,
                              color: Colors.black87,
                            ),
                            onSelected: state.applyEmployeeSort,
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: EmployeeSort(
                                  EmployeeSortField.date,
                                  SortOrder.desc,
                                ),
                                child: Text("Date Added (Newest)"),
                              ),
                              PopupMenuItem(
                                value: EmployeeSort(
                                  EmployeeSortField.date,
                                  SortOrder.asc,
                                ),
                                child: Text("Date Added (Oldest)"),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: EmployeeSort(
                                  EmployeeSortField.name,
                                  SortOrder.desc,
                                ),
                                child: Text("Name (A–Z)"),
                              ),
                              PopupMenuItem(
                                value: EmployeeSort(
                                  EmployeeSortField.name,
                                  SortOrder.asc,
                                ),
                                child: Text("Name (Z–A)"),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: EmployeeSort(
                                  EmployeeSortField.email,
                                  SortOrder.desc,
                                ),
                                child: Text("Email (A–Z)"),
                              ),
                              PopupMenuItem(
                                value: EmployeeSort(
                                  EmployeeSortField.email,
                                  SortOrder.asc,
                                ),
                                child: Text("Email (Z–A)"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    buildTab("Employees", 0),
                    buildTab("Roles", 1),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.selectedTab == 0
                      ? (state.filteredUsers.isEmpty
                            ? state.selectedRoleFilter == null
                                  ? emptyTables(
                                      message: "No employees found",
                                      onAddPressed: state.createEmployee,
                                      buttonType: EmptyButtonType.icon,
                                      buttonText: null,
                                    )
                                  : emptyTables(
                                      message:
                                          "No employees with selected role",
                                      onAddPressed: state.createEmployee,
                                      buttonType: EmptyButtonType.icon,
                                      buttonText: null,
                                    )
                            : buildUniversalTable(
                                headers: [
                                  "Name",
                                  "Email",
                                  "Phone",
                                  "Role",
                                  "",
                                ],
                                rows: state.filteredUsers.map((user) {
                                  return [
                                    user.username,
                                    user.email,
                                    user.phone ?? '-',
                                    SizedBox(
                                      child: state.roles.isEmpty
                                          ? const Text(
                                              'No roles',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            )
                                          : DropdownButton<int>(
                                              isDense: true,
                                              isExpanded: true,
                                              value: user.roleId,
                                              items: state.roles
                                                  .map(
                                                    (role) =>
                                                        DropdownMenuItem<int>(
                                                          value: role.id,
                                                          child: Text(
                                                            role.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                  )
                                                  .toList(),
                                              onChanged:
                                                  (int? newRoleId) async {
                                                    if (newRoleId == null)
                                                      return;
                                                    await state.assignRole(
                                                      user,
                                                      newRoleId,
                                                    );
                                                  },
                                            ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => state.deleteEmployee(user),
                                    ),
                                  ];
                                }).toList(),
                                
                          smallHeaderWidth: 20,
                          largeHeaderWidth: 120,
                          ))
                      : (state.roles.isEmpty
                            ? emptyTables(
                                message: "No roles found",
                                onAddPressed: state.createRoleDialog,
                                buttonType: EmptyButtonType.icon,
                                buttonText: null,
                              )
                            : buildUniversalTable(
                                headers: [
                                  "Role Name",
                                  "Access",
                                  "Employees",
                                  "",
                                ],
                                rows: state.roles.map((role) {
                                  final accessWidgets = <Widget>[];
                                  final accessFlags = state.flagsFromRole(role);
                                  for (
                                    int j = 0;
                                    j < state.accessTitles.length;
                                    j++
                                  ) {
                                    if (accessFlags[j]) {
                                      accessWidgets.add(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            state.accessTitles[j],
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  final userCount = state.users
                                      .where((user) => user.roleId == role.id)
                                      .length;

                                  return [
                                    role.name,
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: Wrap(children: accessWidgets),
                                    ),
                                    userCount.toString(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          state.deleteRole(role, userCount),
                                    ),
                                  ];
                                }).toList(),
                                
                          smallHeaderWidth: 20,
                          largeHeaderWidth: 120,
                          )),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          (!state.isLoading &&
              ((state.selectedTab == 0 && state.filteredUsers.isNotEmpty) ||
                  (state.selectedTab == 1 && state.roles.isNotEmpty)))
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                backgroundColor: Colors.red[700],
                onPressed: state.selectedTab == 0
                    ? state.createEmployee
                    : state.createRoleDialog,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}