import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dio/io.dart';

class DioHelper {
  static Dio? _dio;
  static DioCacheManager? _manager;
  static const baseUrl = "https://www.wanandroid.com/";

  static Dio getDio() {
    _dio ??= Dio(BaseOptions(
        baseUrl: baseUrl,
        contentType: "application/x-www-form-urlencoded; charset=utf-8"))
//        ..httpClientAdapter = _getHttpClientAdapter()
      ..interceptors.add(getCacheManager().interceptor)
      ..interceptors.add(LogInterceptor(responseBody: true));
    return _dio!;
  }

  static DioCacheManager getCacheManager() {
    _manager ??= DioCacheManager(CacheConfig(
        baseUrl: "https://www.wanandroid.com/", skipMemoryCache: true));
    return _manager!;
  }

  // set proxy
  // ignore: unused_element
  static IOHttpClientAdapter _getHttpClientAdapter() {
    IOHttpClientAdapter httpClientAdapter;
    httpClientAdapter = IOHttpClientAdapter();
    httpClientAdapter.onHttpClientCreate = (HttpClient client) {
      client.findProxy = (uri) {
        return 'PROXY 10.0.0.103:6152';
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return client;
    };
    return httpClientAdapter;
  }
}
