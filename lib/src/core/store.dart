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
  final String tableCacheObject = "cache_dio";
  final String columnKey = "key";
  final String columnSubKey = "subKey";
  final String columnMaxAgeDate = "max_age_date";
  final String columnMaxStaleDate = "max_stale_date";
  final String columnContent = "content";

  Database _db;

  Future<Database> get _database async {
    if (null == _db) {
      var path = await getDatabasesPath();
      await Directory(path).create(recursive: true);
      path = join(path, "${config.databaseName}.db");
      _db = await openDatabase(path);
      await _onDatabaseOpen(_db);
    }
    return _db;
  }

  DiskCacheStore(CacheConfig config) : super(config);

  _onDatabaseOpen(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCacheObject ( 
        $columnKey text, 
        $columnSubKey text, 
        $columnMaxAgeDate integer,
        $columnMaxStaleDate integer,
        $columnContent text,
        PRIMARY KEY ($columnKey, $columnSubKey)
        ) 
      ''');
    await _clearExpired(db);
  }

  @override
  Future<CacheObj> getCacheObj(String key, {String subKey}) async {
    var db = await _database;
    if (null == db) return null;
    var where = "$columnKey=\"$key\"";
    if (null != subKey) where += " and $columnSubKey=\"$subKey\"";
    var resultList = await db.query(tableCacheObject, where: where);
    if (null == resultList || resultList.length <= 0) return null;
    return await _decryptCacheObj(CacheObj.fromJson(resultList[0]));
  }

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    var db = await _database;
    if (null == db) return false;
    var content = await _encryptCacheStr(obj.content);
    await db.execute(
        "REPLACE INTO $tableCacheObject($columnKey,$columnSubKey,$columnMaxAgeDate,$columnMaxStaleDate,$columnContent)"
        " values(\"${obj.key}\",\"${obj.subKey ?? ""}\",${obj.maxAgeDate ?? 0},${obj.maxStaleDate ?? 0},\"$content\")");
    return true;
  }

  @override
  Future<bool> delete(String key, {String subKey}) async {
    var db = await _database;
    if (null == db) return false;
    var where = "$columnKey=\"$key\"";
    if (null != subKey) where += " and $columnSubKey=\"$subKey\"";
    return 0 != await db.delete(tableCacheObject, where: where);
  }

  @override
  Future<bool> clearExpired() async {
    var db = await _database;
    return _clearExpired(db);
  }

  Future<bool> _clearExpired(Database db) async {
    if (null == db) return false;
    var now = DateTime.now().millisecondsSinceEpoch;
    var where1 = "$columnMaxStaleDate > 0 and $columnMaxStaleDate < $now";
    var where2 = "$columnMaxStaleDate <= 0 and $columnMaxAgeDate < $now";
    return 0 !=
        await db.delete(tableCacheObject, where: "( $where1 ) or ( $where2 )");
  }

  @override
  Future<bool> clearAll() async {
    var db = await _database;
    if (null == db) return false;
    return 0 != await db.delete(tableCacheObject);
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

  MemoryCacheStore(CacheConfig config) : super(config) {
    _initMap();
  }

  _initMap() =>
      _mapCache = MapCache.lru(maximumSize: config.maxMemoryCacheCount);

  @override
  Future<CacheObj> getCacheObj(String key, {String subKey = ""}) async =>
      _mapCache.get("${key}_$subKey");

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    _mapCache.set("${obj.key}_${obj.subKey}", obj);
    return true;
  }

  @override
  Future<bool> delete(String key, {String subKey}) async {
    _mapCache.invalidate("${key}_${subKey ?? ""}");
    return true;
  }

  @override
  Future<bool> clearExpired() {
    return clearAll();
  }

  @override
  Future<bool> clearAll() async {
    _mapCache = null;
    _initMap();
    return true;
  }
}
