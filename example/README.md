# dio-http-cache

[中文介绍](./README_zh.md)

Dio-http-cache is a cache library for [Dio ( http client for flutter )](https://github.com/flutterchina/dio), like [Rxcache](https://github.com/VictorAlbertos/RxCache) in Android.

Dio-http-cache uses [sqflite](https://github.com/tekartik/sqflite) as  disk cache, and  [LRU](https://github.com/google/quiver-dart) strategy as memory cache.

Inspired by [flutter_cache_manager](https://github.com/renefloor/flutter_cache_manager).

### Add Dependency

```yaml
dio_http_cache: ^0.1.1
```

### QuickStart

1. Add a dio-http-cache interceptor in Dio :

   ```dart
   dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
   ```

2. Set maxAge for a request :

   ```dart
   Dio().get(
     "http://www.google.com",
     options: buildCacheOptions(Duration(days: 7)),
   );
   ```

### The advanced

1. **Custom your config by buildCacheOptions :**
   1. ***MaxAge***: the only required param, set the cache time;
   2. ***MaxStale***: set stale time. when error occur (like 500,404),try to return cache before maxStale.
   3. ***subKey***: dio-http-cache use url as **key**,you can add a subKey when necessary, such as different params with the same request.

2. **Use "CacheConfig" to config default params**

   1. ***encrypt / decrypt:***  These two must be used together to encrypt the disk cache data, use base64 as default.
   2. ***DefaultMaxAge:***  use `Duration(day:7)` as default.
   3. ***DefaultaMaxStale:*** just like DefaultMaxAge
   4. ***DatabaseName:*** database name.
   5. ***SkipMemoryCache:*** false defalut.
   6. ***SkipDiskCache:*** false default.
   7. ***MaxMemoryCacheCount:*** 100 defalut.

3. **How to clear expired cache**

   1. Just ignore it,this is automatic.
   2. But if you must do it: `DioCacheManager.clearExpired();`

4. **How to delete one cache**

   ```
   DioCacheManager.delete(url); //delete all the cache with url as the key
   DioCacheManager.delete(url,subKey);
   ```

5. **How to clear All caches**

   ```
   DioCacheManager.clearAll();
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
