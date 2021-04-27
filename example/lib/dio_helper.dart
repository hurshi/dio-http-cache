import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class DioHelper {
  static Dio? _dio;
  static DioCacheManager? _manager;
  static final baseUrl = "https://www.wanandroid.com/";

  static Dio getDio() {
    if (null == _dio) {
      _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          contentType: "application/x-www-form-urlencoded; charset=utf-8"))
//        ..httpClientAdapter = _getHttpClientAdapter()
        ..interceptors.add(getCacheManager().interceptor)
        ..interceptors.add(LogInterceptor(responseBody: true));
    }
    return _dio!;
  }

  static DioCacheManager getCacheManager() {
    if (null == _manager) {
      _manager =
          DioCacheManager(CacheConfig(baseUrl: "https://www.wanandroid.com/"));
    }
    return _manager!;
  }

  // set proxy
  static DefaultHttpClientAdapter _getHttpClientAdapter() {
    DefaultHttpClientAdapter httpClientAdapter;
    httpClientAdapter = DefaultHttpClientAdapter();
    httpClientAdapter.onHttpClientCreate = (HttpClient client) {
      client.findProxy = (uri) {
        return 'PROXY 10.0.0.103:6152';
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    return httpClientAdapter;
  }
}
