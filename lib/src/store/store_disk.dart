import 'package:hive/hive.dart';

import '../../dio_http_cache.dart';

class DiskCacheStore extends ICacheStore {
  final String? _databasePath;
  final String _databaseName;
  final Encrypt? _encrypt;
  final Decrypt? _decrypt;
  final String _columnKey = "key";
  final String _columnSubKey = "subKey";
  final String _columnMaxAgeDate = "max_age_date";
  final String _columnMaxStaleDate = "max_stale_date";
  final String _columnContent = "content";
  final String _columnStatusCode = "statusCode";
  final String _columnHeaders = "headers";

  LazyBox<Map>? _db;

  Future<LazyBox<Map>?> get _database async {
    if (null == _db) {
      var path = _databasePath;
      if (null == path || path.length <= 0) {
        path = await PathHelper.getCurrentPath();
      }
      // await Directory(path).create(recursive: true);
      // path = join(path, "$_databaseName.hive");
      _db = await Hive.openLazyBox<Map>(_databaseName, path: path);
    }
    return _db;
  }

  DiskCacheStore(
      this._databasePath, this._databaseName, this._encrypt, this._decrypt)
      : super();

  @override
  Future<CacheObj?> getCacheObj(String key, {String? subKey}) async {
    var db = await _database;
    if (null == db) return null;
    var dbKey = "$key.$subKey";
    var data = await db.get(dbKey);
    if (data == null) return null;
    var result = data.cast<String, dynamic>();
    return await _decryptCacheObj(CacheObj.fromJson(result));
  }

  @override
  Future<bool> setCacheObj(CacheObj obj) async {
    var db = await _database;
    if (null == db) return false;
    var content = await _encryptCacheStr(obj.content);
    var headers = await _encryptCacheStr(obj.headers);

    var dbKey = "${obj.key}.${obj.subKey}";

    await db.put(dbKey, {
      _columnKey: obj.key,
      _columnSubKey: obj.subKey ?? "",
      _columnMaxAgeDate: obj.maxAgeDate ?? 0,
      _columnMaxStaleDate: obj.maxStaleDate ?? 0,
      _columnContent: content,
      _columnStatusCode: obj.statusCode,
      _columnHeaders: headers
    });
    return true;
  }

  @override
  Future<bool> delete(String key, {String? subKey}) async {
    var db = await _database;
    if (null == db) return false;
    var dbKey = "$key.$subKey";
    await db.delete(dbKey);
    return true;
  }

  @override
  Future<bool> clearExpired() async {
    var db = await _database;
    return _clearExpired(db);
  }

  Future<bool> _clearExpired(LazyBox<Map>? db) async {
    if (null == db) return false;
    var now = DateTime.now().millisecondsSinceEpoch;
    for (var key in db.keys) {
      var data = await db.get(key);
      if (null == data) {
        await db.delete(key);
      } else {
        var obj = CacheObj.fromJson(data.cast<String, dynamic>());
        if ((obj.maxStaleDate != null &&
                obj.maxStaleDate! > 0 &&
                obj.maxStaleDate! < DateTime.now().millisecondsSinceEpoch) ||
            (obj.maxStaleDate == null &&
                obj.maxAgeDate != null &&
                obj.maxAgeDate! < now)) {
          await db.delete(key);
        }
      }
    }
    return true;
  }

  @override
  Future<bool> clearAll() async {
    var db = await _database;
    if (null == db) return false;
    await db.deleteAll(db.keys);
    return true;
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
