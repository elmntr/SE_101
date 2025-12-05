import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/database/app_database.dart';

class DatabaseViewerPage extends StatefulWidget {
  final AppDatabase db;
  const DatabaseViewerPage({super.key, required this.db});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  List<UserWithRole> users = [];
  List<Item> items = [];
  List<Role> roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    final db = widget.db;

    // Load users with roles
    final userList = await db.usersDao.getUsersWithRoles();

    // Load items
    final itemList = await db.itemsDao.getAllItems();

    // Load roles
    final roleList = await db.rolesDao.getAllRoles();

    if (!mounted) return;

    setState(() {
      users = userList;
      items = itemList;
      roles = roleList;
      _isLoading = false;
    });
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Database Viewer")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Users",
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final u = users[index];
                  return ListTile(
                    title: Text(u.displayName),
                    subtitle: Text(u.role?.name ?? "No role"),
                  );
                },
              ),
            ),
            _buildSection(
              "Items",
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text("Stock: ${item.stock}"),
                  );
                },
              ),
            ),
            _buildSection(
              "Roles",
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return ListTile(
                    title: Text(role.name),
                    subtitle: Text(
                        "Can view inventory: ${role.canViewInventory}, Can manage employees: ${role.canManageRoles ?? false}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
