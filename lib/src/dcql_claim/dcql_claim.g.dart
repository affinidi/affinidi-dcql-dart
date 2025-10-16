// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_claim.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DcqlClaim _$DcqlClaimFromJson(Map<String, dynamic> json) => DcqlClaim(
      id: json['id'] as String?,
      path: json['path'] as List<dynamic>,
      values: json['values'] as List<dynamic>?,
    );

Map<String, dynamic> _$DcqlClaimToJson(DcqlClaim instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'path': instance.path,
      if (instance.values case final value?) 'values': value,
    };
