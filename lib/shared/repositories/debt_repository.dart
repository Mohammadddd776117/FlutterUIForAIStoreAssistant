import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../shared/models/debt_model.dart';
import 'repository_exceptions.dart';

class DebtRepository {
  final AppDatabase _db = AppDatabase.instance;

  /// Watches all debts as a reactive stream that emits a new list
  /// whenever the database changes.
  Stream<List<DebtModel>> watchDebts() {
    return (_db.select(_db.debts)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  Future<List<DebtModel>> getDebts() async {
    try {
      final rows = await (_db.select(_db.debts)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
      return rows.map(_mapRow).toList();
    } catch (e) {
      throw DatabaseException('Unable to load debts: $e');
    }
  }

  Future<DebtModel> createDebt({required String customerName, required double amount, String? note}) async {
    if (customerName.trim().isEmpty) {
      throw ValidationException('Customer name is required.');
    }
    if (amount <= 0) {
      throw ValidationException('Debt amount must be greater than zero.');
    }

    try {
      final now = DateTime.now();
      final entity = DebtsCompanion(
        id: Value(Uuid().v4()),
        customerName: Value(customerName.trim()),
        originalAmount: Value(amount),
        paidAmount: const Value(0),
        createdAt: Value(now),
        note: Value(note?.trim()),
      );
      await _db.into(_db.debts).insert(entity);
      return DebtModel(
        id: entity.id.value,
        customerId: '',
        customerName: customerName.trim(),
        originalAmount: amount,
        createdAt: now,
        note: note?.trim(),
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Unable to save debt: $e');
    }
  }

  Future<DebtModel> updateDebt({
    required String id,
    String? customerName,
    double? amount,
    String? note,
  }) async {
    try {
      final existing = await (_db.select(_db.debts)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
      if (existing == null) {
        throw ValidationException('Debt not found.');
      }

      final companion = DebtsCompanion(
        customerName: customerName != null ? Value(customerName.trim()) : const Value.absent(),
        originalAmount: amount != null ? Value(amount) : const Value.absent(),
        note: Value(note?.trim()),
      );

      await (_db.update(_db.debts)..where((tbl) => tbl.id.equals(id)))
          .write(companion);

      final row = await (_db.select(_db.debts)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();
      return _mapRow(row);
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) rethrow;
      throw DatabaseException('Unable to update debt: $e');
    }
  }

  Future<void> deleteDebt(String id) async {
    try {
      final deleted =
          await (_db.delete(_db.debts)..where((tbl) => tbl.id.equals(id)))
              .go();
      if (deleted == 0) {
        throw ValidationException('Debt not found.');
      }
    } catch (e) {
      if (e is ValidationException || e is DatabaseException) rethrow;
      throw DatabaseException('Unable to delete debt: $e');
    }
  }

  Future<DebtModel> recordPayment(String id, double amount) async {
    if (amount <= 0) {
      throw ValidationException('Payment amount must be greater than zero.');
    }
    try {
      final existing = await (_db.select(_db.debts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        throw ValidationException('Debt not found.');
      }
      final updatedPaid = (existing.paidAmount + amount).clamp(0, existing.originalAmount).toDouble();
      await (_db.update(_db.debts)
            ..where((tbl) => tbl.id.equals(id)))
          .write(DebtsCompanion(paidAmount: Value(updatedPaid)));
      final row = await (_db.select(_db.debts)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();
      return _mapRow(row);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Unable to record payment: $e');
    }
  }

  DebtModel _mapRow(Debt row) {
    return DebtModel(
      id: row.id,
      customerId: row.customerId ?? '',
      customerName: row.customerName,
      customerPhone: row.customerPhone,
      originalAmount: row.originalAmount,
      payments: [
        if (row.paidAmount > 0)
          DebtPayment(
            id: '${row.id}-paid',
            amount: row.paidAmount,
            paidAt: row.createdAt,
          ),
      ],
      createdAt: row.createdAt,
      dueDate: row.dueDate,
      note: row.note,
      branchId: row.branchId,
    );
  }
}
