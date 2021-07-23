## [0.3.0] - 2021-03-23

* Migrated to nullsatefy with Dart 2.12
* Updated compatibility woth Dio 4 interceptors

## [0.2.11] - 2020-09-24
* Support for custom disk storage.

## [0.2.9] - 2020-09-15
* Support database path custom config.
* Add flag in Response headers to distinguish whether the data is coming from the cache.

## [0.2.8] - 2020-07-18

* Fix issue [#37](https://github.com/hurshi/dio-http-cache/issues/41), fix request method in primaryKey, and add request method in delete caches.
* WARNING: request method is needed when you delete one cache, or set defaultRequestMethod in CacheConfig.

## [0.2.7] - 2020-06-04

* Fix issue [#37](https://github.com/hurshi/dio-http-cache/issues/30), add request method to primaryKey.

## [0.2.6] - 2020-02-05

* Fix issue [#30](https://github.com/hurshi/dio-http-cache/issues/30), default maxAge ignored.
* Fix issue [#24](https://github.com/hurshi/dio-http-cache/issues/24), Resolve the crash parsing of the Response head.

## [0.2.5] - 2019-11-26

* Support ResponseType.bytes.
* Cache all headers.
* Change cache data type from TEXT to BLOB.
* WARNING: Because of the change in the database data type, when upgrading to this version, the data cached by the previous version will be erased.

## [0.2.4] - 2019-11-16

* Support for get maxAge and maxStale from response headers.
* Improve example codes.

## [0.2.3] - 2019-11-14

* Store cache only when response statusCode in 200 ~ 300.
* Support for store statusCode.
* Improve example codes.

## [0.2.2] - 2019-11-14

* Store cache only when response statusCode equals 200.

## [0.2.1] - 2019-10-29

* Fix crash for null value in headers

## [0.2.0] - 2019-09-20

* Support for dio 3.0

## [0.1.4] - 2019-09-17

* Fix bug for remove memory cache by primary key


## [0.1.3] - 2019-08-21

* Change primaryKey to "host + path", and automatically use queryParams as the subKey.
* Support for delete caches by primaryKey. (Parsing primaryKey from path).
* Support for delete one cache by primaryKey and subKey. (Parsing primaryKey and subKey from path).


## [0.1.2] - 2019-08-06

* Return Future<bool> for function delete, expire and so on.
* Returns statusCode=200 if data was retrieved from the cache successfully.
* Support for forced data refresh from the network.       


## [0.1.1] - 2019-07-24

* Support delete all cache.


## [0.1.0] - 2019-07-14

* This is a pre-release version.
* Support disk cache.
* Support memory cache.
* Support key and subKey.
* Support maxAge and maxStale.
