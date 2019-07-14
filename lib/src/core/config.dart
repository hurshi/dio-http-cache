typedef Future<String> Encrypt(String str);
typedef Future<String> Decrypt(String str);

class CacheConfig {
  Duration defaultMaxAge;
  Duration defaultMaxStale;
  String databaseName;

  bool skipMemoryCache;
  bool skipDiskCache;

  int maxMemoryCacheCount;

  Encrypt encrypt;
  Decrypt decrypt;

  CacheConfig(
      {this.defaultMaxAge = const Duration(days: 7),
      this.defaultMaxStale,
      this.databaseName = "DioCache",
      this.skipDiskCache = false,
      this.skipMemoryCache = false,
      this.maxMemoryCacheCount = 100,
      this.encrypt,
      this.decrypt});
}
