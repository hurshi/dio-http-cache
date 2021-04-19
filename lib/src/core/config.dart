import 'package:dio_http_cache/src/store/store_impl.dart';

class CacheConfig {
  final Duration defaultMaxAge;
  final Duration? defaultMaxStale;
  final String? baseUrl;
  final String defaultRequestMethod;

  final bool skipMemoryCache;
  final bool skipDiskCache;

  final int maxMemoryCacheCount;

  final String? diskSubDir;

  final ICacheStore? diskStore;

  CacheConfig({
    this.defaultMaxAge = const Duration(days: 3),
    this.defaultMaxStale = const Duration(days: 7),
    this.defaultRequestMethod = "POST",
    this.baseUrl,
    this.skipDiskCache = false,
    this.skipMemoryCache = false,
    this.maxMemoryCacheCount = 100,
    this.diskSubDir,
    this.diskStore,
  });
}
