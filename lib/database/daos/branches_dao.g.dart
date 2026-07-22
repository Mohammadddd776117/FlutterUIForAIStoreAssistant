// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_dao.dart';

// ignore_for_file: type=lint
mixin _$BranchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTable get stores => attachedDatabase.stores;
  $BranchesTable get branches => attachedDatabase.branches;
  BranchesDaoManager get managers => BranchesDaoManager(this);
}

class BranchesDaoManager {
  final _$BranchesDaoMixin _db;
  BranchesDaoManager(this._db);
  $$StoresTableTableManager get stores =>
      $$StoresTableTableManager(_db.attachedDatabase, _db.stores);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db.attachedDatabase, _db.branches);
}
