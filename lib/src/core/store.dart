import 'dart:convert';
import 'dart:io';

import 'package:dio_cache/src/core/config.dart';
import 'package:dio_cache/src/core/obj.dart';
import 'package:path/path.dart';
import 'package:quiver/cache.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseCacheStore {
  CacheConfig config;
  BaseCacheStore(this.config);

  Future<CacheObj> getCacheObj(String key, {String subKey});

  setCacheObj(CacheObj obj);

  delete(String key, {String subKey});

  clearExpired();
}

class DiskCacheStore extends BaseCacheStore {
  Future<Database> _database;

  final String tableCacheObject = "cacheObj";
  final String columnKey = "key";
  final String columnSubKey = "subKey";
  final String columnMaxAgeDate = "max_age_date";
  final String columnMaxStaleDate = "max_stale_date";
  final String columnContent = "content";

  DiskCacheStore(CacheConfig config) : super(config) {
    _init();
  }

  _init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "${config.databaseName}.db");
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      print(e);
    }

    _database = openDatabase(path, version: 1, onCreate: (Database db, int version) async {
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
    });
  }

  @override
  Future<CacheObj> getCacheObj(String key, {String subKey}) {
    var where = "$columnKey=\"$key\"";
    if (null != subKey) where += " and $columnSubKey=\"$subKey\"";

    return _database.then((db) => db.query(tableCacheObject, where: where).then((list) {
          if (null == list || list.length <= 0) return null;
          return _decryptCacheObj(CacheObj.fromJson(list[0]));
        }));
  }

  @override
  setCacheObj(CacheObj obj) async {
    if (null != config.encrypt)
      obj.content = await config.encrypt(obj.content);
    else
      obj.content = base64.encode(utf8.encode(obj.content));

    _database.then((db) => db.execute(
        "REPLACE INTO $tableCacheObject($columnKey,$columnSubKey,$columnMaxAgeDate,$columnMaxStaleDate,$columnContent)"
        " values(\"${obj.key}\",\"${obj.subKey ?? ""}\",${obj.maxAgeDate ?? 0},${obj.maxStaleDate ?? 0},\"${obj.content}\")"));
  }

  @override
  delete(String key, {String subKey}) {
    var where = "$columnKey=\"$key\"";
    if (null != subKey) where += " and $columnSubKey=\"$subKey\"";
    _database.then((db) => db.delete(tableCacheObject, where: where));
  }

  @override
  clearExpired() {
    var now = DateTime.now().millisecondsSinceEpoch;
    _database.then((db) => db.delete(tableCacheObject, where: "$columnMaxStaleDate<$now"));
  }

  Future<CacheObj> _decryptCacheObj(CacheObj obj) async {
    if (null != config.decrypt)
      obj.content = await config.decrypt(obj.content);
    else {
      obj.content = utf8.decode(base64.decode(obj.content));
    }
    return obj;
  }
}

class MemoryCacheStore extends BaseCacheStore {
  MapCache<String, CacheObj> _mapCache;

  MemoryCacheStore(CacheConfig config) : super(config) {
    _initMap();
  }

  _initMap() => _mapCache = MapCache.lru(maximumSize: config.maxMemoryCacheCount);

  @override
  Future<CacheObj> getCacheObj(String key, {String subKey = ""}) => _mapCache.get("${key}_$subKey");

  @override
  setCacheObj(CacheObj obj) => _mapCache.set("${obj.key}_${obj.subKey}", obj);

  @override
  delete(String key, {String subKey}) => _mapCache.invalidate("${key}_${subKey ?? ""}");

  @override
  clearExpired() {
    _mapCache = null;
    _initMap();
  }
}
