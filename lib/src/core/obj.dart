import 'package:json_annotation/json_annotation.dart';

part 'obj.g.dart';

@JsonSerializable()
class CacheObj {
  String key;
  String subKey;
  @JsonKey(name: "max_age_date")
  int maxAgeDate;
  @JsonKey(name: "max_stale_date")
  int maxStaleDate;
  String content;

  CacheObj._(this.key, this.subKey, this.content);

  factory CacheObj(String key, String content,
      {String subKey = "", Duration maxAge, Duration maxStale}) {
    return CacheObj._(key, subKey, content)
      ..maxAge = maxAge
      ..maxStale = maxStale;
  }

  set maxAge(Duration duration) {
    if (null != duration) this.maxAgeDate = _convertDuration(duration);
  }

  set maxStale(Duration duration) {
    if (null != duration) this.maxStaleDate = _convertDuration(duration);
  }

  _convertDuration(Duration duration) =>
      DateTime.now().add(duration).millisecondsSinceEpoch;

  factory CacheObj.fromJson(Map<String, dynamic> json) =>
      _$CacheObjFromJson(json);

  toJson() => _$CacheObjToJson(this);
}
