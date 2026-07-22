import '../daos/products_dao.dart';
import '../app_database.dart';

/// Repository for [Product] entities.
///
/// Centralises all inventory product access. Features should call
/// this repository rather than [ProductsDao] directly.
class ProductRepository {
  final ProductsDao _dao;

  const ProductRepository(this._dao);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Watches all products alphabetically as a reactive stream.
  Stream<List<Product>> watchAll() => _dao.watchAll();

  /// Returns all products as a one-time snapshot.
  Future<List<Product>> getAll() => _dao.getAll();

  /// Returns the product with [id], or `null` if it does not exist.
  Future<Product?> getById(int id) => _dao.getById(id);

  /// Returns the product with [barcode], or `null` if not found.
  Future<Product?> getByBarcode(String barcode) => _dao.getByBarcode(barcode);

  /// Watches products whose quantity is below their minimum stock threshold.
  Stream<List<Product>> watchLowStock() => _dao.watchLowStock();

  /// Watches products with zero stock.
  Stream<List<Product>> watchOutOfStock() => _dao.watchOutOfStock();

  /// Watches all products in [category].
  Stream<List<Product>> watchByCategory(String category) =>
      _dao.watchByCategory(category);

  /// Returns products whose name contains [query] (case-insensitive).
  Future<List<Product>> search(String query) => _dao.searchByName(query);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Creates a new product from the provided companion and returns its id.
  Future<int> create(ProductsCompanion companion) => _dao.insertOne(companion);

  /// Fully replaces the product row for [entity].
  Future<bool> save(Product entity) => _dao.updateOne(entity);

  /// Partially updates the product identified by [id].
  Future<int> patch(int id, ProductsCompanion companion) =>
      _dao.updateById(id, companion);

  /// Adjusts the stock quantity of [productId] by [delta] units.
  ///
  /// Pass a negative [delta] to reduce stock.
  Future<void> adjustStock(int productId, int delta) =>
      _dao.adjustStock(productId, delta);

  /// Removes the product with [id] from the database.
  Future<int> delete(int id) => _dao.deleteById(id);
}
