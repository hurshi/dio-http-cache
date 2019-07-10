# dio-cache

Dio-cache is a cache library for [Dio ( http client for flutter )](https://github.com/flutterchina/dio), like [Rxcache](https://github.com/VictorAlbertos/RxCache) in Android.

Dio-cache uses [sqflite](https://github.com/tekartik/sqflite) as  disk cache, and  [LRU](https://github.com/google/quiver-dart) strategy as memory cache.

Inspired by [flutter_cache_manager](https://github.com/renefloor/flutter_cache_manager).

### Add Dependency

```
dio_cache:
    git:
      url: https://github.com/hurshi/dio-cache
```

### QuickStart

1. Add a dio-cache interceptor in Dio :

   ```
   dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
   ```

2. Set maxAge for a request :

   ```
   Dio().get(
     "http://www.google.com",
     options: buildCacheOptions(Duration(days: 7)),
   );
   ```

### The advanced

1. **MaxAge**: return cache directly before maxAge.

2. **StaleAge**: when errors occur, try to return cache before staleAge.

   ```
   buildCacheOptions(Duration(days: 7), staleAge: Duration(days: 10))
   ```

3. **encrypt / decrypt**: custom encrypt config with `CacheConfig`.

4. **subKey**: dio-cache use url as key, you can add a subKey when necessary, such as different params with the same request.

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
