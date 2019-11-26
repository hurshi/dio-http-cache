typedef Future<List<int>> Encrypt(List<int> str);
typedef Future<List<int>> Decrypt(List<int> str);

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
