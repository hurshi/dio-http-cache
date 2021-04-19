import 'package:hive/hive.dart';

part 'cache_obj.g.dart';

@HiveType(typeId: 0)
class CacheObj {
  @HiveField(0)
  String key;

  @HiveField(1)
  String? subKey;

  @HiveField(2)
  int? maxAgeDate;

  @HiveField(3)
  int? maxStaleDate;

  @HiveField(4)
  List<int>? content;

  @HiveField(5)
  int? statusCode;

  @HiveField(6)
  List<int>? headers;

  CacheObj._(this.key, this.subKey, this.content, this.statusCode, this.headers);

  factory CacheObj(
    String key,
    List<int> content, {
    String? subKey = "",
    Duration? maxAge,
    Duration? maxStale,
    int? statusCode = 200,
    List<int>? headers,
  }) {
    return CacheObj._(key, subKey, content, statusCode, headers)
      ..maxAge = maxAge
      ..maxStale = maxStale;
  }

  set maxAge(Duration? duration) {
    if (null != duration) this.maxAgeDate = _convertDuration(duration);
  }

  set maxStale(Duration? duration) {
    if (null != duration) this.maxStaleDate = _convertDuration(duration);
  }

  _convertDuration(Duration duration) => DateTime.now().add(duration).millisecondsSinceEpoch;
}
