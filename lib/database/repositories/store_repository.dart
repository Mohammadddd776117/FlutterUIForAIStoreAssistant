import '../daos/stores_dao.dart';
import '../app_database.dart';

/// Repository for [Store] entities.
///
/// Features should depend on this repository rather than accessing
/// [StoresDao] directly. Business rules (e.g. validation, default
/// values) belong here, not in the DAO.
class StoreRepository {
  final StoresDao _dao;

  const StoreRepository(this._dao);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Watches all stores as a reactive stream.
  Stream<List<Store>> watchAll() => _dao.watchAll();

  /// Returns all stores as a one-time snapshot.
  Future<List<Store>> getAll() => _dao.getAll();

  /// Returns the store with [id], or `null` if it does not exist.
  Future<Store?> getById(int id) => _dao.getById(id);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Creates a new store from the provided companion and returns its id.
  Future<int> create(StoresCompanion companion) => _dao.insertOne(companion);

  /// Fully replaces the store row for [entity].
  Future<bool> save(Store entity) => _dao.updateOne(entity);

  /// Partially updates the store identified by [id].
  Future<int> patch(int id, StoresCompanion companion) =>
      _dao.updateById(id, companion);

  /// Removes the store with [id] from the database.
  Future<int> delete(int id) => _dao.deleteById(id);
}
