typedef Future<String> Encrypt(String str);
typedef Future<String> Decrypt(String str);

class CacheConfig {
  final Duration defaultMaxAge;
  final Duration defaultMaxStale;
  final String databaseName;
  final String baseUrl;

  final bool skipMemoryCache;
  final bool skipDiskCache;

  final int maxMemoryCacheCount;

  final Encrypt encrypt;
  final Decrypt decrypt;

  CacheConfig(
      {this.defaultMaxAge = const Duration(days: 7),
      this.defaultMaxStale,
      this.databaseName = "DioCache",
      this.baseUrl,
      this.skipDiskCache = false,
      this.skipMemoryCache = false,
      this.maxMemoryCacheCount = 100,
      this.encrypt,
      this.decrypt});
}
