[![Pub](https://img.shields.io/pub/v/dio_http_cache.svg?style=flat)](https://pub.dev/packages/dio_http_cache) 

### 简介

* Dio-http-cache 是 Flutter 的 http 缓存库，为 [Dio](https://github.com/flutterchina/dio) 设计，就像 Android 中的 [RxCache](https://github.com/VictorAlbertos/RxCache) 一样。
* Dio-http-cache 使用 [sqflite](https://github.com/tekartik/sqflite) 作为磁盘缓存，使用 [Google/quiver-dart 的LRU算法](https://github.com/google/quiver-dart) 作为内存缓存策略。
* 有参考 [flutter_cache_manager](https://github.com/renefloor/flutter_cache_manager) 开发，为此感谢。
* **更详细**且**最新**的文档还请参阅 [README](https://github.com/hurshi/dio-http-cache)。

### 添加依赖

```yaml
dependencies:
  dio_http_cache: ^0.3.x #latest version
```

### 简单使用

1. 为 dio 添加拦截器：

   ```dart
   dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: "http://www.google.com")).interceptor);
   ```

2. 为需要缓存的请求添加 options:

   ```dart
   Dio().get(
     "http://www.google.com",
     options: buildCacheOptions(Duration(days: 7)),
   );
   ```

### 进阶使用

1. **buildCacheOptions可以配置多种参数满足不同的缓存需求：**
   1. ***MaxAge:*** 只有这个是必须的参数，设置缓存的时间；
   
   2. ***MaxStale:*** 设置过期时常；在maxAge过期，而请求网络**失败**的时候，如果maxStale没有过期，则会使用这个缓存数据。
   
      ```dart
      buildCacheOptions(Duration(days: 7), maxStale: Duration(days: 10))
      ```
   
   3. ***subKey:*** dio-http-cache 默认使用 url 作为缓存 key ,但当 url 不够用的时候，比如 post 请求分页数据的时候，就需要配合subKey使用。
   
      ```dart
      buildCacheOptions(Duration(days: 7), subKey: "page=1")
      ```
   
2. **CacheConfig 可以配置一些默认参数：**
   1. ***encrypt / dectrypt:*** 这2个必须组合使用，实现磁盘缓存数据的加密。也可以在这里实现数据的压缩。
   2. ***DefaultMaxAge:*** 默认值为 Duration( day: 7 ), 在上面 buildCacheOption 中如果没有配置 MaxAge 有错误，或者自己实现了 option 而没有配置 MaxAge, 会使用这个默认值；
   3. ***DefalutMaxStale:*** 和 DefaultMaxAge 类似；
   4. ***DatabaseName:*** 配置数据库名；
   5. ***SkipMemoryCache:*** 默认 false；
   6. ***SkipDiskCache:*** 默认 false;
   7. ***MaxMemoryCacheCount:*** 最大的内存缓存数量，默认100；
   
3. **如何清理已过期缓存**

   * 会自动清理不用管
   * 如果非要清理，可以调用：`DioCacheManager.clearExpired();`

4. **如何删除一条记录**

   ```
   _dioCacheManager.delete(url);//会删除所有 url 的缓存。
   _dioCacheManager.delete(url,subKey);
   ```

5. **如何清理所有缓存**（不管有没有过期）

   ```
   _dioCacheManager.clearAll();
   ```

### License

   ```
Copyright 2019 Hurshi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
   ```
