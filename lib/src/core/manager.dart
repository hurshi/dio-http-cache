import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio_http_cache/src/core/config.dart';
import 'package:dio_http_cache/src/core/obj.dart';
import 'package:dio_http_cache/src/core/store.dart';
import 'package:sqflite/utils/utils.dart';

class CacheManager {
  CacheConfig _config;
  DiskCacheStore _diskCacheStore;
  MemoryCacheStore _memoryCacheStore;
  MD5 _md5;
  Utf8Encoder _utf8encoder;

  CacheManager(this._config) {
    _md5 = md5;
    _utf8encoder = const Utf8Encoder();
    if (!_config.skipDiskCache) _diskCacheStore = DiskCacheStore(_config);
    if (!_config.skipMemoryCache) _memoryCacheStore = MemoryCacheStore(_config);
  }

  Future<CacheObj> _pullFromCache(String key, {String subKey}) async {
    key = _convertMd5(key);
    if (null != subKey) subKey = _convertMd5(subKey);
    var obj = await _memoryCacheStore?.getCacheObj(key, subKey: subKey);
    if (null == obj) {
      obj = await _diskCacheStore?.getCacheObj(key, subKey: subKey);
      if (null != obj) _memoryCacheStore?.setCacheObj(obj);
    }
    if (null != obj) {
      if (null != obj.maxStaleDate && obj.maxStaleDate > 0) {
        //if maxStaleDate exist, Remove it if maxStaleDate expired.
        if (obj.maxStaleDate < DateTime.now().millisecondsSinceEpoch) {
          delete(key, subKey: subKey);
          return null;
        }
      } else {
        //if maxStaleDate NOT exist, Remove it if maxAgeDate expired.
        if (obj.maxAgeDate < DateTime.now().millisecondsSinceEpoch) {
          delete(key, subKey: subKey);
          return null;
        }
      }
    }
    return obj;
  }

  Future<String> pullFromCacheBeforeMaxAge(String key, {String subKey}) {
    return _pullFromCache(key, subKey: subKey).then((obj) {
      if (null != obj &&
          null != obj.maxAgeDate &&
          obj.maxAgeDate < DateTime.now().millisecondsSinceEpoch) {
        return null;
      }
      return obj?.content;
    });
  }

  Future<String> pullFromCacheBeforeMaxStale(String key, {String subKey}) {
    return _pullFromCache(key, subKey: subKey).then((obj) {
      return obj?.content;
    });
  }

  pushToCache(CacheObj obj) {
    obj.key = _convertMd5(obj.key);
    if (null != obj.subKey) obj.subKey = _convertMd5(obj.subKey);

    if (null == obj.maxAgeDate || obj.maxAgeDate <= 0) {
      obj.maxAge = _config.defaultMaxAge;
    }
    if ((null == obj.maxStaleDate || obj.maxStaleDate <= 0) &&
        null != _config.defaultMaxStale) {
      obj.maxStale = _config.defaultMaxStale;
    }
    _memoryCacheStore?.setCacheObj(obj);
    _diskCacheStore?.setCacheObj(obj);
  }

  delete(String key, {String subKey}) {
    key = _convertMd5(key);
    if (null != subKey) subKey = _convertMd5(subKey);

    _memoryCacheStore?.delete(key, subKey: subKey);
    _diskCacheStore?.delete(key, subKey: subKey);
  }

  clearExpired() {
    _memoryCacheStore?.clearExpired();
    _diskCacheStore?.clearExpired();
  }

  String _convertMd5(String str) {
    return hex(_md5.convert(_utf8encoder.convert(str)).bytes);
  }
}
