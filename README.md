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
   
   2. ***MaxStale***: set stale time. When an error (like 500,404) occurs before maxStale, try to return cache .
   
      ```dart
      buildCacheOptions(Duration(days: 7), maxStale: Duration(days: 10))
      ```
   
   3. ***subKey***: dio-http-cache uses url as **key**,you can add a subKey when it's necessary, such as one request with different params.
   
      ```dart
      buildCacheOptions(Duration(days: 7), subKey: "page=1")
      ```
   
2. **Use "CacheConfig" to config default params**
  
   1. ***encrypt / decrypt:***  These two must be used together to encrypt the disk cache data, otherwise use base64 as default.
   2. ***DefaultMaxAge:***  use `Duration(day:7)` as default.
   3. ***DefaultaMaxStale:*** similar with DefaultMaxAge.
   4. ***DatabaseName:*** database name.
   5. ***SkipMemoryCache:*** false defalut.
   6. ***SkipDiskCache:*** false default.
   7. ***MaxMemoryCacheCount:*** 100 defalut.
   
3. **How to clear expired cache**

   * Just ignore it, that is automatic.

   * But if you insist : `DioCacheManager.clearExpired();`

4. **How to delete one cache**

   ```
   _dioCacheManager.delete(url); //delete all the cache with url as the key
   _dioCacheManager.delete(url,subKey);
   ```

5. **How to clear All caches** (expired or not)

   ```
   _dioCacheManager.clearAll();
   ```

###  Example for maxAge and maxStale

```dart
_dio.post(
	"https://www.exmaple.com",
	data: {'k': "keyword"},
  options:buildCacheOptions(
  	Duration(days: 3), 
  	maxStale: Duration(days: 7), 
  )
)
```

1. 0 ~ 3 days : Return data from cache directly (irrelevant with network).
2. 3 ~ 7 days: 
   1. Get data from network first.
   2. If getting data from network succeeds, refresh cache.
   3. If getting data from network fails or no network avaliable, get data from cache instead of an error.
3. 7 ~ ∞ days: It won't use cache anymore, and the cache will be deleted at the right time.

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
