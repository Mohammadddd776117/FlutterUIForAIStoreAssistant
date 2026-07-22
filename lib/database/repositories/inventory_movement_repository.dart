import '../daos/inventory_movements_dao.dart';
import '../app_database.dart';

/// Repository for [InventoryMovement] entities.
///
/// Provides the complete stock audit trail. Features should depend on
/// this repository rather than accessing [InventoryMovementsDao] directly.
class InventoryMovementRepository {
  final InventoryMovementsDao _dao;

  const InventoryMovementRepository(this._dao);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Watches all inventory movements (newest first) as a reactive stream.
  Stream<List<InventoryMovement>> watchAll() => _dao.watchAll();

  /// Returns all inventory movements as a one-time snapshot.
  Future<List<InventoryMovement>> getAll() => _dao.getAll();

  /// Returns all movements for [productId].
  Future<List<InventoryMovement>> getByProduct(int productId) =>
      _dao.getByProduct(productId);

  /// Returns all movements of [type] (`'in'`, `'out'`, or `'adjustment'`).
  Future<List<InventoryMovement>> getByType(String type) =>
      _dao.getByType(type);

  /// Returns movements within the inclusive date range [[from], [to]].
  Future<List<InventoryMovement>> getByDateRange(
    DateTime from,
    DateTime to,
  ) =>
      _dao.getByDateRange(from, to);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Records a new inventory movement and returns its generated id.
  Future<int> record(InventoryMovementsCompanion companion) =>
      _dao.insertOne(companion);

  /// Removes the movement record with [id] from the database.
  Future<int> delete(int id) => _dao.deleteById(id);
}
