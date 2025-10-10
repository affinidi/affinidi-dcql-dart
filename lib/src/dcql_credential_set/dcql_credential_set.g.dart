// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dcql_credential_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DcqlCredentialSet _$DcqlCredentialSetFromJson(Map<String, dynamic> json) =>
    DcqlCredentialSet(
      options: (json['options'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      required: json['required'] as bool? ?? true,
    );

Map<String, dynamic> _$DcqlCredentialSetToJson(DcqlCredentialSet instance) =>
    <String, dynamic>{
      'options': instance.options,
      'required': instance.required,
    };
