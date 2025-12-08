import 'package:flutter/widgets.dart';

/// Enum representing sort order: ascending or descending
enum SortOrder { 
  asc, // Ascending order (e.g., A→Z, 0→9)
  desc // Descending order (e.g., Z→A, 9→0)
}

/// Fields available for sorting Items
enum ItemSortField { 
  name,    // Sort by item name
  stock,   // Sort by stock quantity
  sale,    // Sort by number of items sold
  spoilage,// Sort by number of spoiled items
  date     // Sort by last updated date
}

/// Fields available for sorting Categories
enum CategorySortField { 
  name,  // Sort by category name
  items, // Sort by number of items in category
  date   // Sort by date created/modified
}

/// Fields available for sorting Employees
enum EmployeeSortField { 
  name,  // Sort by employee name
  email, // Sort by employee email
  date   // Sort by date created/added
}
/// Fields available for sorting Roles
enum RoleSortField { 
  name,      // Sort by role name
  employees, // Sort by number of employees in role
  date       // Sort by date created/modified
}

/// Fields available for sorting Review Changes
enum ReviewSortField { 
  employee, // Sort by employee name
  role,     // Sort by role name
  changes   // Sort by number of changes
}

/// Class representing an Item sort option
class ItemSort {
  final ItemSortField field; // Field to sort by
  final SortOrder order;     // Sort order (asc or desc)
  const ItemSort(this.field, this.order);
}

/// Class representing a Category sort option
class CategorySort {
  final CategorySortField field; // Field to sort by
  final SortOrder order;         // Sort order (asc or desc)
  const CategorySort(this.field, this.order);
}

/// Class representing an Employee sort option
class EmployeeSort {
  final EmployeeSortField field; // Field to sort by
  final SortOrder order;         // Sort order (asc or desc)
  const EmployeeSort(this.field, this.order);
}

/// Class representing a Role sort option
class RoleSort {
  final RoleSortField field; // Field to sort by
  final SortOrder order;     // Sort order (asc or desc)
  const RoleSort(this.field, this.order);
}

/// Class representing a Review sort option
class ReviewSort {
  final ReviewSortField field; // Field to sort by
  final SortOrder order;       // Sort order (asc or desc)
  const ReviewSort(this.field, this.order);
}




/// Filters for employee list
enum EmployeeFilter { 
  all,     // Show all employees
  admin,   // Show only admins
  manager, // Show only managers
  staff,   // Show only staff
}
