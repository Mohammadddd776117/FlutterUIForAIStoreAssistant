import 'package:drift/drift.dart';

import 'stores_table.dart';

/// Drift table definition for store branches.
///
/// A [Branch] belongs to a [Store] and represents a physical
/// location where business is conducted.
class Branches extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key referencing the parent [Stores.id].
  IntColumn get storeId => integer().references(Stores, #id)();

  /// Display name of the branch.
  TextColumn get name => text()();

  /// Physical address of this branch.
  TextColumn get address => text()();
}
