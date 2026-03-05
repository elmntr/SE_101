import 'package:flutter/material.dart';
import 'package:chickenjoo_inventory/services/search_service.dart';
import 'package:chickenjoo_inventory/design_constants.dart';
import 'package:chickenjoo_inventory/utils/tables.dart';
import 'package:chickenjoo_inventory/widgets/filter_widgets.dart';
import 'branches_page.dart';

class BranchesPageDesktop extends StatelessWidget {
  final BranchesPageState state;

  const BranchesPageDesktop({super.key, required this.state});

  Widget buildTab(String label, int index) {
    bool active = state.selectedTab == index;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.setSelectedTab(index),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Branches',
                  style: TextStyle(fontSize: 30, fontFamily: fontAll),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UniversalSearchBar(
                    controller: state.searchController,
                    onSearch: state.onSearchChanged,
                    hintText: state.selectedTab == 0
                        ? 'Search branches...'
                        : 'Search admins...',
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                // Sort button for branches tab
                if (state.selectedTab == 0)
                  UniversalFilterButton<String>(
                    currentValue: state.branchSortOrder,
                    onSelected: state.setBranchSortOrder,
                    tooltip: 'Sort branches',
                    options: const [
                      FilterOption.header('SORT BY NAME'),
                      FilterOption(value: 'nameAsc', label: 'Name (Aâ€“Z)', icon: Icons.sort_by_alpha),
                      FilterOption(value: 'nameDesc', label: 'Name (Zâ€“A)', icon: Icons.sort_by_alpha),
                      FilterOption.divider(),
                      FilterOption.header('SORT BY STATUS'),
                      FilterOption(value: 'activeFirst', label: 'Active First', icon: Icons.check_circle),
                      FilterOption(value: 'inactiveFirst', label: 'Inactive First', icon: Icons.cancel),
                      FilterOption.divider(),
                      FilterOption.header('SORT BY DATE'),
                      FilterOption(value: 'newestFirst', label: 'Newest First', icon: Icons.schedule),
                      FilterOption(value: 'oldestFirst', label: 'Oldest First', icon: Icons.history),
                    ],
                  ),
                // Active only toggle
                if (state.selectedTab == 0)
                  IconButton(
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 28,
                      color: state.showActiveOnly ? Colors.green : null,
                    ),
                    tooltip: 'Show active only',
                    onPressed: () => state.toggleShowActiveOnly(!state.showActiveOnly),
                  ),
                // Branch filter for admins tab
                if (state.selectedTab == 1)
                  PopupMenuButton<int>(
                    icon: Icon(
                      Icons.filter_list,
                      size: 28,
                      color: state.selectedBranchFilter != null ? Colors.blue : null,
                    ),
                    tooltip: 'Filter by branch',
                    onSelected: state.setBranchFilter,
                    itemBuilder: (context) {
                      final items = <PopupMenuEntry<int>>[];
                      items.add(
                        PopupMenuItem<int>(
                          value: -1,
                          child: Row(
                            children: [
                              const Icon(Icons.store, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'All Branches',
                                style: TextStyle(
                                  fontWeight: state.selectedBranchFilter == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (state.selectedBranchFilter == null) ...[
                                const Spacer(),
                                Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                              ],
                            ],
                          ),
                        ),
                      );
                      items.add(const PopupMenuDivider());
                      for (final branch in state.branches) {
                        final isSelected = state.selectedBranchFilter == branch.id;
                        items.add(
                          PopupMenuItem<int>(
                            value: branch.id,
                            child: Row(
                              children: [
                                const Icon(Icons.storefront, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    branch.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor),
                              ],
                            ),
                          ),
                        );
                      }
                      return items;
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.sync, size: 35),
                  tooltip: 'Force Sync',
                  onPressed: () => state.forceSyncAndReload(),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        buildTab('Branch List', 0),
                        buildTab('Branch Admins', 1),
                      ],
                    ),
                  ),
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
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state.selectedTab == 0
                          ? _buildBranchesTab()
                          : _buildAdminsTab(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (!state.isLoading &&
              ((state.selectedTab == 0 && state.branches.isNotEmpty) ||
                  (state.selectedTab == 1 && state.branches.isNotEmpty)))
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                backgroundColor: Colors.red[700],
                onPressed: state.selectedTab == 0
                    ? state.showCreateBranchDialog
                    : state.showCreateBranchAdminDialog,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBranchesTab() {
    if (state.branches.isEmpty) {
      return emptyTables(
        message: 'You can manage your branches here.',
        onAddPressed: state.showCreateBranchDialog,
        buttonType: EmptyButtonType.icon,
        buttonText: null,
      );
    }

    final filteredBranches = state.filteredBranches;
    if (filteredBranches.isEmpty) {
      return const Center(
        child: Text(
          'No branches match your search',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return buildUniversalTable(
      headers: [
        'Branch Name',
        'Address',
        'Phone',
        'Email',
        'Users',
        'Status',
        '',
      ],
      rows: filteredBranches.map((branch) {
        final users = state.branchUsers[branch.id] ?? [];
        return [
          Text(branch.name),
          Text(branch.address ?? ''),
          Text(branch.phone ?? ''),
          Text(branch.email ?? ''),
          Text('${users.length} users'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: branch.isActive
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              branch.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: branch.isActive ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add, size: 18),
                tooltip: 'Add Admin',
                onPressed: () => state.showCreateBranchAdminDialog(
                  preselectedBranch: branch,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                tooltip: 'Delete',
                onPressed: () => state.deleteBranch(branch),
              ),
            ],
          ),
        ];
      }).toList(),
      smallHeaderWidth: 20,
      largeHeaderWidth: 60,
    );
  }

  Widget _buildAdminsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: state.buildAdminRows(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final admins = snapshot.data!;

        if (admins.isEmpty) {
          return emptyTables(
            message: state.branches.isEmpty
                ? 'Create a branch first, then add admins.'
                : 'You can add branch admins here.',
            onAddPressed: state.branches.isEmpty
                ? state.showCreateBranchDialog
                : state.showCreateBranchAdminDialog,
            buttonType: EmptyButtonType.icon,
            buttonText: null,
          );
        }

        return buildUniversalTable(
          headers: ['Name', 'Email', 'Phone', 'Branch', 'Status', ''],
          rows: admins.map((data) {
            final user = data['user'];
            final branch = data['branch'];
            return [
              Text(user.username),
              Text(user.email),
              Text(user.phone ?? ''),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  branch.name,
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                tooltip: 'Delete',
                onPressed: () => state.deleteAdmin(user),
              ),
            ];
          }).toList(),
          smallHeaderWidth: 20,
          largeHeaderWidth: 80,
        );
      },
    );
  }
}
