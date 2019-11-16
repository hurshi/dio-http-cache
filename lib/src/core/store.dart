import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio_http_cache/src/core/config.dart';
import 'package:dio_http_cache/src/core/obj.dart';
import 'package:path/path.dart';
import 'package:quiver/cache.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseCacheStore {
  CacheConfig config;

  BaseCacheStore(this.config);

  Future<CacheObj> getCacheObj(String key, {String subKey});

  Future<bool> setCacheObj(CacheObj obj);

  Future<bool> delete(String key, {String subKey});

  Future<bool> clearExpired();

  Future<bool> clearAll();
}

class DiskCacheStore extends BaseCacheStore {
  final String _tableCacheObject = "cache_dio";
  final String _columnKey = "key";
  final String _columnSubKey = "subKey";
  final String _columnMaxAgeDate = "max_age_date";
  final String _columnMaxStaleDate = "max_stale_date";
  final String _columnContent = "content";
  final String _columnStatusCode = "statusCode";

  Database _db;
  static const int _curDBVersion = 2;

  Future<Database> get _database async {
    if (null == _db) {
      var path = await getDatabasesPath();
      await Directory(path).create(recursive: true);
      path = join(path, "${config.databaseName}.db");
      _db = await openDatabase(path,
          version: _curDBVersion,
          onConfigure: (db) => _tryFixDbNoVersionBug(db, path),
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
          .then((v) => (null != v && v.length > 0));
      if (isTableUserLogExist) {
        await db.setVersion(1);
      }
    }
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableCacheObject ( 
        $_columnKey text, 
        $_columnSubKey text, 
        $_columnMaxAgeDate integer,
        $_columnMaxStaleDate integer,
        $_columnContent text,
        $_columnStatusCode integer,
        PRIMARY KEY ($_columnKey, $_columnSubKey)
        ) 
      ''');
  }

  _dbUpgradeList() => [
        // 0 -> 1
        null,
        // 1 -> 2
        "ALTER TABLE $_tableCacheObject ADD COLUMN $_columnStatusCode integer;",
      ];

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var mergeLength = _dbUpgradeList().length;
    if (oldVersion < 0 || oldVersion >= mergeLength) return;
    await db.transaction((txn) async {
      var tempVersion = oldVersion;
      while (tempVersion < newVersion) {
        if (tempVersion < mergeLength) {
          var sql = _dbUpgradeList()[tempVersion].trim();
          if (null != sql && sql.length > 0) {
            await txn.execute(sql);
          }
        }
        tempVersion++;
      }
    });
  }

  DiskCacheStore(CacheConfig config) : super(config);

  @override
  Future<CacheObj> getCacheObj(String key, {String subKey}) async {
    var db = await _database;
    if (null == db) return null;
    var where = "$_columnKey=\"$key\"";
    if (null != subKey) where += " and $_columnSubKey=\"$subKey\"";
    var resultList = await db.query(_tableCacheObject, where: where);
    if (null == resultList || resultList.length <= 0) return null;
    return await _decryptCacheObj(CacheObj.fromJson(resultList[0]));
  }

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    var db = await _database;
    if (null == db) return false;
    var content = await _encryptCacheStr(obj.content);
    await db.execute(
        "REPLACE INTO $_tableCacheObject($_columnKey,$_columnSubKey,$_columnMaxAgeDate,$_columnMaxStaleDate,$_columnContent,$_columnStatusCode)"
        " values(\"${obj.key}\",\"${obj.subKey ?? ""}\",${obj.maxAgeDate ?? 0},${obj.maxStaleDate ?? 0},\"$content\",${obj.statusCode})");
    return true;
  }

  @override
  Future<bool> delete(String key, {String subKey}) async {
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

  Future<bool> _clearExpired(Database db) async {
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
    if (null != config.decrypt) {
      obj.content = await config.decrypt(obj.content);
    } else {
      obj.content = utf8.decode(base64.decode(obj.content));
    }
    return obj;
  }

  Future<String> _encryptCacheStr(String str) async {
    if (null != config.encrypt) {
      str = await config.encrypt(str);
    } else {
      str = base64.encode(utf8.encode(str));
    }
    return str;
  }
}

class MemoryCacheStore extends BaseCacheStore {
  MapCache<String, CacheObj> _mapCache;
  Map<String, List<String>> _keys;

  MemoryCacheStore(CacheConfig config) : super(config) {
    _initMap();
  }

  _initMap() {
    _mapCache = MapCache.lru(maximumSize: config.maxMemoryCacheCount);
    _keys = HashMap();
  }

  @override
  Future<CacheObj> getCacheObj(String key, {String subKey = ""}) async =>
      _mapCache.get("${key}_$subKey");

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    _mapCache.set("${obj.key}_${obj.subKey}", obj);
    _storeKey(obj);
    return true;
  }

  @override
  Future<bool> delete(String key, {String subKey}) async {
//    _mapCache.invalidate("${key}_${subKey ?? ""}");
    _removeKey(key, subKey: subKey).forEach((key) => _mapCache.invalidate(key));
    return true;
  }

  @override
  Future<bool> clearExpired() {
    return clearAll();
  }

  @override
  Future<bool> clearAll() async {
    _mapCache = null;
    _keys = null;
    _initMap();
    return true;
  }

  _storeKey(CacheObj obj) {
    List<String> subKeyList = _keys[obj.key];
    if (null == subKeyList) subKeyList = List();
    subKeyList.add(obj.subKey ?? "");
    _keys[obj.key] = subKeyList;
  }

  List<String> _removeKey(String key, {String subKey}) {
    List<String> subKeyList = _keys[key];
    if (null == subKeyList || subKeyList.length <= 0) return [];
    if (null == subKey) {
      _keys.remove(key);
      return subKeyList.map((sKey) => "${key}_$sKey").toList();
    } else {
      subKeyList.remove(subKey);
      _keys[key] = subKeyList;
      return ["${key}_$subKey"];
    }
  }
}
