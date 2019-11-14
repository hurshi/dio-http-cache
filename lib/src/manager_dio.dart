import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/src/core/config.dart';
import 'package:dio_http_cache/src/core/manager.dart';
import 'package:dio_http_cache/src/core/obj.dart';

const DIO_CACHE_KEY_MAX_AGE = "dio_cache_max_age";
const DIO_CACHE_KEY_MAX_STALE = "dio_cache_max_stale";
const DIO_CACHE_KEY_PRIMARY_KEY = "dio_cache_primary_key";
const DIO_CACHE_KEY_SUB_KEY = "dio_cache_sub_key";
const DIO_CACHE_KEY_FORCE_REFRESH = "dio_cache_force_refresh";

class DioCacheManager {
  CacheManager _manager;
  InterceptorsWrapper _interceptor;
  String _baseUrl;

  DioCacheManager(CacheConfig config) {
    _manager = CacheManager(config);
    _baseUrl = config.baseUrl;
  }

  /// interceptor for http cache.
  get interceptor {
    if (null == _interceptor) {
      _interceptor = InterceptorsWrapper(
          onRequest: _onRequest, onResponse: _onResponse, onError: _onError);
    }
    return _interceptor;
  }

  _onRequest(RequestOptions options) async {
    if (!options.extra.containsKey(DIO_CACHE_KEY_MAX_AGE)) {
      return options;
    }
    if (true == options.extra[DIO_CACHE_KEY_FORCE_REFRESH]) {
      return options;
    }
    var responseDataFromCache = await _pullFromCacheBeforeMaxAge(options);
    if (null != responseDataFromCache) {
      return _buildResponse(responseDataFromCache?.content,
          responseDataFromCache?.statusCode, options);
    }
    return options;
  }

  _onResponse(Response response) async {
    if (response.request.extra.containsKey(DIO_CACHE_KEY_MAX_AGE) &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      await _pushToCache(response);
    }
    return response;
  }

  _onError(DioError e) async {
    if (e.request.extra.containsKey(DIO_CACHE_KEY_MAX_AGE)) {
      var responseDataFromCache = await _pullFromCacheBeforeMaxStale(e.request);
      if (null != responseDataFromCache)
        return _buildResponse(responseDataFromCache?.content,
            responseDataFromCache?.statusCode, e.request);
    }
    return e;
  }

  Response _buildResponse(String data, int statusCode, RequestOptions options) {
    var headers = Headers();
    options.headers.forEach((k, v) => headers.add(k, v ?? ""));
    return Response(
        data: (options.responseType == ResponseType.json)
            ? jsonDecode(data)
            : data,
        headers: headers,
        extra: options.extra..remove(DIO_CACHE_KEY_MAX_AGE),
        statusCode: statusCode ?? 200);
  }

  Future<CacheObj> _pullFromCacheBeforeMaxAge(RequestOptions options) {
    return _manager?.pullFromCacheBeforeMaxAge(
        _getPrimaryKeyFromOptions(options),
        subKey: _getSubKeyFromOptions(options));
  }

  Future<CacheObj> _pullFromCacheBeforeMaxStale(RequestOptions options) {
    return _manager?.pullFromCacheBeforeMaxStale(
        _getPrimaryKeyFromOptions(options),
        subKey: _getSubKeyFromOptions(options));
  }

  Future<bool> _pushToCache(Response response) {
    RequestOptions options = response.request;
    Duration maxAge = options.extra[DIO_CACHE_KEY_MAX_AGE];
    Duration maxStale = options.extra[DIO_CACHE_KEY_MAX_STALE];
    var obj = CacheObj(
        _getPrimaryKeyFromOptions(options), jsonEncode(response.data),
        subKey: _getSubKeyFromOptions(options),
        maxAge: maxAge,
        maxStale: maxStale);
    return _manager?.pushToCache(obj);
  }

  String _getPrimaryKeyFromOptions(RequestOptions options) {
    return options.extra.containsKey(DIO_CACHE_KEY_PRIMARY_KEY)
        ? options.extra[DIO_CACHE_KEY_PRIMARY_KEY]
        : _getPrimaryKeyFromUri(options.uri);
  }

  String _getSubKeyFromOptions(RequestOptions options) {
    return options.extra.containsKey(DIO_CACHE_KEY_SUB_KEY)
        ? options.extra[DIO_CACHE_KEY_SUB_KEY]
        : _getSubKeyFromUri(options.uri, data: options.data);
  }

  String _getPrimaryKeyFromUri(Uri uri) => "${uri?.host}${uri?.path}";

  String _getSubKeyFromUri(Uri uri, {dynamic data}) =>
      "${data?.toString()}_${uri?.query}";

  /// delete local cache by primaryKey and optional subKey
  Future<bool> delete(String primaryKey, {String subKey}) =>
      _manager?.delete(primaryKey, subKey: subKey);

  /// no matter what subKey is, delete local cache if primary matched.
  Future<bool> deleteByPrimaryKeyWithUri(Uri uri) =>
      delete(_getPrimaryKeyFromUri(uri));

  Future<bool> deleteByPrimaryKey(String path) =>
      deleteByPrimaryKeyWithUri(_getUriByPath(_baseUrl, path));

  /// delete local cache when both primaryKey and subKey matched.
  Future<bool> deleteByPrimaryKeyAndSubKeyWithUri(Uri uri,
          {String subKey, dynamic data}) =>
      delete(_getPrimaryKeyFromUri(uri),
          subKey: subKey ?? _getSubKeyFromUri(uri, data: data));

  Future<bool> deleteByPrimaryKeyAndSubKey(String path,
          {Map<String, dynamic> queryParameters,
          String subKey,
          dynamic data}) =>
      deleteByPrimaryKeyAndSubKeyWithUri(
          _getUriByPath(_baseUrl, path,
              data: data, queryParameters: queryParameters),
          subKey: subKey,
          data: data);

  /// clear all expired cache.
  Future<bool> clearExpired() => _manager?.clearExpired();

  /// empty local cache.
  Future<bool> clearAll() => _manager?.clearAll();

  Uri _getUriByPath(String baseUrl, String path,
      {dynamic data, Map<String, dynamic> queryParameters}) {
    if (!path.startsWith(new RegExp(r"https?:"))) {
      assert(null != baseUrl && baseUrl.length > 0);
    }
    return RequestOptions(
            baseUrl: baseUrl,
            path: path,
            data: data,
            queryParameters: queryParameters)
        .uri;
  }
}
