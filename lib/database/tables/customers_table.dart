import 'package:drift/drift.dart';

/// Drift table definition for customers.
///
/// A [Customer] is a buyer who may have an outstanding [Debt]
/// recorded against them.
class Customers extends Table {
  /// Auto-incremented primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Full name of the customer.
  TextColumn get name => text()();

  /// Optional contact phone number.
  TextColumn get phone => text().nullable()();

  /// Optional delivery or home address.
  TextColumn get address => text().nullable()();
}
