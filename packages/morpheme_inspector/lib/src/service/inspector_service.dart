import 'package:morpheme_inspector/morpheme_inspector.dart';
import 'package:sqflite/sqflite.dart';

/// Service helper for sqlite inspector.
abstract final class InspectorService {
  /// The name of table sqlite
  static const String _table = 'inspector';

  /// The name of column id in table inspector.
  static const String _id = 'id';

  /// The name of column request json in table inspector.
  static const String _request = 'request';

  /// The name of column response json in table inspector.
  static const String _response = 'response';

  /// The name of column created_at in table inspector.
  static const String _createdAt = 'created_at';

  /// The name of column updated_at in table inspector.
  static const String _updatedAt = 'updated_at';

  /// The wrapper database sqlite.
  static Database? _db;

  /// Return [Database] with open database sqlite.
  static Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    String path = '$databasesPath/morpheme_inspector.db';

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE $_table ($_id TEXT PRIMARY KEY, $_request TEXT, $_response TEXT, $_createdAt INTEGER, $_updatedAt INTEGER)');
    });
  }

  /// Validate database stil opened, if close then open database.
  static Future<void> _validateDatabaseOpened() async {
    if (_db?.isOpen ?? false) return;
    _db = await _openDatabase();
  }

  /// Insert data to sqlite with given [inspector].
  static Future<void> insert(Inspector inspector) async {
    await _validateDatabaseOpened();
    await _db?.transaction((txn) async {
      await txn.insert(
        _table,
        inspector.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Update data to sqlite with given [inspector].
  static Future<void> updateResponse(
      String uuid, ResponseInspector response) async {
    await _validateDatabaseOpened();
    await _db?.transaction((txn) async {
      await txn.update(
        _table,
        {
          _response: response.toJson(),
          _updatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        where: '$_id = ?',
        whereArgs: [uuid],
      );
    });
  }

  /// Return list [Inspector] with given [limit] and [offset].
  static Future<List<Inspector>> getAll({
    String? keyword,
    int? limit,
    int? offset,
  }) async {
    await _validateDatabaseOpened();
    final listMap = await _db?.query(
          _table,
          where: keyword != null ? '$_request LIKE ?' : null,
          whereArgs: keyword != null ? ['%$keyword%'] : null,
          orderBy: '$_createdAt DESC',
          limit: limit,
          offset: offset,
        ) ??
        [];
    return listMap.map((e) => Inspector.fromMap(e)).toList();
  }

  /// Return [Inspector] with given [id].
  static Future<Inspector?> get(String id) async {
    await _validateDatabaseOpened();
    final listMap =
        await _db?.query(_table, where: '$_id = ?', whereArgs: [id]) ?? [];
    if (listMap.isNotEmpty) return Inspector.fromMap(listMap.first);
    return null;
  }

  /// Delete data sqlite with given [id].
  static Future<int?> delete(String id) async {
    await _validateDatabaseOpened();
    return _db?.transaction((txn) {
      return txn.delete(_table, where: '$_id = ?', whereArgs: [id]);
    });
  }

  /// Delete all data sqlite inspector.
  static Future<void> deleteAll() async {
    await _validateDatabaseOpened();
    await _db?.transaction((txn) async {
      await txn.delete(_table);
    });
  }

  /// Close the database if databse stil open.
  Future<void> close() async {
    if (_db?.isOpen ?? false) {
      await _db?.close();
    }
  }
}
