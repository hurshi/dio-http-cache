import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache/src/core/config.dart';
import 'package:dio_cache/src/core/manager.dart';
import 'package:dio_cache/src/core/obj.dart';

const DIO_CACHE_KEY_MAX_AGE = "dio_cache_max_age";
const DIO_CACHE_KEY_MAX_STALE = "dio_cache_max_stale";
const DIO_CACHE_KEY_SUB_KEY = "dio_cache_sub_key";

class DioCacheManager {
  CacheManager _manager;
  InterceptorsWrapper _interceptor;

  DioCacheManager(CacheConfig config) {
    _manager = CacheManager(config);
  }

  get interceptor {
    if (null == _interceptor) {
      _interceptor = InterceptorsWrapper(onRequest: _onRequest, onResponse: _onResponse, onError: _onError);
    }
    return _interceptor;
  }

  _onRequest(RequestOptions options) async {
    if (options.extra.containsKey(DIO_CACHE_KEY_MAX_AGE)) {
      var responseDataFromCache = await _pullFromCacheBeforeMaxAge(options);
      if (null != responseDataFromCache) return _buildResponse(responseDataFromCache, options);
    }
    return options;
  }

  _onResponse(Response response) {
    if (response.request.extra.containsKey(DIO_CACHE_KEY_MAX_AGE)) {
      _pushToCache(response);
    }
    return response;
  }

  _onError(DioError e) async {
    if (e.request.extra.containsKey(DIO_CACHE_KEY_MAX_AGE)) {
      var responseDataFromCache = await _pullFromCacheBeforeMaxStale(e.request);
      if (null != responseDataFromCache) return _buildResponse(responseDataFromCache, e.request);
    }
    return e;
  }

  Response _buildResponse(String data, RequestOptions options) {
    return Response(
        data: data,
        headers: DioHttpHeaders.fromMap(options.headers),
        extra: options.extra..remove(DIO_CACHE_KEY_MAX_AGE));
  }

  Future<String> _pullFromCacheBeforeMaxAge(RequestOptions options) {
    return _manager.pullFromCacheBeforeMaxAge(options.uri.toString(), subKey: options.extra[DIO_CACHE_KEY_SUB_KEY]);
  }

  Future<String> _pullFromCacheBeforeMaxStale(RequestOptions options) {
    return _manager.pullFromCacheBeforeMaxStale(options.uri.toString(), subKey: options.extra[DIO_CACHE_KEY_SUB_KEY]);
  }

  _pushToCache(Response response) {
    RequestOptions options = response.request;
    Duration maxAge = options.extra[DIO_CACHE_KEY_MAX_AGE];
    Duration maxStale = options.extra[DIO_CACHE_KEY_MAX_STALE];
    var obj = CacheObj(options.uri.toString(), jsonEncode(response.data),
        subKey: options.extra[DIO_CACHE_KEY_SUB_KEY], maxAge: maxAge, maxStale: maxStale);
    _manager.pushToCache(obj);
  }

  delete(String key, {String subKey}) => _manager.delete(key, subKey: subKey);

  clearExpired() => _manager.clearExpired();
}
