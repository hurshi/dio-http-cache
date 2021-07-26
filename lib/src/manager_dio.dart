import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/src/core/config.dart';
import 'package:dio_http_cache/src/core/manager.dart';
import 'package:dio_http_cache/src/core/obj.dart';

const DIO_CACHE_KEY_TRY_CACHE = "dio_cache_try_cache";
const DIO_CACHE_KEY_MAX_AGE = "dio_cache_max_age";
const DIO_CACHE_KEY_MAX_STALE = "dio_cache_max_stale";
const DIO_CACHE_KEY_PRIMARY_KEY = "dio_cache_primary_key";
const DIO_CACHE_KEY_SUB_KEY = "dio_cache_sub_key";
const DIO_CACHE_KEY_FORCE_REFRESH = "dio_cache_force_refresh";
const DIO_CACHE_HEADER_KEY_DATA_SOURCE = "dio_cache_header_key_data_source";

typedef _ParseHeadCallback = void Function(
    Duration? _maxAge, Duration? _maxStale);

class DioCacheManager {
  late CacheManager _manager;
  InterceptorsWrapper? _interceptor;
  late String? _baseUrl;
  late String _defaultRequestMethod;

  DioCacheManager(CacheConfig config) {
    _manager = CacheManager(config);
    _baseUrl = config.baseUrl;
    _defaultRequestMethod = config.defaultRequestMethod;
  }

  /// interceptor for http cache.
  get interceptor {
    if (null == _interceptor) {
      _interceptor = InterceptorsWrapper(
          onRequest: _onRequest, onResponse: _onResponse, onError: _onError);
    }
    return _interceptor;
  }

  _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if ((options.extra[DIO_CACHE_KEY_TRY_CACHE] ?? false) != true) {
      return handler.next(options);
    }
    if (true == options.extra[DIO_CACHE_KEY_FORCE_REFRESH]) {
      return handler.next(options);
    }
    var responseDataFromCache = await _pullFromCacheBeforeMaxAge(options);
    if (null != responseDataFromCache) {
      return handler.resolve(
          _buildResponse(
              responseDataFromCache, responseDataFromCache.statusCode, options),
          true);
    }
    return handler.next(options);
  }

  _onResponse(Response response, ResponseInterceptorHandler handler) async {
    if ((response.requestOptions.extra[DIO_CACHE_KEY_TRY_CACHE] ?? false) ==
            true &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      await _pushToCache(response);
    }
    return handler.next(response);
  }

  _onError(DioError e, ErrorInterceptorHandler handler) async {
    if ((e.requestOptions.extra[DIO_CACHE_KEY_TRY_CACHE] ?? false) == true) {
      var responseDataFromCache =
          await _pullFromCacheBeforeMaxStale(e.requestOptions);
      if (null != responseDataFromCache) {
        var response = _buildResponse(responseDataFromCache,
            responseDataFromCache.statusCode, e.requestOptions);

        return handler.resolve(response);
      }
    }
    return handler.next(e);
  }

  Response _buildResponse(
      CacheObj obj, int? statusCode, RequestOptions options) {
    Headers? headers;
    if (null != obj.headers) {
      headers = Headers.fromMap((Map<String, List<dynamic>>.from(
              jsonDecode(utf8.decode(obj.headers!))))
          .map((k, v) => MapEntry(k, List<String>.from(v))));
    }
    if (null == headers) {
      headers = Headers();
      options.headers.forEach((k, v) => headers!.add(k, v ?? ""));
    }
    // add flag
    headers.add(DIO_CACHE_HEADER_KEY_DATA_SOURCE, "from_cache");
    dynamic data = obj.content;
    if (options.responseType != ResponseType.bytes) {
      data = jsonDecode(utf8.decode(data));
    }
    return Response(
        data: data,
        headers: headers,
        requestOptions: options.copyWith(
            extra: options.extra..remove(DIO_CACHE_KEY_TRY_CACHE)),
        statusCode: statusCode ?? 200);
  }

  Future<CacheObj?> _pullFromCacheBeforeMaxAge(RequestOptions options) {
    return _manager.pullFromCacheBeforeMaxAge(
        _getPrimaryKeyFromOptions(options),
        subKey: _getSubKeyFromOptions(options));
  }

  Future<CacheObj?> _pullFromCacheBeforeMaxStale(RequestOptions options) {
    return _manager.pullFromCacheBeforeMaxStale(
        _getPrimaryKeyFromOptions(options),
        subKey: _getSubKeyFromOptions(options));
  }

  Future<bool> _pushToCache(Response response) {
    RequestOptions options = response.requestOptions;
    Duration? maxAge = options.extra[DIO_CACHE_KEY_MAX_AGE];
    Duration? maxStale = options.extra[DIO_CACHE_KEY_MAX_STALE];
    if (null == maxAge) {
      _tryParseHead(response, maxStale, (_maxAge, _maxStale) {
        maxAge = _maxAge;
        maxStale = _maxStale;
      });
    }
    List<int>? data;
    if (options.responseType == ResponseType.bytes) {
      data = response.data;
    } else {
      data = utf8.encode(jsonEncode(response.data));
    }
    var obj = CacheObj(_getPrimaryKeyFromOptions(options), data!,
        subKey: _getSubKeyFromOptions(options),
        maxAge: maxAge,
        maxStale: maxStale,
        statusCode: response.statusCode,
        headers: utf8.encode(jsonEncode(response.headers.map)));
    return _manager.pushToCache(obj);
  }

  // try to get maxAge and maxStale from http headers
  void _tryParseHead(
      Response response, Duration? maxStale, _ParseHeadCallback callback) {
    Duration? _maxAge;
    var cacheControl = response.headers.value(HttpHeaders.cacheControlHeader);
    if (null != cacheControl) {
      // try to get maxAge and maxStale from cacheControl
      Map<String, String?> parameters;
      try {
        parameters = HeaderValue.parse(
                "${HttpHeaders.cacheControlHeader}: $cacheControl",
                parameterSeparator: ",",
                valueSeparator: "=")
            .parameters;
        _maxAge = _tryGetDurationFromMap(parameters, "s-maxage");
        if (null == _maxAge) {
          _maxAge = _tryGetDurationFromMap(parameters, "max-age");
        }
        // if maxStale has valued, don't get max-stale anymore.
        if (null == maxStale) {
          maxStale = _tryGetDurationFromMap(parameters, "max-stale");
        }
      } catch (e) {
        print(e);
      }
    } else {
      // try to get maxAge from expires
      var expires = response.headers.value(HttpHeaders.expiresHeader);
      if (null != expires && expires.length > 4) {
        DateTime? endTime;
        try {
          endTime = HttpDate.parse(expires).toLocal();
        } catch (e) {
          print(e);
        }
        if (null != endTime && endTime.compareTo(DateTime.now()) >= 0) {
          _maxAge = endTime.difference(DateTime.now());
        }
      }
    }
    callback(_maxAge, maxStale);
  }

  Duration? _tryGetDurationFromMap(
      Map<String, String?> parameters, String key) {
    if (parameters.containsKey(key)) {
      var value = int.tryParse(parameters[key]!);
      if (null != value && value >= 0) {
        return Duration(seconds: value);
      }
    }
    return null;
  }

  String _getPrimaryKeyFromOptions(RequestOptions options) {
    var primaryKey = options.extra.containsKey(DIO_CACHE_KEY_PRIMARY_KEY)
        ? options.extra[DIO_CACHE_KEY_PRIMARY_KEY]
        : _getPrimaryKeyFromUri(options.uri);

    return "${_getRequestMethod(options.method)}-$primaryKey";
  }

  String _getRequestMethod(String? requestMethod) {
    if (null != requestMethod && requestMethod.length > 0) {
      return requestMethod.toUpperCase();
    }
    return _defaultRequestMethod.toUpperCase();
  }

  String? _getSubKeyFromOptions(RequestOptions options) {
    return options.extra.containsKey(DIO_CACHE_KEY_SUB_KEY)
        ? options.extra[DIO_CACHE_KEY_SUB_KEY]
        : _getSubKeyFromUri(options.uri, data: options.data);
  }

  String _getPrimaryKeyFromUri(Uri uri) => "${uri.host}${uri.path}";

  String _getSubKeyFromUri(Uri uri, {dynamic data}) =>
      "${data?.toString()}_${uri.query}";

  /// delete local cache by primaryKey and optional subKey
  Future<bool> delete(String primaryKey,
          {String? requestMethod, String? subKey}) =>
      _manager.delete("${_getRequestMethod(requestMethod)}-$primaryKey",
          subKey: subKey);

  /// no matter what subKey is, delete local cache if primary matched.
  Future<bool> deleteByPrimaryKeyWithUri(Uri uri, {String? requestMethod}) =>
      delete(_getPrimaryKeyFromUri(uri), requestMethod: requestMethod);

  Future<bool> deleteByPrimaryKey(String path, {String? requestMethod}) =>
      deleteByPrimaryKeyWithUri(_getUriByPath(_baseUrl, path),
          requestMethod: requestMethod);

  /// delete local cache when both primaryKey and subKey matched.
  Future<bool> deleteByPrimaryKeyAndSubKeyWithUri(Uri uri,
          {String? requestMethod, String? subKey, dynamic data}) =>
      delete(_getPrimaryKeyFromUri(uri),
          requestMethod: requestMethod,
          subKey: subKey ?? _getSubKeyFromUri(uri, data: data));

  Future<bool> deleteByPrimaryKeyAndSubKey(String path,
          {String? requestMethod,
          Map<String, dynamic>? queryParameters,
          String? subKey,
          dynamic data}) =>
      deleteByPrimaryKeyAndSubKeyWithUri(
          _getUriByPath(_baseUrl, path,
              data: data, queryParameters: queryParameters),
          requestMethod: requestMethod,
          subKey: subKey,
          data: data);

  /// clear all expired cache.
  Future<bool> clearExpired() => _manager.clearExpired();

  /// empty local cache.
  Future<bool> clearAll() => _manager.clearAll();

  Uri _getUriByPath(String? baseUrl, String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) {
    if (!path.startsWith(RegExp(r"https?:"))) {
      assert(baseUrl != null && baseUrl.length > 0);
    }
    return RequestOptions(
            baseUrl: baseUrl,
            path: path,
            data: data,
            queryParameters: queryParameters)
        .uri;
  }
}
