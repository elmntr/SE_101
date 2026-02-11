import 'package:flutter_test/flutter_test.dart';
import 'package:chickenjoo_inventory/tables/sorting_and_filters.dart';

void main() {
  group('SortOrder Enum', () {
    test('1. should have asc and desc values', () {
      expect(SortOrder.values.length, equals(2));
      expect(SortOrder.values, contains(SortOrder.asc));
      expect(SortOrder.values, contains(SortOrder.desc));
    });

    test('2. asc should have index 0', () {
      expect(SortOrder.asc.index, equals(0));
    });

    test('3. desc should have index 1', () {
      expect(SortOrder.desc.index, equals(1));
    });
  });

  group('ItemSortField Enum', () {
    test('4. should have 5 values', () {
      expect(ItemSortField.values.length, equals(5));
    });

    test('5. should contain all expected fields', () {
      expect(ItemSortField.values, contains(ItemSortField.name));
      expect(ItemSortField.values, contains(ItemSortField.stock));
      expect(ItemSortField.values, contains(ItemSortField.sale));
      expect(ItemSortField.values, contains(ItemSortField.spoilage));
      expect(ItemSortField.values, contains(ItemSortField.date));
    });
  });

  group('CategorySortField Enum', () {
    test('6. should have 3 values', () {
      expect(CategorySortField.values.length, equals(3));
      expect(CategorySortField.values, contains(CategorySortField.name));
      expect(CategorySortField.values, contains(CategorySortField.items));
      expect(CategorySortField.values, contains(CategorySortField.date));
    });
  });

  group('EmployeeSortField Enum', () {
    test('7. should have 3 values', () {
      expect(EmployeeSortField.values.length, equals(3));
      expect(EmployeeSortField.values, contains(EmployeeSortField.name));
      expect(EmployeeSortField.values, contains(EmployeeSortField.email));
      expect(EmployeeSortField.values, contains(EmployeeSortField.date));
    });
  });

  group('RoleSortField Enum', () {
    test('8. should have 3 values', () {
      expect(RoleSortField.values.length, equals(3));
      expect(RoleSortField.values, contains(RoleSortField.name));
      expect(RoleSortField.values, contains(RoleSortField.employees));
      expect(RoleSortField.values, contains(RoleSortField.date));
    });
  });

  group('ReviewSortField Enum', () {
    test('9. should have 3 values', () {
      expect(ReviewSortField.values.length, equals(3));
      expect(ReviewSortField.values, contains(ReviewSortField.employee));
      expect(ReviewSortField.values, contains(ReviewSortField.role));
      expect(ReviewSortField.values, contains(ReviewSortField.changes));
    });
  });

  group('ItemSort', () {
    test('10. should create with field and order', () {
      const sort = ItemSort(ItemSortField.name, SortOrder.asc);
      expect(sort.field, equals(ItemSortField.name));
      expect(sort.order, equals(SortOrder.asc));
    });

    test('11. should support const constructor', () {
      const sort1 = ItemSort(ItemSortField.stock, SortOrder.desc);
      const sort2 = ItemSort(ItemSortField.stock, SortOrder.desc);
      expect(sort1.field, equals(sort2.field));
      expect(sort1.order, equals(sort2.order));
    });
  });

  group('CategorySort', () {
    test('12. should create with field and order', () {
      const sort = CategorySort(CategorySortField.items, SortOrder.desc);
      expect(sort.field, equals(CategorySortField.items));
      expect(sort.order, equals(SortOrder.desc));
    });
  });

  group('EmployeeSort', () {
    test('13. should create with field and order', () {
      const sort = EmployeeSort(EmployeeSortField.email, SortOrder.asc);
      expect(sort.field, equals(EmployeeSortField.email));
      expect(sort.order, equals(SortOrder.asc));
    });
  });

  group('RoleSort', () {
    test('14. should create with field and order', () {
      const sort = RoleSort(RoleSortField.employees, SortOrder.desc);
      expect(sort.field, equals(RoleSortField.employees));
      expect(sort.order, equals(SortOrder.desc));
    });
  });

  group('EmployeeFilter Enum', () {
    test('15. should have 4 values', () {
      expect(EmployeeFilter.values.length, equals(4));
      expect(EmployeeFilter.values, contains(EmployeeFilter.all));
      expect(EmployeeFilter.values, contains(EmployeeFilter.admin));
      expect(EmployeeFilter.values, contains(EmployeeFilter.manager));
      expect(EmployeeFilter.values, contains(EmployeeFilter.staff));
    });
  });
}
