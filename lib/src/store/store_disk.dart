import 'dart:io';

import 'package:dio_http_cache/src/core/config.dart';
import 'package:dio_http_cache/src/core/obj.dart';
import 'package:dio_http_cache/src/store/store_impl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DiskCacheStore extends ICacheStore {
  final String? _databasePath;
  final String _databaseName;
  final Encrypt? _encrypt;
  final Decrypt? _decrypt;
  final String _tableCacheObject = "cache_dio";
  final String _columnKey = "key";
  final String _columnSubKey = "subKey";
  final String _columnMaxAgeDate = "max_age_date";
  final String _columnMaxStaleDate = "max_stale_date";
  final String _columnContent = "content";
  final String _columnStatusCode = "statusCode";
  final String _columnHeaders = "headers";

  Database? _db;
  static const int _curDBVersion = 3;

  Future<Database?> get _database async {
    if (null == _db) {
      var path = _databasePath;
      if (null == path || path.length <= 0) {
        path = await getDatabasesPath();
      }
      await Directory(path).create(recursive: true);
      path = join(path, "$_databaseName.db");
      _db = await openDatabase(path,
          version: _curDBVersion,
          onConfigure: (db) => _tryFixDbNoVersionBug(db, path!),
          onCreate: _onCreate,
          onUpgrade: _onUpgrade);
      await _clearExpired(_db);
    }
    return _db;
  }

  _tryFixDbNoVersionBug(Database db, String dbPath) async {
    if ((await db.getVersion()) == 0) {
      var isTableUserLogExist = await db
          .rawQuery(
              "select DISTINCT tbl_name from sqlite_master where tbl_name = '$_tableCacheObject'")
          .then((v) => (v.length > 0));
      if (isTableUserLogExist) {
        await db.setVersion(1);
      }
    }
  }

  _getCreateTableSql() => '''
      CREATE TABLE IF NOT EXISTS $_tableCacheObject ( 
        $_columnKey text, 
        $_columnSubKey text, 
        $_columnMaxAgeDate integer,
        $_columnMaxStaleDate integer,
        $_columnContent BLOB,
        $_columnStatusCode integer,
        $_columnHeaders BLOB,
        PRIMARY KEY ($_columnKey, $_columnSubKey)
        ) 
      ''';

  _onCreate(Database db, int version) async {
    await db.execute(_getCreateTableSql());
  }

  List<List<String>?> _dbUpgradeList() => [
        // 0 -> 1
        null,
        // 1 -> 2
        [
          "ALTER TABLE $_tableCacheObject ADD COLUMN $_columnStatusCode integer;"
        ],
        // 2 -> 3 : Change $_columnContent from text to BLOB
        ["DROP TABLE IF EXISTS $_tableCacheObject;", _getCreateTableSql()],
      ];

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var mergeLength = _dbUpgradeList().length;
    if (oldVersion < 0 || oldVersion >= mergeLength) return;
    await db.transaction((txn) async {
      var tempVersion = oldVersion;
      while (tempVersion < newVersion) {
        if (tempVersion < mergeLength) {
          var sqlList = _dbUpgradeList()[tempVersion];
          if (null != sqlList && sqlList.length > 0) {
            sqlList.forEach((sql) async {
              sql = sql.trim();
              if (sql.length > 0) {
                await txn.execute(sql);
              }
            });
          }
        }
        tempVersion++;
      }
    });
  }

  DiskCacheStore(
      this._databasePath, this._databaseName, this._encrypt, this._decrypt)
      : super();

  @override
  Future<CacheObj?> getCacheObj(String key, {String? subKey}) async {
    var db = await _database;
    if (null == db) return null;
    var where = "$_columnKey=\"$key\"";
    if (null != subKey) where += " and $_columnSubKey=\"$subKey\"";
    var resultList = await db.query(_tableCacheObject, where: where);
    if (resultList.isEmpty) return null;
    return await _decryptCacheObj(CacheObj.fromJson(resultList[0]));
  }

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    var db = await _database;
    if (null == db) return false;
    var content = await _encryptCacheStr(obj.content);
    var headers = await _encryptCacheStr(obj.headers);
    await db.insert(
        _tableCacheObject,
        {
          _columnKey: obj.key,
          _columnSubKey: obj.subKey ?? "",
          _columnMaxAgeDate: obj.maxAgeDate ?? 0,
          _columnMaxStaleDate: obj.maxStaleDate ?? 0,
          _columnContent: content,
          _columnStatusCode: obj.statusCode,
          _columnHeaders: headers
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  @override
  Future<bool> delete(String key, {String? subKey}) async {
    var db = await _database;
    if (null == db) return false;
    var where = "$_columnKey=\"$key\"";
    if (null != subKey) where += " and $_columnSubKey=\"$subKey\"";
    return 0 != await db.delete(_tableCacheObject, where: where);
  }

  @override
  Future<bool> clearExpired() async {
    var db = await _database;
    return _clearExpired(db);
  }

  Future<bool> _clearExpired(Database? db) async {
    if (null == db) return false;
    var now = DateTime.now().millisecondsSinceEpoch;
    var where1 = "$_columnMaxStaleDate > 0 and $_columnMaxStaleDate < $now";
    var where2 = "$_columnMaxStaleDate <= 0 and $_columnMaxAgeDate < $now";
    return 0 !=
        await db.delete(_tableCacheObject, where: "( $where1 ) or ( $where2 )");
  }

  @override
  Future<bool> clearAll() async {
    var db = await _database;
    if (null == db) return false;
    return 0 != await db.delete(_tableCacheObject);
  }

  Future<CacheObj> _decryptCacheObj(CacheObj obj) async {
    obj.content = await _decryptCacheStr(obj.content);
    obj.headers = await _decryptCacheStr(obj.headers);
    return obj;
  }

  Future<List<int>?> _decryptCacheStr(List<int>? bytes) async {
    if (null == bytes) return null;
    if (null != _decrypt) {
      bytes = await _decrypt!(bytes);
    }
    return bytes;
  }

  Future<List<int>?> _encryptCacheStr(List<int>? bytes) async {
    if (null == bytes) return null;
    if (null != _encrypt) {
      bytes = await _encrypt!(bytes);
    }
    return bytes;
  }
}
