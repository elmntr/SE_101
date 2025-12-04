enum ItemSort {
  nameAZ,
  nameZA,
  stockLowHigh,
  stockHighLow,
  saleLowHigh,
  saleHighLow,
  spoilLowHigh,
  spoilHighLow,
  dateOldNew,
  dateNewOld,
}

enum CategorySort {
  nameAZ,
  nameZA,
  itemsLowHigh,
  itemsHighLow,
  dateOldNew,
  dateNewOld,
}

enum EmployeeSort {
  nameAZ,
  nameZA,
  emailAZ,
  emailZA,
  dateNewOld,
  dateOldNew,
}

enum EmployeeFilter {
  all,
  admin,
  manager,
  staff,
}

enum RoleSort {
  nameAZ,
  nameZA,
  employeesHighLow,
  employeesLowHigh,
  dateNewOld,
  dateOldNew,
}

enum ReviewSort { employeeAZ, employeeZA, roleAZ, roleZA, changesLowHigh, changesHighLow}

