// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movements_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryMovementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductsTable get products => attachedDatabase.products;
  $InventoryMovementsTable get inventoryMovements =>
      attachedDatabase.inventoryMovements;
  InventoryMovementsDaoManager get managers =>
      InventoryMovementsDaoManager(this);
}

class InventoryMovementsDaoManager {
  final _$InventoryMovementsDaoMixin _db;
  InventoryMovementsDaoManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(
          _db.attachedDatabase, _db.inventoryMovements);
}
