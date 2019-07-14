### 简介

* Dio-cache 是 Flutter 的 http 缓存库，为 [Dio](https://github.com/flutterchina/dio) 设计，就像 Android 中的 [RxCache](https://github.com/VictorAlbertos/RxCache) 一样；

* Dio-cache 使用 [sqflite](https://github.com/tekartik/sqflite) 作为磁盘缓存，使用 [Google/quiver-dart 的LRU算法](https://github.com/google/quiver-dart) 作为内存缓存策略；
* 有参考 [flutter_cache_manager](https://github.com/renefloor/flutter_cache_manager) 开发，为此感谢.

### 添加依赖

```yaml
dio_cache:
    git:
      url: https://github.com/hurshi/dio-cache
```

### 简单使用

1. 为 dio 添加拦截器：

   ```dart
   dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
   ```

2. 为需要缓存的请求添加 options:

   ```dart
   Dio().get(
     "http://www.google.com",
     options: buildCacheOptions(Duration(days: 7)),
   );
   ```

### 进阶使用

1. buildCacheOptions可以配置多种参数满足不同的缓存需求：
   1. MaxAge: 只有这个是必须的参数，设置缓存的时间；
   2. MaxStale: 设置过期时常，在maxAge过期，而请求网络**失败**的时候，如果maxStale没有过期，则会使用这个缓存数据。
   3. subKey: cache_dio 默认使用 url 作为缓存 key ,但当 url 不够用的时候，比如 post 请求不同参数比如分页的时候，就需要配合subKey使用。
2. CacheConfig 可以配置一些默认参数：
   1. encrypt / dectrypt : 这2个必须组合使用，实现磁盘缓存数据的加密，如果没有设置加密，默认会用 base64 重新编码再存到数据库。
   2. DefaultMaxAge: 默认值为 Duration( day: 7 ), 在上面 buildCacheOption 中如果没有配置 MaxAge 有错误，或者自己实现了 option 而没有配置 MaxAge, 会使用这个默认值；
   3. DefalutMaxStale: 和 DefaultMaxAge 类似；
   4. DatabaseName: 配置数据库名；
   5. SkipMemoryCache: 默认 false；
   6. SkipDiskCache: 默认 false;
   7. MaxMemoryCacheCount: 最大的内存缓存数量，默认100；