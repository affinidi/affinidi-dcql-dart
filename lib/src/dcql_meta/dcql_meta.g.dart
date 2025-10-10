// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DcqlMeta _$DcqlMetaFromJson(Map<String, dynamic> json) => DcqlMeta(
      vctValues: (json['vct_values'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      doctypeValue: json['doctype_value'] as String?,
      typeValues: (json['type_values'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
    );

Map<String, dynamic> _$DcqlMetaToJson(DcqlMeta instance) => <String, dynamic>{
      'vct_values': instance.vctValues,
      'doctype_value': instance.doctypeValue,
      'type_values': instance.typeValues,
    };
