import '../daos/sales_dao.dart';
import '../app_database.dart';

/// Repository for [Sale] entities.
///
/// Features should depend on this repository rather than accessing
/// [SalesDao] directly.
class SaleRepository {
  final SalesDao _dao;

  const SaleRepository(this._dao);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Watches all sales (newest first) as a reactive stream.
  Stream<List<Sale>> watchAll() => _dao.watchAll();

  /// Returns all sales as a one-time snapshot.
  Future<List<Sale>> getAll() => _dao.getAll();

  /// Returns the sale with [id], or `null` if it does not exist.
  Future<Sale?> getById(int id) => _dao.getById(id);

  /// Returns all sales for [productId].
  Future<List<Sale>> getByProduct(int productId) =>
      _dao.getByProduct(productId);

  /// Returns all sales processed by [employeeId].
  Future<List<Sale>> getByEmployee(int employeeId) =>
      _dao.getByEmployee(employeeId);

  /// Returns sales recorded within the inclusive date range [[from], [to]].
  Future<List<Sale>> getByDateRange(DateTime from, DateTime to) =>
      _dao.getByDateRange(from, to);

  /// Watches all sales recorded on the given calendar [day].
  Stream<List<Sale>> watchByDay(DateTime day) => _dao.watchByDay(day);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Records a new sale and returns its generated id.
  Future<int> create(SalesCompanion companion) => _dao.insertOne(companion);

  /// Removes the sale with [id] from the database.
  Future<int> delete(int id) => _dao.deleteById(id);
}
