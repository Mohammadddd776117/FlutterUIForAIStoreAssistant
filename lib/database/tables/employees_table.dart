import 'package:drift/drift.dart';

import 'branches_table.dart';

/// Drift table definition for employees.
///
/// An [Employee] is assigned to a [Branch] and has a role
/// (e.g. cashier, manager) that controls their permissions in the app.
class Employees extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key referencing the parent [Branches.id].
  IntColumn get branchId => integer().references(Branches, #id)();

  /// Full name of the employee.
  TextColumn get name => text()();

  /// Role string (e.g. 'merchant', 'worker').
  TextColumn get role => text()();

  /// Contact phone number for the employee.
  TextColumn get phone => text()();
}
