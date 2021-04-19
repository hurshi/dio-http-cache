// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obj.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheObj _$CacheObjFromJson(Map<String, dynamic> json) {
  return CacheObj(
    json['key'] as String,
    (json['content'] as List<dynamic>).map((e) => e as int).toList(),
    subKey: json['subKey'] as String?,
    statusCode: json['statusCode'] as int?,
    headers: (json['headers'] as List<dynamic>?)?.map((e) => e as int).toList(),
  )
    ..maxAgeDate = json['max_age_date'] as int?
    ..maxStaleDate = json['max_stale_date'] as int?;
}

Map<String, dynamic> _$CacheObjToJson(CacheObj instance) => <String, dynamic>{
      'key': instance.key,
      'subKey': instance.subKey,
      'max_age_date': instance.maxAgeDate,
      'max_stale_date': instance.maxStaleDate,
      'content': instance.content,
      'statusCode': instance.statusCode,
      'headers': instance.headers,
    };
