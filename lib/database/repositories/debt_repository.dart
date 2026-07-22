import '../daos/debts_dao.dart';
import '../app_database.dart';

/// Repository for [Debt] entities.
///
/// Features should depend on this repository rather than accessing
/// [DebtsDao] directly.
class DebtRepository {
  final DebtsDao _dao;

  const DebtRepository(this._dao);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Watches all debts (newest first) as a reactive stream.
  Stream<List<Debt>> watchAll() => _dao.watchAll();

  /// Returns all debts as a one-time snapshot.
  Future<List<Debt>> getAll() => _dao.getAll();

  /// Returns the debt with [id], or `null` if it does not exist.
  Future<Debt?> getById(int id) => _dao.getById(id);

  /// Watches all debts for the given [customerId].
  Stream<List<Debt>> watchByCustomer(int customerId) =>
      _dao.watchByCustomer(customerId);

  /// Watches debts that still have an outstanding balance.
  Stream<List<Debt>> watchUnpaid() => _dao.watchUnpaid();

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Records a new debt and returns its generated id.
  ///
  /// [companion.remaining] should equal [companion.amount] on creation.
  Future<int> create(DebtsCompanion companion) => _dao.insertOne(companion);

  /// Fully replaces the debt row for [entity].
  Future<bool> save(Debt entity) => _dao.updateOne(entity);

  /// Partially updates the debt identified by [id].
  Future<int> patch(int id, DebtsCompanion companion) =>
      _dao.updateById(id, companion);

  /// Applies a payment of [amount] to debt [id], updating [paid] and
  /// [remaining] atomically.
  Future<void> recordPayment(int id, double amount) =>
      _dao.recordPayment(id, amount);

  /// Removes the debt with [id] from the database.
  Future<int> delete(int id) => _dao.deleteById(id);
}
