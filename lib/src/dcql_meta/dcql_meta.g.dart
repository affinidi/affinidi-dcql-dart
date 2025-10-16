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
      if (instance.vctValues case final value?) 'vct_values': value,
      if (instance.doctypeValue case final value?) 'doctype_value': value,
      if (instance.typeValues case final value?) 'type_values': value,
    };
