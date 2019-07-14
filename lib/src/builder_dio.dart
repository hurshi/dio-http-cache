import 'package:dio/dio.dart';
import 'package:dio_http_cache/src/manager_dio.dart';

Options buildCacheOptions(Duration maxAge, {Options options, String subKey, Duration maxStale}) {
  if (null == options) options = Options();
  options.extra.addAll({DIO_CACHE_KEY_MAX_AGE: maxAge});
  if (null != subKey) options.extra.addAll({DIO_CACHE_KEY_SUB_KEY: subKey});
  if (null != maxStale) options.extra.addAll({DIO_CACHE_KEY_MAX_STALE: maxStale});
  return options;
}
