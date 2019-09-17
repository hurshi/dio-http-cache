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
* support disk cache.
* support memory cache.
* support key and subKey.
* support maxAge and maxStale.
